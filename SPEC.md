# La Tercera:

## Secciones
    - Política (https://www.latercera.com/canal/politica/)
    - Nacional (https://www.latercera.com/canal/nacional/)
    - Tendencias (https://www.latercera.com/canal/tendencias/)
    - Mundo (https://www.latercera.com/canal/mundo/)
    - Opinion (https://www.latercera.com/canal/opinion/)

## Selectores
### Article List:
    - res = response.xpath('//section[@class="middle-mainy"]/div[contains(@class,"archive-list")]/article/div')
        #### In Article:
            a. Headline: //div[contains(@class, "titulares")]//h1//text()
            b. Author: //div[contains(@class, "titulares")]//div[@rel="author"]//text()
            c. Image: //div[@class="main-figure"]//img/@src
            d. Excerpt: response.xpath('//p[@class="excerpt"]/text()').get()
            e. Body: response.xpath('//p[contains(@class, "paragraph")]').getall()
            f. Published: response.xpath('//time/@datetime').get()

# Bio Bio Chile:

## Secciones:
    - Nacional (https://www.biobiochile.cl/lista/busca-2020/categorias/nacional)
    - Internacional (https://www.biobiochile.cl/lista/busca-2020/categorias/internacional)
    - Economia (https://www.biobiochile.cl/lista/busca-2020/categorias/economia)
    - Tendencias (https://www.biobiochile.cl/lista/busca-2020/categorias/tendencias)
    - Opinion (https://www.biobiochile.cl/lista/busca-2020/categorias/opinion)
    - BBCL Investiga (https://www.biobiochile.cl/especial/bbcl-investiga)

## Selectores
### Article List:
    - res = response.xpath('//section[contains(@class, "section-busca")]/div[@class="section-body"]//article')
        #### In Article:
            a. Headline: response.xpath('//h1[@class="post-title"]')
            d. Author: response.xpath('//a[@class="autor-link"]/text()')
            c. Image: response.xpath('//meta[@property="og:image"]/@content')
            d. Excerpt: response.xpath('//div[@class="extracto-nota"]/p//text()').getall()
            e. Body: response.xpath('//div[contains(@class, "contenido-nota")]/*[self::p or self::h1]//text()')

            f. Published: response.xpath('//meta[@property="article:published_time"]/@content').get()

# El Mercurio:

## Secciones:
    - Nacional (https://www.emol.com/nacional/)
    - Economia (https://www.emol.com/economia/noticias/)
    - Educación (https://www.emol.com/educacion/)
    - Tendencias (https://www.emol.com/tendencias/)

## Selectores:
    - Nacional = (JSON (ultimo minuto)) https://cache-elastic-pandora.ecn.cl/emol/noticia/_search?q=publicada:true+AND+ultimoMinuto:true+AND+seccion:nacional+AND+idSubSeccion:*+AND+temas.id:*&sort=fechaModificacion:desc&size=6&from=0 /_
    - Economia res = response.xpath('//div[@id="col_center_420px"]/div')
        1. Headline: articles.xpath('./*[self::h1 or self::h3]//text()')
        2. Excerpt: articles.xpath('./p/text()')
        #### In Article:
            a. Body: response.xpath('//div[@class="EmolText"]//*[self::div or self::b]/text()').getall()
            b. Image: response.xpath('//img[@id="cuDetalle_cuTexto_ucImagen_Img"]/@src').get()
            c. Published: response.xpath('//meta[@property="article:published_time"]/@content').get()
            d. Writer: response.xpath('//div[@class="info-notaemol-porfecha"]/a/text()').get()

# Ciper Chile:

## Secciones:
    - Investigacion (https://www.ciperchile.cl/investigacion/)
    - Actualidad (https://www.ciperchile.cl/actualidad/)
    - Opinion (https://www.ciperchile.cl/debate/opinion/)

# The Clinic:

## Secciones:
    - Politica (https://www.theclinic.cl/categoria/politica/)
    - Humor (https://www.theclinic.cl/categoria/humor/)
    - Entrevista (https://www.theclinic.cl/categoria/entrevista-canalla/)
    - Virales (https://www.theclinic.cl/categoria/virales/)
    - Actualidad (https://www.theclinic.cl/categoria/actualidad/)



