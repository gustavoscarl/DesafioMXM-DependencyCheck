# Define o arquivo JSON gerado pela Dependency Check e converte para Objeto, na variável report
$report = Get-Content -Path "./dependency-check-report/dependency-check-report.json" | ConvertFrom-Json

# Contadores de severidades alta e críticas
$highLevel = $false
$criticalLevel = $false

#Define que o padrão de vulnerabilidade e warn é nulo/falso
$vulnerable = $false
$warn = $false

# Obtém a data do relatório em formato string
$dateReport = $report.projectInfo.reportDate

# Converte a string para um objeto DateTime
$dateTime = [DateTime]::Parse($dateReport)

# Especifica que o DateTime é do tipo UTC
$dateTimeUtc = [DateTime]::SpecifyKind($dateTime, [DateTimeKind]::Utc)

# Encontra a informação do fuso horário de Brasília (GMT-3)
$timeZoneBrasilia = [TimeZoneInfo]::FindSystemTimeZoneById("E. South America Standard Time")

# Converte a data UTC para o horário de Brasília
$localDateTime = [TimeZoneInfo]::ConvertTimeFromUtc($dateTimeUtc, $timeZoneBrasilia)

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

# Dicionário dos graus de severidade das vulnerabilidades de cada dependência, atribuindo um valor para cada para determinar a maior
$severityLevels = @{ 'LOW' = 0; 'MEDIUM' = 1; 'HIGH' = 2; 'HIGHEST' = 3; 'CRITICAL' = 4 }

# Analisa cada dependência dentro da array dependencies
foreach ($dependency in $report.dependencies) {

  # Definidos como -1 e nulo para não interferir no mapeamento de qual a maior severidade no passo abaixo (foreach vuln in vulnerabilities)
  $highestSeverity = -1
  $highestSeverityLabel = ""

  $evidence = $dependency.evidenceCollected
  
  # Caso dependency tenha o objeto 'vulnerabilities', irá parsear as informações do JSON convertido.
  if ($dependency.vulnerabilities) {
    # Foreach para parsear a severidade maior de cada dependency, utilizando de variavel auxiliar $highestSeverityLabel. $severityLevels[$vuln.severity] faz com que a severidade atual seja incluída no dicionário, definindo seu valor número a partir da string ('LOW','MEDIUM', etc).
    foreach ($vuln in $dependency.vulnerabilities) {
      $currentSeverity = $severityLevels[$vuln.severity]
      if ($currentSeverity -gt $highestSeverity) {
        $highestSeverity = $currentSeverity
        $highestSeverityLabel = $vuln.severity
      }

      if ($vuln.severity -eq 'LOW') {
        $lowLevel = $true
        $warn = $true
      }
      if ($vuln.severity -eq 'MEDIUM') {
        $mediumLevel = $true
        $warn = $true
      }
      if ($vuln.severity -eq 'HIGH') {
        $highLevel = $true
        $vulnerable = $true
      }
      if ($vuln.severity -eq 'CRITICAL') {
        $criticalLevel = $true
        $vulnerable = $true
      }

    }

    # Transforma todos os CPES dentro de report.dependencies.vulnerabilities.vulnerableSoftware.software.id e transforma seleciona ao final somente os com nome únicos
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
if (-not $vulnerable -and -not $warn) {
  Write-Output "===================================================="
  Write-Output "No Vulnerabilities Found! Check https://jeremylong.github.io/DependencyCheck/general/hints.html on how to search for False Negatives."
  Write-Output "vulnerable=false" >> $env:GITHUB_OUTPUT
}

if ($warn -eq 'true') {
  Write-Output "warn=true" >> $env:GITHUB_OUTPUT
  if ($lowLevel) {
    Write-Output "lowLevel=true" | Out-File -Append $env:GITHUB_OUTPUT
  }
  if ($mediumLevel) {
    Write-Output "mediumLevel=true" | Out-File -Append $env:GITHUB_OUTPUT
  }
}


if ($vulnerable) {
  Write-Output "vulnerable=true" >> $env:GITHUB_OUTPUT
  if ($highLevel) {
    Write-Output "highLevel=true" | Out-File -Append $env:GITHUB_OUTPUT
  }
  if ($criticalLevel) {
    Write-Output "criticalLevel=true" | Out-File -Append $env:GITHUB_OUTPUT
  }
}
