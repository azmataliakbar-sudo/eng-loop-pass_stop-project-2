$broken = @"
function add(a, b) { return a - b; }
function subtract(a, b) { return a + b; }
function multiply(a, b) { return a / b; }
module.exports = { add, subtract, multiply };
"@

Set-Content -Path "src\calc.js" -Value $broken
Set-Content -Path "fixes-applied.txt" -Value "# fixes-applied log"
Set-Content -Path "progress.md" -Value "# pass_stop loop progress"

Write-Output "Reset to broken baseline. Run .\loop.ps1 to start."
