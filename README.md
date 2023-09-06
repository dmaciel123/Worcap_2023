# Sensoriamento Remoto e programação aplicados à qualidade de água

O uso do sensoriamento remoto para estimativa de parâmetros de qualidade de água vem sendo feita para águas oceânicas e costeiras há pelo menos 50 anos. Graças a nova geração de sensores com resoluções adequadas (espectral, radiométrica, espacial e temporal) como o Landsat-8, Sentinel-2, CBERS-04A e Amazônia-1, a comunidade de sensoriamento remoto começou a poder utilizar este tipo de dado para aplicações aquáticas. Com o sensoriamento remoto conseguimos obter parâmetros de qualidade de água que são ópticamente ativos (ou seja, interagem com a radiação eletromagnética) como material em suspensão, concentração de pigmentos do fitoplancton, como a clorofila-a e ficocianina (presente em algas tóxicas), material orgânico dissolvido e transparência da água. É, sem dúvidas, uma importante fonte de dados que podem auxiliar biólogos, limnologistas, gestores ambientais e toda a comunidade preocupada com esse nosso importante bem que é a água.

Neste workshop, nós vamos aprender como utilizar o sensoriamento remoto para predizer um parâmetro de qualidade de água - Total de Sedimentos em Suspensão - em um dos principais lagos do Brasil, o Lago Guaíba, em Porto Alegre. Iremos utilizar dados gratuitos provenientes de colaborações globais (na qual o INPE participa) com dados de campo para desenvolver um modelo de aprendizagem de máquina (Random Forest) para a obtenção deste parâmetro. O foco será a utilização do sensor Landsat-8/OLI e os dados serão obtidos através do serviço STAC do Microsoft Planetary Computer. 


O fluxo de processamento é dividido em três etapas:

1. Instalação dos pacotes, download dos dados, simulação das bandas e preparação dos dados (remoção de outliers, cálculo de índices).
2. Desenvolvimento do modelo (Treinamento, validação e geração do modelo final)
3. Aplicação do modelo: aplicação dos algoritmos em imagens Landsat-8/OLI utilizando o STAC do Microsoft Planetary Computer

# O que nós esperamos como resultado??

1. Um modelo de Random Forest para estimar Sedimentos em Suspensão (TSS)
2. Uma predição para a concentração de TSS em uma data específica
3. Série temporal de TSS usando o serviço WTSS


![Figure 01](https://github.com/dmaciel123/HackingLimnology_RS_day/blob/main/animation.gif)

# Software requerido

Para rodar os scripts, é necessária a instalação do R e do RSTUDIO

O R pode ser baixado aqui: https://www.r-project.org/

O RSTUDIO (Agora chamado POSIT) pode ser baixado aqui: https://posit.co/download/rstudio-desktop/

# Pacotes necessários

Durante o workshop, iremos utilizar vários pacotes. Recomendamos instalar eles antes do workshop. 

```r

# Required packages

packages = c('data.table','dplyr','terra','mapview','httr','Metrics','geodrawr',
             'svDialogs','rstac','wesanderson','PerformanceAnalytics', 'remotes',
             'ggpmisc','gdalcubes','Metrics','randomForest','rasterVis','RColorBrewer')

install.packages(packages)

```

Nós também precisaremos baixar o pacote bandSimulation que está disponível no GitHub. Esse pacote serve para fazer simulação de bandas e será necessário no decorrer do curso. 

```r

devtools::install_github("dmaciel123/BandSimulation")

require(bandSimulation)

```



# Dados do GLORIA

O dataset que utilizaremos neste trabalho para gerar um modelo de Random Forest será o GLORIA. Este dataset é uma compilação global com dados de reflectância da água para águas do mundo todo, com mais de 7.000 pontos e o INPE é um dos colaboradores deste dataset. É gratuito e disponível para toda a comunidade (Figura 01).

Para mais informações, vejam a publicação: [(Lehmann et al. 2023)](https://www.nature.com/articles/s41597-023-01973-y). O dataset está disponível no [PANGAEA](http://https://doi.pangaea.de/10.1594/PANGAEA.948492) e também mais informações podem ser obtidas no [Nature Earth and Environmment blog post](http://https://earthenvironmentcommunity.nature.com/posts/gloria-challenges-in-developing-a-globally-representative-hyperspectral-in-situ-dataset-for-the-remote-sensing-of-water-resources)



![Figure 01](https://earthenvironmentcommunity.nature.com/cdn-cgi/image/metadata=copyright,fit=scale-down,format=auto,sharpen=1,quality=95/https://images.zapnito.com/uploads/hiCMOprnTtSCTJNv78gu_locations.jpg)

