param (
  [string]$highLevel,
  [string]$criticalLevel
)

Write-Output "Vulnerabilities found, failing the build."
Write-Output "`n"
if ($highLevel -eq "true") {
  Write-Output "[FAIL] HIGH Severity Vulnerabilities Found."
}
if ($criticalLevel -eq "true") {
  Write-Output "[FAIL] CRITICAL Severity Vulnerabilities Found."
}
Write-Output "`nCheck and update your packages to fix security. If you think that this is a mistake, contact the team at 'gustavo@gmail.com'.`nTo add vulnerabilities to suppression list (false positive list) you can set on ./cicd/dependency-check-config/suppression-XXX.xml file. More info on FAQs in this repository README and in the official documentation.`nYou can discover more about OWASP Dependency Check in the official documentation at https://jeremylong.github.io/DependencyCheck/index.html"

exit 1