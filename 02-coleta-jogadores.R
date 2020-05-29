## ------------------------------------------------------------------------- ##
## Script de automação de webscraping usando RSelenium
##
## Página:  Premier League (Inglaterra)
## Dados:   Jogadores cadastrados na Premier League
## URL:     <https://www.premierleague.com/players>
## Autor:   Willber Nascimento <nascimentowillber at gmail dot com>
## Licence: GPLv3
## 
## ------------------------------------------------------------------------- ##

## ------------- Carregamento dos pacotes --------

# Nota: Você precisa instalá-los se já não o fez. 

library(RSelenium)
library(XML)
library(httr)
library(wdman)
library(electionsBR)
library(dplyr)

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

chrome$open() # abrir navegador

# indicar a URL

baseurl <- 'https://www.premierleague.com/players'
chrome$navigate(baseurl)

Sys.sleep(2)

bt_cookies <- chrome$findElement(using = 'xpath','/html/body/section/div/div')
bt_cookies$clickElement()



# Vamos criar um loop simples para coletar as informações das temporadas
# na página atual. 

# O indexador i representa a quantidade de temporadas que você vai coletar.
# i = 1 é a temporada mais recente. Dentro do loop coleto a informação exata
# da temporada.

# crie um objeto para gravar os dados a cada interação

jogadores <- NULL


# -------------- Inicia o loop --------

for (i in 1:11) {
  

drop <- chrome$findElement(using = 'xpath',  
                           value = '//*[@id="mainContent"]/div/div[1]/div/section/div[1]/div[2]')
drop$clickElement()


# tempo para carregar a página: 
# Quanto maior, mais lento até terminar. Contudo, MENOS trafego no servidor (isso é bom). 

Sys.sleep(5) 

temporada <- chrome$findElement(using = 'xpath', paste0('//*[@id="mainContent"]/div/div[1]/div/section/div[1]/ul/li[',i, ']'))
temporada$clickElement()


Sys.sleep(5)

last_height = 0 #
repeat {   
  chrome$executeScript("window.scrollTo(0,document.body.scrollHeight);")
  Sys.sleep(4) #delay by 4sec to give chance to load. 
  
  # Updated if statement which breaks if we can't scroll further 
  new_height = chrome$executeScript("return document.body.scrollHeight")
  Sys.sleep(5)
  if(unlist(last_height) == unlist(new_height)) {
    break
  } else {
    last_height = new_height
  }
}

cod_font <- htmlParse(chrome$getPageSource()[[1]], encoding = "utf-8")

ano <- xpathSApply(doc = cod_font, path = paste0('//*[@id="mainContent"]/div/div[1]/div/section/div[1]/ul/li[',i, ']'), fun = xmlValue)

jogador <- xpathSApply(cod_font, '//*[@id="mainContent"]/div/div[1]/div/div/table/tbody/tr/td[1]', xmlValue)
jogador

posicao <- xpathSApply(cod_font, '//*[@id="mainContent"]/div/div[1]/div/div/table/tbody/tr/td[2]', xmlValue)
posicao

pais <- xpathSApply(cod_font, '//*[@id="mainContent"]/div/div[1]/div/div/table/tbody/tr/td[3]', xmlValue)
pais

dados <- data.frame(ano, jogador, posicao, pais, stringsAsFactors = F)

jogadores <- rbind(jogadores, dados)

print(ano)

webElem <- chrome$findElement("css", "body")
webElem$sendKeysToElement(list(key = "home"))
Sys.sleep(3)

}

# Salvando os dados no pc

system("mkdir -p ./dados/brutos/")
jogadores <- saveRDS(jogadores, "./dados/brutos/jogadores.rds")
