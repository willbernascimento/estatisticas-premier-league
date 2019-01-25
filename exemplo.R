### COLETANDO ORGÃOS PARTIDÁRIOS 

### PACOTES

# Podem existir depências que precisem ser instaladas separadamente para a instalçao do 'RSelenium'
# install.packages(c("xml2", "XML", "binman", "httr","openssl","curl", "wdman")) # alguns desses precisei instalar no computador e não no R (openssl)
# É também necessário o JDK - Java (o open JDK8 funcionou perfeitamente)

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


# baixar lista de partidos e municipios

infoPartidos <- legend_local(2016)
infoPartidos <- unique(infoPartidos[, c(6:8)]) # filtrando todos os municípios 5568

# indicar a URL
baseurl <- "http://inter01.tse.jus.br/sgipweb/"
chrome$navigate(baseurl)

# botão do orgão partidário
orgpart <- chrome$findElement(using = "xpath", "/html/body/form/table[1]/tbody/tr[5]/td/a") # inspecionar elemento e copiar xpath
orgpart$clickElement() # clicar no botão

  
# codigo fonte da página para coletar os codigos dos partidos e da UF
cod_font <- htmlParse(chrome$getPageSource()[[1]], encoding = "utf-8")

# o TSE tem codigos para cada partido para buscar na página

codPartidosTse <- xpathSApply(cod_font, '/html/body/form/table[1]/tbody/tr[2]/td[2]/select/option', xmlValue)
codigos <- data.frame(codPartidosTse, stringsAsFactors = F)
codigos$id <- 1:37 # todos os codigo

codigos$SIGLA_PARTIDO <- substr(codigos$codPartidosTse,1,7) # coletando carcteres

# limpando nome dos partidos para um merge com base do TSE eleições
codigos$SIGLA_PARTIDO <- gsub(" - D", "", codigos$SIGLA_PARTIDO)
codigos$SIGLA_PARTIDO <- gsub(" - PA","",codigos$SIGLA_PARTIDO)
codigos$SIGLA_PARTIDO <- gsub(" - P","",codigos$SIGLA_PARTIDO)
codigos$SIGLA_PARTIDO <- gsub(" - SO","",codigos$SIGLA_PARTIDO)
codigos$SIGLA_PARTIDO <- gsub(" - ", "", codigos$SIGLA_PARTIDO)

codigos <- codigos[-c(1:2),] # retirar os codigos que não são dos partidos
infoPartidos <- merge(infoPartidos, codigos) # juntar com base de municipios 



# coletando UF
SIGLA_UF <- xpathSApply(cod_font, '//*[@id="sgUeSup"]/option', xmlValue)
codigosUf <- data.frame(SIGLA_UF, stringsAsFactors = F)
codigosUf$iduf <- 1:28

# nova base adicionando a UF
infoPartidos2 <- merge(infoPartidos, codigosUf, by=c("SIGLA_UF"), all.x = T)

# Correções no nome de municípios OBS: só tem como saber executando a coleta

infoPartidos2$NOME_MUNICIPIO[infoPartidos2$NOME_MUNICIPIO=='PEDRA BRANCA DO AMAPARI'] <- 'AMAPARI'
infoPartidos2$NOME_MUNICIPIO[infoPartidos2$NOME_MUNICIPIO=='LARANJAL DO JARI'] <- 'LARANJAL DO JARÍ'
infoPartidos2$NOME_MUNICIPIO[infoPartidos2$NOME_MUNICIPIO=='VITÓRIA DO JARI'] <- 'VITÓRIA DO JARÍ'
infoPartidos2$NOME_MUNICIPIO[infoPartidos2$NOME_MUNICIPIO=='SANTA ROSA DO PURUS'] <- 'SANTA ROSA'
infoPartidos2$NOME_MUNICIPIO[infoPartidos2$NOME_MUNICIPIO=='SÃO JOÃO DA BALIZA'] <- 'SÃO JOÃO DO BALIZA'

