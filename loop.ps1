$MaxBeats = 6
$progressFile = "progress.md"
$fixesFile = "fixes-applied.txt"

$startedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

if (-not (Test-Path $progressFile)) {
    Set-Content -Path $progressFile -Value "# pass_stop loop progress"
}

$passed = $false
$try = 0

for ($i = 1; $i -le $MaxBeats; $i++) {
    $try = $i

    $before = ""
    if (Test-Path $fixesFile) { $before = (Get-Content $fixesFile).Trim() }

    node maker.js

    $after = ""
    if (Test-Path $fixesFile) { $after = (Get-Content $fixesFile).Trim() }

    $testOutput = npm test 2>&1
    $testExit = $LASTEXITCODE

    $line = "- beat $i : fixes=$after : test-exit=$testExit"
    Add-Content -Path $progressFile -Value $line
    Write-Output $line
    $testOutput | Select-Object -Last 6

    if ($testExit -eq 0) {
        $passed = $true
        break
    }

    if ($after -eq $before) {
        Write-Output "NO-PROGRESS: maker made no change and tests still fail, stopping early"
        break
    }
}

$finishedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

if ($passed) {
    Write-Output "PASSED on try $try (npm test returned 0)"
} else {
    Write-Output "STOPPED: no pass within $MaxBeats beats or no progress detected"
}

Add-Content -Path $progressFile -Value "Started: $startedAt"
Add-Content -Path $progressFile -Value "Finished: $finishedAt"
