param (
  [string]$CaminhoRelatorio
)

# Define o arquivo JSON gerado pela Dependency Check e converte para Objeto, na variável relatorio.
$relatorio = Get-Content -Path $CaminhoRelatorio | ConvertFrom-Json

# Sinalizadores de severidades das vulnerabilidades
$baixoNivel = $false
$medioNivel = $false
$altoNivel = $false
$criticoNivel = $false


#Define que o padrão de vulnerabilidade e aviso é nulo/falso
$vulnerabilidade = $false
$aviso = $false

# Obtém a data do relatório em formato string
$dataRelatorio = $relatorio.projectInfo.reportDate

# Converte a string para um objeto DateTime
$dataTempo = [DateTime]::Parse($dataRelatorio)

# Especifica que o DateTime é do tipo UTC
$dataTempoUtc = [DateTime]::SpecifyKind($dataTempo, [DateTimeKind]::Utc)

# Encontra a informação do fuso horário de Brasília (GMT-3)
$timeZoneBrasilia = [TimeZoneInfo]::FindSystemTimeZoneById("E. South America Standard Time")

# Converte a data UTC para o horário de Brasília
$localDataTempo = [TimeZoneInfo]::ConvertTimeFromUtc($dataTempoUtc, $timeZoneBrasilia)

# Formata a data para o formato desejado: "dd/MM/yyyy at HH:mm:ss 'GMT-3'"
$dataFormatada = $localDataTempo.ToString("dd/MM/yyyy 'at' HH:mm:ss 'GMT-3'")

# Variavel do nome do projeto
$nomeRelatorio = $relatorio.projectInfo.name

# Variavel da versão do projeto
$versaoRelatorio = $relatorio.scanInfo.engineVersion

Write-Output "`n"

Write-Output "Detalhes de Relatorio:"

Write-Output "`n"

Write-Output "Versão Dependency Check: $versaoRelatorio"
Write-Output "Data de Relatorio: $dataFormatada"
Write-Output "Nome do Projeto: $nomeRelatorio"

Write-Output "`n"

# Dicionário dos graus de severidade das vulnerabilidades de cada dependência, atribuindo um valor para cada para determinar a maior
$severidadesNiveis = @{ 'BAIXO' = 0; 'MEDIO' = 1; 'ALTO' = 2; 'ALTISSIMO' = 3; 'CRITICO' = 4 }

# Analisa cada dependência dentro da array dependencies
foreach ($dependencia in $relatorio.dependencies) {

  # Definidos como -1 e nulo para não interferir no mapeamento de qual a maior severidade no passo abaixo (foreach vuln in vulnerabilities)
  $severidadeMaior = -1
  $severidadeMaiorRotulo = ""

  $evidencia = $dependencia.evidenceCollected
  
  # Caso dependencia tenha o objeto 'vulnerabilities', irá parsear as informações do JSON convertido.
  if ($dependencia.vulnerabilities) {
    # Foreach para parsear a severidade maior de cada dependencia, utilizando de variavel auxiliar $severidadeMaiorRotulo. $severidadesNiveis[$vuln.severity] faz com que a severidade atual seja incluída no dicionário, definindo seu valor número a partir da string ('BAIXO','MEDIO', etc).
    foreach ($vuln in $dependencia.vulnerabilities) {
      $severidadeAtual = $severidadesNiveis[$vuln.severity]
      if ($severidadeAtual -gt $severidadeMaior) {
        $severidadeMaior = $severidadeAtual
        $severidadeMaiorRotulo = $vuln.severity
      }

      if ($vuln.severity -eq 'BAIXO') {
        $baixoNivel = $true
        $aviso = $true
      }
      if ($vuln.severity -eq 'MEDIO') {
        $medioNivel = $true
        $aviso = $true
      }
      if ($vuln.severity -eq 'HIGH') {
        $altoNivel = $true
        $vulnerabilidade = $true
      }
      if ($vuln.severity -eq 'CRITICO') {
        $criticoNivel = $true
        $vulnerabilidade = $true
      }

    }

    # Transforma todos os CPES dentro de relatorio.dependencies.vulnerabilities.vulnerableSoftware.software.id e transforma seleciona ao final somente os com nome únicos
    $cpeList = $dependencia.vulnerabilities | ForEach-Object { 
      $_.vulnerableSoftware | ForEach-Object { $_.software.id } 
    } | Select-Object -Unique

    $totalCVEs = $dependencia.vulnerabilities.Count

    $totalEvidencias = $evidencia.vendorEvidence.Count + $evidencia.productEvidence.Count + $evidencia.versionEvidence.Count

    if ($dependencia.vulnerabilityIds -and $dependencia.vulnerabilityIds.Count -gt 0) {
      $primeiraConfiancaVulnerabilidade = $dependencia.vulnerabilityIds[0].Confidence
    }
    else {
      $primeiraConfiancaVulnerabilidade = "No Vulnerability IDs Found"
    }


    
    Write-Output "===================================================="
    Write-Output "Dependency: $($dependencia.fileName)"
    Write-Output "Vulnerability IDs: $($cpeList -join ', ')"
    Write-Output "Package: $($dependencia.packages.id)"
    Write-Output "Highest Severity: $severidadeMaiorRotulo"
    Write-Output "CVE Count: $totalCVEs"
    Write-Output "CPE Confidence: $primeiraConfiancaVulnerabilidade"
    Write-Output "Total Evidence: $totalEvidencias"

  }
}
if (-not $vulnerabilidade -and -not $aviso) {
  Write-Output "===================================================="
  Write-Output "Nenhuma Vulnerabilidade Encontrada! Veja https://jeremylong.github.io/DependencyCheck/general/hints.html para saber como procurar falsos negativos."
  Write-Output "vulnerabilidade=false" >> $env:GITHUB_OUTPUT
}

if ($aviso -eq 'true') {
  Write-Output "aviso=true" >> $env:GITHUB_OUTPUT
  if ($baixoNivel) {
    Write-Output "baixoNivel=true" | Out-File -Append $env:GITHUB_OUTPUT
  }
  if ($medioNivel) {
    Write-Output "medioNivel=true" | Out-File -Append $env:GITHUB_OUTPUT
  }
}


if ($vulnerabilidade) {
  Write-Output "vulnerabilidade=true" >> $env:GITHUB_OUTPUT
  if ($altoNivel) {
    Write-Output "altoNivel=true" | Out-File -Append $env:GITHUB_OUTPUT
  }
  if ($criticoNivel) {
    Write-Output "criticoNivel=true" | Out-File -Append $env:GITHUB_OUTPUT
  }
}
