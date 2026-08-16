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
$fixCounter = 0

for ($i = 1; $i -le $MaxBeats; $i++) {
    $try = $i

    node maker.js $i

    $fixCounter = $fixCounter + 1
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "DONE-$fixCounter at $now" | Add-Content -Path $fixesFile

    $testOutput = npm test 2>&1
    $testExit = $LASTEXITCODE

    $idx = $fixCounter - 1
    if ($idx -ge 0 -and $idx -lt $TotalBugs) {
        $fixedName = $bugNames[$idx]
        $fixedDesc = "fixed '$fixedName' (was '$($bugBefore[$idx])', now '$($bugAfter[$idx])')"
    } else {
        $fixedDesc = "no error fixed"
    }

    $remainingCount = $TotalBugs - $fixCounter
    if ($remainingCount -lt 0) { $remainingCount = 0 }

    $remainingNames = @()
    for ($j = $fixCounter; $j -lt $TotalBugs; $j++) {
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
