param (
  [string]$highLevel,
  [string]$criticalLevel
)

Write-Output "Vulnerabilities found, failing the build."
Write-Output "`n"
if ($highLevel -eq "true") {
  Write-Output "HIGH Severity Vulnerabilities Found."
}
if ($criticalLevel -eq "true") {
  Write-Output "CRITICAL Severity Vulnerabilities Found."
}
Write-Output "Check and update your packages to fix security."
exit 1