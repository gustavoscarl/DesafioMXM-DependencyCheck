param (
  [string]$lowLevel,
  [string]$mediumLevel
)

Write-Warning "Low or Medium Vulnerabilities found, please be careful."
Write-Output "`n"
if ($lowLevel -eq "true") {
  Write-Warning "LOW Severity Vulnerabilities Found."
}
if ($mediumLevel -eq "true") {
  Write-Warning "MEDIUM Severity Vulnerabilities Found."
}
Write-Output "Check and update your packages to fix security. If you think that this is a mistake, contact the team at 'gustavo@gmail.com'.`nTo add vulnerabilities to suppression list (false positive list) you can set on ./cicd/dependency-check-config/suppression-XXX.xml file. More info on FAQs in this repository README and in the official documentation.`nYou can discover more about OWASP Dependency Check in the official documentation at https://jeremylong.github.io/DependencyCheck/index.html"