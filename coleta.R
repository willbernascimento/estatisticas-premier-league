
library(RSelenium)
library(XML)
library(httr)
library(wdman)
library(electionsBR)
library(dplyr)

# criação de um servidor na máquina - isso poupa o R
selServ <- selenium(retcommand = TRUE, verbose = TRUE)
cat(selServ) # código para colar no terminal de comando e liberar o navegador.

# configure o navegador
chrome <- remoteDriver(browserName="chrome", port=4567) # pode trocar por "firefox" e o valor de port é encontrado no seu terminal com o cat(selServ)
chrome$open() # abrir navegador

# indicar a URL
baseurl <- 'https://www.premierleague.com/stats/top/players/goals?se=210'
chrome$navigate(baseurl)

Sys.sleep(5)

bt_cookies <- chrome$findElement(using = 'xpath','/html/body/section/div/div')
bt_cookies$clickElement()


dados1 <- NULL

for (i in 2:12) {

drop <- chrome$findElement(using = 'xpath', '//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[1]/div[2]')
drop$clickElement()

temporada <- chrome$findElement(using = 'xpath', paste0('//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[1]/ul/li[',i,']'))
temporada$clickElement()

cod_font <- htmlParse(chrome$getPageSource()[[1]], encoding = "utf-8")

ano <- xpathSApply(cod_font, '//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[1]/div[2]/text()', xmlValue)
ano

Sys.sleep(3)

for (i in 1:12) {

#//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[4]/ul/li[1]#all
#//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[4]/ul/li[2]#goalkeeper
#//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[4]/ul/li[3]#defender
#
#//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[4]/ul/li[4]#midfield
#//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[4]/ul/li[5]#foward

#bt_aplicar <- chrome$findElement('xpath', '//*[@id="mainContent"]/div/div/div[2]/div[1]/section/div[6]')
#bt_aplicar$clickElement()

cod_font <- htmlParse(chrome$getPageSource()[[1]], encoding = "utf-8")

rank <- xpathSApply(cod_font,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[1]', xmlValue)
rank

jogador <- xpathSApply(cod_font,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[2]', xmlValue)
jogador

clube <- xpathSApply(cod_font,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[3]', xmlValue)
clube

pais <- xpathSApply(cod_font,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[4]', xmlValue)
pais

score <- xpathSApply(cod_font,  '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[2]/table/tbody/tr/td[5]', xmlValue)
score

dados <- data.frame(ano,rank, jogador,clube, pais, score, stringsAsFactors = F)

dados1 <- rbind(dados1, dados)

#

bt_pagina <- chrome$findElement(using = 'xpath', '//*[@id="mainContent"]/div/div/div[2]/div[1]/div[3]/div[2]')
bt_pagina$clickElement()

# volta pro cod_font
Sys.sleep(3)
print(i)
webElem <- chrome$findElement("css", "body")
webElem$sendKeysToElement(list(key = "home"))
Sys.sleep(3)
}

webElem <- chrome$findElement("css", "body")
webElem$sendKeysToElement(list(key = "home"))
Sys.sleep(2)

}

