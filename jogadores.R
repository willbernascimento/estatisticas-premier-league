## -------------------------------------------------------------------------- ##
## WebScraping do site da Premier League
## Desenvolvedor: Willber Nascimento <nascimentowillber at gmail dot com>
## -------------------------------------------------------------------------- ##


# coleta: jogadores

chrome <- remoteDriver(browserName="chrome", port=4567) # pode trocar por "firefox" e o valor de port é encontrado no seu terminal com o cat(selServ)
chrome$open() # abrir navegador

# indicar a URL
baseurl <- 'https://www.premierleague.com/players'
chrome$navigate(baseurl)

Sys.sleep(2)

bt_cookies <- chrome$findElement(using = 'xpath','/html/body/section/div/div')
bt_cookies$clickElement()

dados1 <- NULL

for (i in 1:11) {
  

drop <- chrome$findElement(using = 'xpath', '//*[@id="mainContent"]/div/div[1]/div/section/div[1]/div[2]')
drop$clickElement()

#//*[@id="mainContent"]/div/div[1]/div/section/div[1]/ul/li[11] # 08/09
#//*[@id="mainContent"]/div/div[1]/div/section/div[1]/ul/li[2]  # 17/18
#//*[@id="mainContent"]/div/div[1]/div/section/div[1]/ul/li[1]  # 18/19
Sys.sleep(2)

temporada <- chrome$findElement(using = 'xpath', paste0('//*[@id="mainContent"]/div/div[1]/div/section/div[1]/ul/li[',i, ']'))
temporada$clickElement()


Sys.sleep(2)

last_height = 0 #
repeat {   
  chrome$executeScript("window.scrollTo(0,document.body.scrollHeight);")
  Sys.sleep(4) #delay by 3sec to give chance to load. 
  
  # Updated if statement which breaks if we can't scroll further 
  new_height = chrome$executeScript("return document.body.scrollHeight")
  Sys.sleep(4)
  if(unlist(last_height) == unlist(new_height)) {
    break
  } else {
    last_height = new_height
  }
}

cod_font <- htmlParse(chrome$getPageSource()[[1]], encoding = "utf-8")

ano <- i

jogador <- xpathSApply(cod_font, '//*[@id="mainContent"]/div/div[1]/div/div/table/tbody/tr/td[1]', xmlValue)
jogador

posicao <- xpathSApply(cod_font, '//*[@id="mainContent"]/div/div[1]/div/div/table/tbody/tr/td[2]', xmlValue)
posicao

pais <- xpathSApply(cod_font, '//*[@id="mainContent"]/div/div[1]/div/div/table/tbody/tr/td[3]', xmlValue)
pais

dados <- data.frame(ano, jogador, posicao, pais, stringsAsFactors = F)

dados1 <- rbind(dados1, dados)

print(i)

webElem <- chrome$findElement("css", "body")
webElem$sendKeysToElement(list(key = "home"))
Sys.sleep(1)
#webElem$sendKeysToElement(list(key = "home"))

}

bd_jogadores <- dados1
