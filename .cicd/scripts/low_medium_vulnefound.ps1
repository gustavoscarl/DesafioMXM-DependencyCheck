param (
  [string]$baixoNivel,
  [string]$medioNivel,
  [string]$linkSupressao,
  [string]$linkRelatorios
)

Write-Warning "Vulnerabilidades Baixas ou Médias encontradas, por favor, tenha cuidado."
Write-Output "`n"
if ($baixoNivel -eq "true") {
  Write-Warning "Vulnerabilidades de Baixa Gravidade encontradas."
}
if ($medioNivel -eq "true") {
  Write-Warning "Vulnerabilidades de Gravidade Média encontradas."
}
Write-Output "Verifique e atualize seus pacotes para corrigir a segurança do projeto. Se você acha que isso é um erro, entre em contato com a equipe em 'gustavo@gmail.com'.`nPara adicionar vulnerabilidades à lista de supressão (lista de falsos positivos), você pode defini-lás em $linkSupressao . Mais informações sobre perguntas frequentes podem ser encontradas no README deste repositório e na documentação oficial.`nPara acessar os Relatórios JSON e HTML completos e nativos da ferramenta, acesse: $linkRelatorios `nVocê pode descobrir mais sobre a verificação de dependência da OWASP na documentação oficial em https://jeremylong.github.io/DependencyCheck/"