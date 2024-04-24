param (
  [string]$altoNivel,
  [string]$criticoNivel
)

Write-Output "Vulnerabilities found, failing the build."
Write-Output "`n"
if ($altoNivel -eq "true") {
  Write-Output "[FALHA] Vulnerabilidades de Alta Gravidade encontradas."
}
if ($criticoNivel -eq "true") {
  Write-Output "[FALHA] Vulnerabilidades de Gravidade Crítica encontradas."
}
Write-Output "`nVerifique e atualize seus pacotes para corrigir a segurança do projeto. Se você acha que isso é um erro, entre em contato com a equipe em 'gustavo@gmail.com'.`nPara adicionar vulnerabilidades a lista de supressão (lista de falsos positivos), você pode defini-las em './cicd/dependency-check-config/supplession-xxx.xml'. Mais informações sobre perguntas frequentes podem ser encontradas no README deste repositório e na documentação oficial.`nVoce pode descobrir mais sobre a verificação de dependência da OWASP na documentação oficial em https://jeremylong.github.io/dependencycheck/index.html"

exit 1