infoPartidos2$NOME_MUNICIPIO[infoPartidos2$NOME_MUNICIPIO=='SANTA ROSA DO PURUS'] <- 'SANTA ROSA'
infoPartidos2$NOME_MUNICIPIO[infoPartidos2$NOME_MUNICIPIO=='AMAJARI'] <- 'AMAJARÍ'


# Organizando a base por ordem de UF e Município: Necessário pq o TSE tem um código para cada
# município em seu site ordenado alfabeticamente para cada UF. 

infoPartidos2 <- infoPartidos2 %>%
  arrange(SIGLA_UF,NOME_MUNICIPIO)

a <- unique(infoPartidos2[,c(1:3)]) # únicos de UF, SIGLA_UE e NOME_MUNICIPIO

a <- a %>%
  group_by(SIGLA_UF)%>%
  mutate(codMunPopTSE = 1:length(SIGLA_UF)+2) # o primeiro município em cada estado sempre terá código 3

# junte as duas bases 
infoPartidos2 <- merge(infoPartidos2, a, by=c("SIGLA_UF", "SIGLA_UE", "NOME_MUNICIPIO"), all.x = T)

# reordene a base para que se colete na ordem 
infoPartidos2 <- infoPartidos2 %>%
  arrange(SIGLA_UF,NOME_MUNICIPIO,SIGLA_PARTIDO)


######### LOOP ################################

# base onde se armazenará os dados de cada interação

dados1 <- NULL

# configure o navegador

chrome <- remoteDriver(browserName="chrome", port=4567) # pode trocar por "firefox" e o valor de port é encontrado no seu terminal com o cat(selServ)
chrome$open() # abrir navegador

baseurl <- "http://inter01.tse.jus.br/sgipweb/" # página de coleta

