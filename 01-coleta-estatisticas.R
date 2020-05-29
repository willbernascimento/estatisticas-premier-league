## ------------------------------------------------------------------------- ##
## Script de automação de webscraping usando RSelenium
##
## Página:  Premier League (Inglaterra)
## Dados:   Estatísticas dos jogadores 
## URL:     <https://www.premierleague.com/stats/top/players/goals?se=210>
## Autor:   Willber Nascimento <nascimentowillber at gmail dot com>
## Licence: GPLv3
## 
## ------------------------------------------------------------------------- ##

## ------------- Carregamento dos pacotes --------

# Nota: Você precisa instalá-los se já não o fez. 

library(RSelenium)
library(XML)
library(wdman)

## -------------- Ativação do Servidor -----------

# criação de um servidor na máquina

selServ <- selenium(retcommand = TRUE, verbose = TRUE)

cat(selServ) 

# Cole o codigo da saida anterior no seu terminal.
# Você precisa ter o Java (OpenJdk) instalado na sua máquina.

# configure o navegador para automatização 
# você pode usar "firefox" ao invés de chrome
# a porta utilizada pode ser encontrada no seu terminal com o cat(selServ)

chrome <- remoteDriver(browserName="chrome", port=4567) 

## ----------------------------------------------------

## ------------- TESTE DO AMBIENTE INICIAL  -----------

# O resultado esperado dos comandos entre as linhas XX e XX é:
# 1: o navegador ser lançado e maximizado
# 2: o navegador carregar a página de interesse.
# 3: o botão de cookies ser apertado. 

# abrir navegador
chrome$open()
chrome$maxWindowSize()  

# indicar a URL
baseurl <- 'https://www.premierleague.com/stats/top/players/goals?se=210'
chrome$navigate(baseurl)

# tempo de carregamento da página

Sys.sleep(5)

# Vamos criar os botões para navergar na página solicitada

# Clicar em aceitar os cookies

bt_cookies <- chrome$findElement(using = 'xpath','/html/body/section/div/div')
bt_cookies$clickElement()

#------------------------------------------------------#




## ------------- INICIO DA COLETA ---------------------

## ------------- Inicio do loop -------------
# Vamos criar um loop simples para coletar cada uma das páginas disponíveis.
# O indexizador [i] são as temporadas disponíveis. O valor de [i]==1 retorna
# os dados para todas temporadas. Não iremos utilizá-lo.


# crie um objeto para gravar os dados a cada interação

estatisticasGols <- NULL

for (i in 1:10) {
  chrome$open(silent = T)
  chrome$maxWindowSize() 
  chrome$navigate(baseurl)
  Sys.sleep(8)
  bt_cookies <- chrome$findElement(using = 'xpath','/html/body/section/div/div')
  bt_cookies$clickElement()
  Sys.sleep(8)

# tempo de carregamento da página
# Coleta dos gols
  
drop <- chrome$findElement(using = 'xpath', '//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[1]/div[2]')
drop$clickElement()

Sys.sleep(2)

# seleciona a temporada

temporada <- chrome$findElement(using = 'xpath', paste0('//*[@id="mainContent"]/div[2]/div/div[2]/div[1]/section/div[1]/ul/li[',i+2,']'))
temporada$clickElement()

#paste0('//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[1]/ul/li[',i+2,']')
#//*[@id="mainContent"]/div[2]/div/div[2]/div[1]/section/div[1]/ul/li[3] = 1
#//*[@id="mainContent"]/div[2]/div/div[2]/div[1]/section/div[1]/ul/li[4] = 2
#//*[@id="mainContent"]/div[2]/div/div[2]/div[1]/section/div[1]/ul/li[5] = 3
#//*[@id="mainContent"]/div[2]/div/div[2]/div[1]/section/div[1]/ul/li[6] = 4
#//*[@id="mainContent"]/div[2]/div/div[2]/div[1]/section/div[1]/ul/li[10] = 8
#//*[@id="mainContent"]/div[2]/div/div[2]/div[1]/section/div[1]/ul/li[12] = 10

Sys.sleep(3)

# baixa o código fonte da página

cod_font <- htmlParse(chrome$getPageSource()[[1]], encoding = "utf-8")

# Grava o ano/temporada
ano <- xpathSApply(cod_font, '//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[1]/div[2]/text()', xmlValue)

print(ano)

# Esse loop coleta as estatísticas de gols dos jogadores disponíveis na página
# Você pode melhorar essa parte buscando no código fonte da página. Eu vizualizei
# manualmente e inseri no loop.

for (j in 1:12) {

cod_font_j <- htmlParse(chrome$getPageSource()[[1]], encoding = "utf-8")

rank <- xpathSApply(cod_font_j,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[1]', xmlValue)
rank

jogador <- xpathSApply(cod_font_j,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[2]', xmlValue)
jogador

clube <- xpathSApply(cod_font_j,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[3]', xmlValue)
clube

pais <- xpathSApply(cod_font_j,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[4]', xmlValue)
pais

score <- xpathSApply(cod_font_j,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[5]', xmlValue)
score

# cria o data.frame de cada jogador i

dados <- data.frame(ano,rank, jogador,clube, pais, score, stringsAsFactors = F)

# salva cada interação em um objeto 

estatisticasGols <- rbind(estatisticasGols, dados)

# botão para passar a página

bt_pagina <- chrome$findElement(using = 'xpath', '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[3]/div[2]')
bt_pagina$clickElement()


# tempo para carregar, e indicação da página que carregou
Sys.sleep(5)


print(j)

# volta pra HOME do site para poder coletar desde a primeira
# linha da nova página

webElem <- chrome$findElement("css", "body")
webElem$sendKeysToElement(list(key = "home"))

}

# volta pra HOME do site para poder coletar desde a primeira
# linha da nova página
#webElem <- chrome$findElement("css", "body")
#webElem$sendKeysToElement(list(key = "home"))
chrome$closeWindow()

}

system("mkdir -p ./dados/brutos/")
saveRDS(estatisticasGols, "./dados/brutos/estatisticasGols.rds")
