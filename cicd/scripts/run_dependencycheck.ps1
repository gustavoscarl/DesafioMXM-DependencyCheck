$report = Get-Content -Path "./dependency-check-report/dependency-check-report.json" | ConvertFrom-Json
$vulnerable = $false
Write-Output "Vulnerabilities Details:"

$severityLevels = @{ 'LOW' = 0; 'MEDIUM' = 1; 'HIGH' = 2; 'HIGHEST' = 3; 'CRITICAL' = 4 }

foreach ($dependency in $report.dependencies) {
  $highestSeverity = -1
  $highestSeverityLabel = ""
  $evidence = $dependency.evidenceCollected
    
  if ($dependency.vulnerabilities) {
    $vulnerable = $true
    foreach ($vuln in $dependency.vulnerabilities) {
      $currentSeverity = $severityLevels[$vuln.severity]
      if ($currentSeverity -gt $highestSeverity) {
        $highestSeverity = $currentSeverity
        $highestSeverityLabel = $vuln.severity
      }
    }
    $cpeList = $dependency.vulnerabilities | ForEach-Object { 
      $_.vulnerableSoftware | ForEach-Object { $_.software.id } 
    } | Select-Object -Unique

    $totalCVEs = $dependency.vulnerabilities.Count

    $totalEvidence = $evidence.vendorEvidence.Count + $evidence.productEvidence.Count + $evidence.versionEvidence.Count

    $firstVulnerabilityIdConfidence = $dependency.vulnerabilityIds[0].confidence


    
    Write-Output "===================================================="
    Write-Output "Dependency: $($dependency.fileName)"
    Write-Output "Vulnerability IDs: $($cpeList -join ', ')"
    Write-Output "Package: $($dependency.packages.id)"
    Write-Output "Highest Severity: $highestSeverityLabel"
    Write-Output "CVE Count: $totalCVEs"
    Write-Output "CPE Confidence: $firstVulnerabilityIdConfidence"
    Write-Output "Total Evidence: $totalEvidence"

  }
}
if (-not $vulnerable) {
  Write-Output "No Vulnerabilities Found! Check https://jeremylong.github.io/DependencyCheck/general/hints.html on how to search for False Negatives."
}
if ($vulnerable) {
  echo "vulnerable=true" >> $env:GITHUB_OUTPUT
}
else {
  echo "vulnerable=false" >> $env:GITHUB_OUTPUT
}