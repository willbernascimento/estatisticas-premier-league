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

# O resultado esperado dos comandos dentro deste bloco é:
# 1: o navegador ser lançado e maximizado
# 2: o navegador carregar a página de interesse.
# 3: o botão de cookies ser apertado. 

# abrir navegador
chrome$open()
chrome$maxWindowSize()  

# indicar a URL
baseurl <- '<https://www.premierleague.com/players'
chrome$navigate(baseurl)

# tempo de carregamento da página

Sys.sleep(5)

# Vamos criar os botões para navergar na página solicitada

# Clicar em aceitar os cookies

bt_cookies <- chrome$findElement(using = 'xpath','/html/body/section/div/div')
bt_cookies$clickElement()

# Você já pode fechar o navegador 
chrome$close()

#------------------------------------------------------#


## -------------------------------------------------------------------------- ##
## ----------------------- BLOCO OPCIONAL ------------------------------------##

# Eu prefiro realizar a coleta sem a exibição do navegador. Neste momento isso
# só é possível utilizando a versão beta do chrome. Para funcionar é preciso 
# executar as linhas abaixo: 


capacidadesExtras <- list(
  browserName = 'chrome',
  chromeOptions = list(
    args = c('--headless', '--disable-gpu', '--window-size=1280,800'),
    binary = '/usr/bin/google-chrome-beta' # preciso indicar onde está o
    # executável do chrome-beta
  )
)

chrome <- remoteDriver(browserName="chrome", port=4567, 
                       extraCapabilities = capacidadesExtras) 

## -------------------------------------------------------------------------- ##




## ------------- INICIO DA COLETA ---------------------

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