for (i in 1:nrow(infoPartidos2)){

chrome$navigate(baseurl) # 
  
# Criando cliques - botões
chrome$setImplicitWaitTimeout(20000)  
# botão do orgão partidário
orgpart <- chrome$findElement(using = "xpath", "/html/body/form/table[1]/tbody/tr[5]/td/a") # inspecionar elemento e copiar xpath
chrome$setImplicitWaitTimeout(20000)
orgpart$clickElement() # clicar no botão


# botão partido + loop dentro
chrome$setImplicitWaitTimeout(20000)
partido <- chrome$findElement(using = "xpath", paste0('/html/body/form/table[1]/tbody/tr[2]/td[2]/select/option[',infoPartidos3[i,7],']'))
chrome$setImplicitWaitTimeout(20000)
partido$clickElement()

# botão abrangência
chrome$setImplicitWaitTimeout(20000)
abrangencia <- chrome$findElement(using = "xpath", '//*[@id="dominio"]/option[4]')
chrome$setImplicitWaitTimeout(20000)
abrangencia$clickElement()

# botão UF
chrome$setImplicitWaitTimeout(20000)
uf <- chrome$findElement(using = "xpath", paste0('//*[@id="sgUeSup"]/option[', infoPartidos2[i,7],']'))
chrome$setImplicitWaitTimeout(20000)
uf$clickElement()

#### botão mais '+' para selecionar municipio
chrome$setImplicitWaitTimeout(20000)

mais <- chrome$findElement(using = "xpath", '//*[@id="pesquisarMunicipios"]/a/img')
chrome$setImplicitWaitTimeout(20000)

mais$clickElement() # click
chrome$setImplicitWaitTimeout(25000)

janela <- chrome$getWindowHandles() # procurar a identificação das janelas abertas
chrome$setImplicitWaitTimeout(20000)
chrome$switchToWindow(janela[[2]]) # mudar para essa janela
chrome$setImplicitWaitTimeout(25000)


# buscar municipio
m2 <- chrome$findElement(using = "xpath", '//*[@id="_filterText0"]') # caixa de busca dos municípios
chrome$setImplicitWaitTimeout(25000)
m2$sendKeysToElement(list(infoPartidos2[i,3])) # busque o município x
chrome$setImplicitWaitTimeout(25000)

# selecionar o município
ck <- chrome$findElement(using = "xpath", paste0('//*[@id="municipio"]/tbody/tr[',infoPartidos2[i,8], ']/td/a'))# botão para clicar na busca do pop up

chrome$setImplicitWaitTimeout(25000)
ck$clickElement() # clique no elemento m2 (Acrelândia). Por padrão ele fecha o pop up.

chrome$setImplicitWaitTimeout(30000)


# voltar para a janela principal
chrome$setImplicitWaitTimeout(20000)
chrome$switchToWindow(janela[[1]])

# botão pesquisar
chrome$setImplicitWaitTimeout(30000)
pesquisar <- chrome$findElement(using = "xpath", '/html/body/form/table[2]/tbody/tr/td/input[1]')
chrome$setImplicitWaitTimeout(30000)
pesquisar$clickElement()

chrome$setImplicitWaitTimeout(20000)
# coletar o código fonte da página
cod_font <- htmlParse(chrome$getPageSource()[[1]], encoding = "utf-8")

tamanho = length(xpathSApply(cod_font,path = '/html/body//tbody//td', fun = xmlValue)) # coletar o tamanho # 13 é o padrão para vazio

print(i)
print(infoPartidos3[i,])
if(tamanho < 14){
  print("tabela vazia")
} else{
  print("coletando dados...")
# coletar as variáveis de interesse

chrome$setImplicitWaitTimeout(20000)

nomePartido <- xpathSApply(cod_font,path = '/html/body/table[2]/tbody/tr/td[1]/a', fun = xmlValue) # partido político
nomePartido <- gsub("[\t; \n]", "", nomePartido)
nomePartido

#if(nomePartido > 0) {

linkNomePartido <- xpathSApply(cod_font, path = '/html/body/table[2]/tbody/tr/td[1]/a', xmlGetAttr, "href") # link do diretorio
linkNomePartido

linkNomePartido <- gsub("[\t; \n]", "", linkNomePartido)
linkNomePartido


tipoOrgao <-  xpathSApply(cod_font, path = '/html/body/table[2]/tbody/tr/td[2]/a', fun = xmlValue) # argumento 'td' é a posição da variável na tabela
linkTipoOrgao <- xpathSApply(cod_font, path = '/html/body/table[2]/tbody/tr/td[2]/a', xmlGetAttr, "href")
linkTipoOrgao <- gsub("[\t; \n]", "", linkTipoOrgao)
linkTipoOrgao


inicioVigencia <- xpathSApply(cod_font, path = '/html/body/table[2]/tbody/tr/td[3]', fun = xmlValue)
inicioVigencia <- inicioVigencia[2:length(inicioVigencia)]
inicioVigencia

fimVigencia <- xpathSApply(cod_font, path = '/html/body/table[2]/tbody/tr/td[4]', fun = xmlValue)
fimVigencia <- fimVigencia[2:length(fimVigencia)]
fimVigencia

nProtocolo <- xpathSApply(cod_font, path = '/html/body/table[2]/tbody/tr/td[5]', fun = xmlValue)
nProtocolo <- nProtocolo[2:length(nProtocolo)]
nProtocolo <- gsub("[\t; \n]", "", nProtocolo)
nProtocolo

situacao <- xpathSApply(cod_font, path = '/html/body/table[2]/tbody/tr/td[6]', fun = xmlValue)
situacao <- situacao[2:length(situacao)]
situacao

situacaoVigencia <- xpathSApply(cod_font, path = '/html/body/table[2]/tbody/tr/td[7]', fun = xmlValue)
situacaoVigencia <- situacaoVigencia[2:length(situacaoVigencia)]
situacaoVigencia


municipio <- xpathSApply(cod_font, path ='/html/body/table[2]/tbody/tr[1]/td', fun = xmlValue)
municipio <- gsub("Abrangência da consulta: Municipal - ", "", municipio)
#uf <- gsub("BUJARI  -  ", "", municipio)
#municipio <- gsub("  -  AC", "", municipio)

dados <- data.frame(municipio,
  nomePartido, linkNomePartido, tipoOrgao, linkTipoOrgao,
                    inicioVigencia, fimVigencia, nProtocolo, situacao, situacaoVigencia, stringsAsFactors = F)

dados1 <- rbind(dados1, dados)
}}

saveRDS(dados1, paste0('NC-', i,'.Rda'))

#
