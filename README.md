# premier-league-scraping

Implementação simples de um processo de automatização de coleta e compilação dos dados da página de estatísticas e jogadores do site da [Premier League](https://www.premierleague.com/stats/top/players/goals?se=210) inglesa utilizando R e RSelenium.

# RSelenium

[Rselenium](https://cran.r-project.org/web/packages/RSelenium/vignettes/basics.html) é uma implementação para R da API do [selenium](https://www.selenium.dev/). Esta ferramenta permite a automação e controle de um navegador web. Para o exemplo contido aqui essa ferramenta é importante pois permite que automatizemos uma coleta direta na página web requerida, simulando eventos (cliques) como um usuário padrão. 

**OBS:** Os scripts contidos nessa página servem como um exemplo de *webscraping* usando RSelenium. Leve em conta, que a coleta de dados em larga escala pode sobrecarregar a página buscada. Preferencialmente, use as API desenvolvidas para esse fim.

# Instruções

**OBS:** Os *scripts* foram escritos e testados em uma máquina Linux. Os procedimentos para outros sistemas operacionais devem ser similares, mas eu não posso garantir. 

- Você vai precisar do kit Java instalado. Utilizei o [OpenJdk](https://openjdk.java.net/install/). 

- Você vai precisar do navegador chromium / chrome. Preferencialmente nas versões betas.

Os pacotes do R necessários para reproduzir os scripts são:


```{r}
library(RSelenium)
library(XML)
library(wdman)
```
Obs: Alguns desses pacotes precisarão de dependências instaladas em seu sistema.
Fique atento às mensagens no console. Em ambiente Linux os pacotes estarão disponíveis
nos repositórios padrão.

Vá para o script `01-coleta-estatisticas.R` e carregue os pacotes. Preste atenção na seção de ativar
o servidor java no seu terminal para lançar o navegador. 

# Estatísticas disponíveis

O script de `01-coleta-estatisticas.R` baixa as estatísticas de gols para todos os jogadores nas temporadas 2010/11 à 2018/19 da Premier League.

Variáveis:

```
ano: temporada
rank: posição do jogador no rank de gols
jogador: nome do jogador
clube: nome do clube/time do jogador
pais: país de origem do jogador
score: número de gols.
```

O script `02-coleta-jogadores.R` lista todos os jogadores que atuaram na Premier League durante as temporadas 2009/10 à 2019/20.

Variáveis:

```
ano: temporada
jogador: nome do jogador
posicao: posição em que o jogador atua
pais: pais de origem do jogador
```

# Acesso aos dados:

Se você quer apenas os dados eles já estão na pasta `/dados`. o formato `.rds`
é nativo do R e foi escolhido pelo seu nível de compressão e limitação de espaço 
do GitHub.

Para carregá-los, abra o R e execute:

```
estatGols <- readRDS("./dados/brutos/estatsGols.rds")
jogadores <- readRDS("./dados/brutos/jogadores.rds")
```

# Próximos passos

Este projeto é um hobby, mas pretendo terminá-lo e empacotar as funções com todas as 
estatísticas disponíveis. Assim mais pessoas terão acesso sem precisar instalar ou executar o código manualmente.

Contudo, estou revendo a forma de implementação. Caso existam APIs grátis disponíveis, irei reimplementar a coleta com base nelas. Como já foi dito, a coleta de dados em larga escala pode sobrecarregar a página buscada. Não queremos derrubar o site, ou termos o IP bloqueado.

Essa é uma discução importante no webscraping. Se você se interessa veja esse post do 
[James Densmore](https://towardsdatascience.com/ethics-in-web-scraping-b96b18136f01) sobre Ética na prática da raspagem de dados.


# Licença

Não possuo os direitos sobre os dados, nem os pacotes utilizados. Em caso de dúvidas sobre sua utilização consulte as respectivas licenças. 

Quanto aos códigos você pode utilizá-los sobre os termos da [GPLv3](https://choosealicense.com/licenses/gpl-3.0/) quando aplicável. Créditos são apreciados, mas não requeridos.

