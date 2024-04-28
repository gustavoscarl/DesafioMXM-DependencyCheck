param (
  [string]$altoNivel,
  [string]$criticoNivel,
  [string]$linkSupressao,
  [string]$linkArtifact,
  [string]$linkRelatorios
)

Write-Output "Vulnerabilidades Alta ou Críticas encontradas, falhando a build."
Write-Output "`n"
if ($altoNivel -eq "true") {
  Write-Output "[FALHA] Vulnerabilidades de Alta Gravidade encontradas."
}
if ($criticoNivel -eq "true") {
  Write-Output "[FALHA] Vulnerabilidades de Gravidade Crítica encontradas."
}
Write-Output "Verifique e atualize seus pacotes para corrigir a segurança do projeto"
Write-Output "Se você acha que isso é um erro, entre em contato com a equipe em 'gustavo@gmail.com'"
Write-Output "Para adicionar vulnerabilidades à lista de supressão (lista de falsos positivos), você pode defini-lás em $linkSupressao"
Write-Output "Mais informações sobre perguntas frequentes podem ser encontradas no README deste repositório e na documentação oficial"
Write-Output "Para acessar os Relatórios JSON e HTML completos e nativos da ferramenta, acesse: $linkArtifact"
Write-Output "Você também pode acessar os relatórios pelo arquivo do repositório em: $linkRelatorios"
Write-Output "Você pode descobrir mais sobre a verificação de dependência da OWASP na documentação oficial em https://jeremylong.github.io/DependencyCheck/"

exit 1