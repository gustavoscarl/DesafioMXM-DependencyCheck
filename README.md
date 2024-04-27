# Projeto PayWise - Integração com OWASP Dependency Check

## Sobre o Projeto

Este desafio envolve a implementação da ferramenta [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/) no projeto PayWise, utilizado no Hackadev do bootcamp SharpCoders. A ferramenta verifica vulnerabilidades públicas em dependências e bibliotecas de terceiros, utilizando o banco de dados do National Vulnerability Database ([NVD](https://nvd.nist.gov/)). Para mais informações, consulte a [documentação oficial da ferramenta Dependency Check](https://owasp.org/www-project-dependency-check/).

## Requisitos para Execução neste Projeto

Os workflows do Dependency Check são executados automaticamente neste repositório sob as seguintes condições:
- Alterações (pushes) para os arquivos que listam as dependências (`package.json` e arquivos `.csproj`).
- Pull requests para a branch `main`.
- Execuções programadas diariamente em um horário definido.

## Como Instalar em Outro Projeto

### Pré-requisitos

- Criar uma [NVD API Key](https://nvd.nist.gov/developers/request-an-api-key).
- Estrutura de pastas necessária: Copie a pasta `.cicd` para a raiz do seu repositório com as subpastas `/dependency-check-report`, `/dependency-check-config` e `/scripts`.

### Configuração

1. **Configurar Secrets:**
   - NVD API Key: Crie um secret em `Settings -> Secrets and variables -> Actions -> New repository Secrets` com o nome `NVDAPIKEY`, contendo seu código de API.
   - Email do GitHub: Crie um secret para seu email do GitHub (ex: `seuemail@users.noreply.github.com`) com o nome `GIT_USER_EMAIL`.

2. **Workflow File:**
   - Copie o arquivo `.github/workflows/dependency_check.yml` para o mesmo caminho na pasta raiz do seu projeto.
   - Modifique as variáveis de ambiente no bloco `env` conforme necessário:
     ```yaml
     env:
       NOME_PROJETO: Nome do seu projeto
       SCANEAR_CAMINHO: Caminho para o scan do Dependency Check
       RESULTADO_CAMINHO: Caminho onde os relatórios HTML e JSON serão salvos
       ARQUIVO_SUPRESSAO: Caminho para o arquivo de supressão
       LINK_SUPRESSAO: Caminho completo para o arquivo de supressão
       LINK_RELATORIOS: Caminho completo para os relatórios
       USER_EMAIL: ${{ secrets.GIT_USER_EMAIL }}
       APIKEY: ${{ secrets.NVDAPIKEY }}
     ```

3. **(Opcional) Nome da Pipeline:**
   - Altere o valor de `name:` no arquivo `dependency_check.yml` para o nome desejado da pipeline.

4. **(Opcional) Regras de Gatilhamento:**
   - Defina as condições sob as quais o workflow será executado.
     ```yaml
      on:
        push:
          paths:
            - "frontend/package.json"
        pull_request:
          branches:
            - main
        schedule:
          - cron: "00 20 * * *"
     ```

5. **(Opcional) Configuração do Cache:**
   - Modifique `key` e `restore-keys` para configurar o cache apropriado.

6. **(Opcional) Configuração da Varredura:**
   - Configurar de acordo com suas necessidades, você pode ver todas as opções do Dependency Check CLI [aqui](https://jeremylong.github.io/DependencyCheck/dependency-check-cli/arguments.html)
 ```yaml
      - name: Executar Dependency Check CLI Scan
        run: |
          .\dependency-check\bin\dependency-check.bat --project "${{ env.NOME_PROJETO }}" --scan "${{ env.SCANEAR_CAMINHO }}" --out "${{ env.RESULTADO_CAMINHO }}" --format "HTML" --format "JSON" --suppression "${{ env.ARQUIVO_SUPRESSAO }}" --nvdApiKey="${{ env.APIKEY }}"
```
6. **Regras de Pull Request:**
   - Configure as regras no repositório do GitHub (`Settings -> Branches -> Add Rule`) ou (`Settings -> Rules -> Rulesets -> New ruleset`) para que os pull requests sejam efetuados apenas após a verificação pelo workflow.


## Resultados e Notificações do Dependency Check

### Resultados Possíveis
Existem três categorias de resultados ao executar o OWASP Dependency Check no projeto:

1. **Nenhuma Vulnerabilidade Encontrada**:
   - **Ação:** O teste passa normalmente sem falhas.
   - **Impacto:** Não há impacto nas operações de merge ou push.

2. **Vulnerabilidades Baixas e Médias Encontradas**:
   - **Ação:** O teste completa sem falhar.
   - **Impacto:** Emissão de um aviso (WARN) durante a execução da pipeline, incentivando revisão adicional.

3. **Vulnerabilidades Graves e Críticas Encontradas**:
   - **Ação:** O teste falha.
   - **Impacto:** Bloqueio de pull requests e notificação por email ao codeowner do repositório. Configurações adicionais podem ser ajustadas [aqui](https://github.com/settings/notifications).

### Gestão de Relatórios

- **Branches para Relatórios:** Para eventos de Pull Request e execuções programadas (schedule), novas branches são criadas automaticamente contendo os relatórios detalhados. Para saber mais sobre o código responsável por isso, verificar o job com nome "Commitar Relatórios do Dependency Check".
- **Localização dos Relatórios:** Os relatórios são salvos no diretório `.cicd/dependency-check-report`. Links diretos para os relatórios são disponibilizados nas logs do GitHub Actions após cada execução.
- **Visualização de Relatórios:** Os relatórios podem ser acessos tanto pela pasta `.cicd/dependency-check-report` em suas respectivas branches, ou pelo link de download (artifact). Os links são disponibilizados em cada run e armazenado por 90 dias:
  ![Visualização de Relatório](https://github.com/gustavoscarl/DesafioMXM-DependencyCheck/assets/104444836/69a2ecf3-eb1e-4fd8-b073-4ecaad31d3f4)

### Notificações de Falha

- **Email de Notificação:** Em caso de falhas graves ou críticas detectadas, uma notificação é enviada por email ao codeowner do projeto. A configuração de notificações pode ser personalizada [aqui](https://github.com/settings/notifications).
  
   ![image](https://github.com/gustavoscarl/DesafioMXM-DependencyCheck/assets/104444836/0decbfcb-08e6-409b-b515-eeee90d80886)

### Configurar Arquivo de Supressão (Falso Positivos)

**Configuração básica do arquivo:** Acessar o arquivo de supressão, por padrão: `.cicd/dependency-check-config/supression.xml` e adicionar as supressões. Você pode encontrar o código pronto nos relatórios HTML e clicando em "Suppress" e copiando o código SHA. Um exemplo de configuração é o código a seguir:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
  <suppress until="2024-05-07Z">
     <notes><![CDATA[
     file name: Azure.Core.dll
     ]]></notes>
     <packageUrl regex="true">^pkg:generic/Azure\.Core@.*$</packageUrl>
     <cve>CVE-2023-36052</cve>
  </suppress>
</suppressions>
```
Para mais informações sobre Falso Positivos, clicar [aqui](https://jeremylong.github.io/DependencyCheck/general/suppression.html)







