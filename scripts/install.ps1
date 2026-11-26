<#
.SYNOPSIS
  AI-DLC workflow (규칙, 스킬, Claude Code hook) 를 대상 프로젝트에 설치한다.

.EXAMPLE
  .\scripts\install.ps1 -Project C:\work\my-app -Agent claude
  .\scripts\install.ps1 -Project C:\work\my-app -Agent codex
  .\scripts\install.ps1 -Project C:\work\my-app -Agent both -Force
#>
param(
    [string]$Project = (Get-Location).Path,
    [ValidateSet('claude', 'codex', 'both')]
    [string]$Agent = 'claude',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Utf8 = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path $Project -PathType Container)) { throw "프로젝트 폴더 없음: $Project" }
$Project = (Resolve-Path $Project).Path

function Copy-Item-Safe([string]$From, [string]$To) {
    if ((Test-Path $To) -and -not $Force) {
        Write-Host "  건너뜀 (이미 있음, 덮어쓰려면 -Force): $To"
        return
    }
    if (Test-Path $To) { Remove-Item $To -Recurse -Force }
    New-Item -ItemType Directory -Force (Split-Path -Parent $To) | Out-Null
    Copy-Item $From $To -Recurse -Force
    Write-Host "  설치: $To"
}

function Add-Snippet([string]$File, [string]$Template) {
    $snippet = [IO.File]::ReadAllText($Template, $Utf8)
    if (Test-Path $File) {
        $text = [IO.File]::ReadAllText($File, $Utf8)
        if ($text -match 'aidlc-workflow:begin') {
            Write-Host "  건너뜀 (AI-DLC 절 이미 있음): $File"
            return
        }
        $sep = if ($text.EndsWith("`n")) { "`n" } else { "`n`n" }
        [IO.File]::AppendAllText($File, $sep + $snippet, $Utf8)
    } else {
        [IO.File]::WriteAllText($File, $snippet, $Utf8)
    }
    Write-Host "  AI-DLC 절 추가: $File"
}

function Install-Skills([string]$SkillsDir) {
    Get-ChildItem (Join-Path $Root 'skills') -Directory | ForEach-Object {
        Copy-Item-Safe $_.FullName (Join-Path $SkillsDir $_.Name)
    }
}

Write-Host "[1] 규칙 -> $Project\.aidlc-rule-details"
Copy-Item-Safe (Join-Path $Root 'aidlc-rule-details') (Join-Path $Project '.aidlc-rule-details')

if ($Agent -in 'claude', 'both') {
    Write-Host "[2] Claude Code"
    $claude = Join-Path $Project '.claude'
    Install-Skills (Join-Path $claude 'skills')
    Copy-Item-Safe (Join-Path $Root 'claude\agents\aidlc-traceability.md') (Join-Path $claude 'agents\aidlc-traceability.md')
    Get-ChildItem (Join-Path $Root 'claude\hooks') -Filter '*.py' | ForEach-Object {
        Copy-Item-Safe $_.FullName (Join-Path $claude "hooks\$($_.Name)")
    }
    $settings = Join-Path $claude 'settings.json'
    if ((Test-Path $settings) -and ([IO.File]::ReadAllText($settings) -match 'aidlc_audit\.py')) {
        Write-Host "  건너뜀 (AI-DLC hook 이미 등록됨): $settings"
    } elseif (Test-Path $settings) {
        Copy-Item (Join-Path $Root 'claude\settings.json') (Join-Path $claude 'settings.aidlc.json') -Force
        Write-Host "  주의: settings.json 이 이미 있어 덮어쓰지 않음. .claude\settings.aidlc.json 의 hooks, statusLine 을 직접 합칠 것"
    } else {
        Copy-Item (Join-Path $Root 'claude\settings.json') $settings
        Write-Host "  설치: $settings"
    }
    Add-Snippet (Join-Path $Project 'CLAUDE.md') (Join-Path $Root 'templates\CLAUDE.aidlc.md')
}

if ($Agent -in 'codex', 'both') {
    Write-Host "[3] Codex"
    Install-Skills (Join-Path $Project '.agents\skills')
    Add-Snippet (Join-Path $Project 'AGENTS.md') (Join-Path $Root 'templates\AGENTS.aidlc.md')
}

Write-Host "완료. 에이전트를 다시 시작한 뒤 /aidlc (Claude Code) 또는 `$aidlc (Codex) 로 상태를 확인하세요."
