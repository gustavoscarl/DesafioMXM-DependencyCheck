$report = Get-Content -Path "./dependency-check-report/dependency-check-report.json" | ConvertFrom-Json
$vulnerable = $false
Write-Output "Vulnerabilities Found:"

$severityLevels = @{ 'LOW' = 0; 'MEDIUM' = 1; 'HIGH' = 2; 'HIGHEST' = 3; 'CRITICAL' = 4 }

foreach ($dependency in $report.dependencies) {
    $highestSeverity = -1
    $highestSeverityLabel = ""
    
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
    
        Write-Output "===================================================="
        Write-Output "Dependency: $($dependency.fileName)"
        Write-Output "CPEs: $($cpeList -join ', ')"
        Write-Output "Package: $($dependency.packages.id)"
        Write-Output "Highest Severity: $highestSeverityLabel"
    }
}
if ($vulnerable) {
    echo "vulnerable=true" >> $env:GITHUB_OUTPUT
} else {
    echo "vulnerable=false" >> $env:GITHUB_OUTPUT
}