# Define o arquivo JSON gerado pela Dependency Check e converte para Objeto, na variável report
$report = Get-Content -Path "./dependency-check-report/dependency-check-report.json" | ConvertFrom-Json

#Define que o padrão de vulnerabilidade é nulo/falso
$vulnerable = $false

# Obtém a data do relatório em formato string
$dateReport = $report.projectInfo.reportDate

# Converte a string para um objeto DateTime
$dateTime = [DateTime]::Parse($dateReport)

# Encontra a informação do fuso horário de Brasília (GMT-3)
$timeZoneBrasilia = [TimeZoneInfo]::FindSystemTimeZoneById("E. South America Standard Time")

# Converte a data UTC para o horário de Brasília
$localDateTime = [TimeZoneInfo]::ConvertTimeFromUtc($dateTime, $timeZoneBrasilia)

# Formata a data para o formato desejado: "dd/MM/yyyy at HH:mm:ss 'GMT-3'"
$formattedDate = $localDateTime.ToString("dd/MM/yyyy 'at' HH:mm:ss 'GMT-3'")

# Variavel do nome do projeto
$nameReport = $report.projectInfo.name

# Variavel da versão do projeto
$versionReport = $report.scanInfo.engineVersion

Write-Output "`n"

Write-Output "Report Details:"

Write-Output "`n"

Write-Output "Dependency Check Version: $versionReport"
Write-Output "Report Date: $formattedDate"
Write-Output "Project Name: $nameReport"

Write-Output "`n"

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