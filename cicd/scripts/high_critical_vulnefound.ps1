param (
  [string]$highLevel,
  [string]$criticalLevel
)

Write-Output "Vulnerabilities found, failing the build."
Write-Output "`n"
if ($highLevel -eq "true") {
  Write-Error "HIGH Severity Vulnerabilities Found."
}
if ($criticalLevel -eq "true") {
  Write-Error "CRITICAL Severity Vulnerabilities Found."
}
Write-Output "Check and update your packages to fix security. If you think that this is a mistake, contact the team at 'gustavo@gmail.com'.`nYou can discover more about OWASP Dependency Check in the official documentation at https://jeremylong.github.io/DependencyCheck/index.html"
exit 1