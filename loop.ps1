$MaxBeats = 6
$progressFile = "progress.md"
$fixesFile = "fixes-applied.txt"

$bugNames = @("add", "subtract", "multiply")
$bugBefore = @("a - b", "a + b", "a / b")
$bugAfter = @("a + b", "a - b", "a * b")
$TotalBugs = $bugNames.Count

$startedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

if (-not (Test-Path $progressFile)) {
    Set-Content -Path $progressFile -Value "# pass_stop loop progress"
}

$passed = $false
$try = 0
$beatLines = @()

for ($i = 1; $i -le $MaxBeats; $i++) {
    $try = $i

    $before = ""
    if (Test-Path $fixesFile) { $before = (Get-Content $fixesFile).Trim() }

    node maker.js

    $after = ""
    if (Test-Path $fixesFile) { $after = (Get-Content $fixesFile).Trim() }

    $testOutput = npm test 2>&1
    $testExit = $LASTEXITCODE

    $fixedThisLoop = $after - $before
    if ($fixedThisLoop -gt 0) {
        $idx = [int]$after - 1
        $fixedName = $bugNames[$idx]
        $fixedDesc = "fixed '$fixedName' (was '$($bugBefore[$idx])', now '$($bugAfter[$idx])')"
    } else {
        $fixedDesc = "no error fixed"
    }

    $remainingCount = $TotalBugs - [int]$after
    if ($remainingCount -lt 0) { $remainingCount = 0 }

    $remainingNames = @()
    for ($j = [int]$after; $j -lt $TotalBugs; $j++) {
        $remainingNames += "$($bugNames[$j]) (still '$($bugBefore[$j])')"
    }

    if ($remainingCount -eq 0) {
        $remainingDesc = "none"
    } else {
        $remainingDesc = $remainingNames -join ", "
    }

    if ($testExit -eq 0) {
        $verdict = "PASS"
    } else {
        $verdict = "still failing"
    }

    $line = "Loop $i : $fixedDesc : remaining=$remainingDesc : test says $verdict"
    Write-Output $line
    Add-Content -Path $progressFile -Value "- $line"
    $beatLines += $line

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
    $result = "PASSED on try $try"
    Write-Output $result
} else {
    $result = "STOPPED after $try beats"
    Write-Output $result
}

$existingSummaries = Get-ChildItem -Filter "SUMMARY*.md" -ErrorAction SilentlyContinue
$nextSummary = $existingSummaries.Count + 1
$summaryFile = "SUMMARY$nextSummary.md"

$content = @(
    "Run: $nextSummary"
    "Started: $startedAt"
    "Finished: $finishedAt"
    "Result: $result"
    "Beats:"
) + ($beatLines | ForEach-Object { "  $_" })

Set-Content -Path $summaryFile -Value $content

Add-Content -Path $progressFile -Value "Run $nextSummary started: $startedAt"
Add-Content -Path $progressFile -Value "Run $nextSummary finished: $finishedAt"
