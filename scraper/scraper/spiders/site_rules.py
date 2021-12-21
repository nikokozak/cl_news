tercera = {
    'name': 'tercera',
    'base_url': 'https://www.latercera.com',

    'sections': {
        'politica': 'https://www.latercera.com/canal/politica/',
        'nacional': 'https://www.latercera.com/canal/nacional/',
        'tendencias': 'https://www.latercera.com/canal/tendencias/',
        'internacional': 'https://www.latercera.com/canal/mundo',
        'opinion': 'https://www.latercera.com/canal/opinion'
    },

    'article_links': '//section[@class="middle-mainy"]//h3/a/@href',

    'article': {
        'titular': '//div[contains(@class, "titulares")]//h1//text()',
        'autor': '//div[contains(@class, "titulares")]//div[@rel="author"]//text()',
        'image_url': '//div[@class="main-figure"]//img/@src',
        'bajada': '//p[@class="excerpt"]/text()',
        'cuerpo': '//p[contains(@class, "paragraph")]',
        'fecha': '//time/@datetime'
    }
}

biobio = {
    'name': 'biobio',
    'base_url': 'https://www.biobiochile.cl',

    'sections': {
        'nacional': 'https://www.biobiochile.cl/lista/busca-2020/categorias/nacional',
        'internacional': 'https://www.biobiochile.cl/lista/busca-2020/categorias/internacional',
        'economia': 'https://www.biobiochile.cl/lista/busca-2020/categorias/economia',
        'tendencias': 'https://www.biobiochile.cl/lista/busca-2020/categorias/tendencias',
        'opinion': 'https://www.biobiochile.cl/lista/busca-2020/categorias/opinion',
    },

    'article_links': '//section[contains(@class, "section-busca")]//div[@class="results"]/article/a/@href',

    'article': {
        'titular': 'normalize-space(//*[self::h1[@class="post-title" or @class="nota-title"] or self::h2[@class="titulo"]]/text())',
        'bajada': '//div[@class="post-excerpt" or @class="extracto-nota"]/p//text()',
        'autor': '//a[@class="autor-link"]/text()',
        'image_url': '//meta[@property="og:image"]/@content',
        'cuerpo': '//div[contains(@class, "contenido-nota") or contains(@class, "nota-content") and not(contains(@class, "d-lg-none"))]/*[self::p or self::h1 or self::h2]',
        'fecha': '//meta[@property="article:published_time"]/@content'
    }
}

emol = {
    'name': 'emol',
    'base_url': 'https://www.emol.com',

    'sections': {
        'nacional': 'https://cache-elastic-pandora.ecn.cl/emol/noticia/_search?q=publicada:true+AND+ultimoMinuto:true+AND+seccion:nacional+AND+idSubSeccion:*+AND+temas.id:*+NOT+id:1040394+NOT+id:1040385&sort=fechaModificacion:desc&size=6&from=0',
        'internacional': 'https://cache-elastic-pandora.ecn.cl/emol/noticia/_search?q=publicada:true+AND+ultimoMinuto:true+AND+seccion:internacional+AND+idSubSeccion:*+AND+temas.id:*+NOT+id:1040524+NOT+id:1040482&sort=fechaModificacion:desc&size=6&from=0',
        'tecnologia': 'https://cache-elastic-pandora.ecn.cl/emol/noticia/_search?q=publicada:true+AND+ultimoMinuto:true+AND+seccion:tecnolog%C3%ADa+AND+idSubSeccion:*+AND+temas.id:*+NOT+id:1034027+NOT+id:1033962&sort=fechaModificacion:desc&size=6&from=0',
        'educacion': 'https://cache-elastic-pandora.ecn.cl/emol/noticia/_search?q=publicada:true+AND+temas.id:79+OR+temas.id:109+NOT+id:1021974&sort=fechaModificacion:desc&size=6&from=0',
        'economia': 'https://www.emol.com/economia/',
        'tendencias': 'https://www.emol.com/tendencias/',
    },

    'article_links': '//div[contains(@class, "col_center_noticia")]/*[self::h1 or self::h3]/a/@href',

    'article': {
        'titular': '//h1[contains(@id, "tituloNoticia")]/text()',
        'bajada': '//h2[contains(@id, "bajadaNoticia")]/text()',
        'autor': '//div[@id="barra-agencias-info"]//a/text()',
        'imagen_url': '//img[@id="cuDetalle_cuTexto_ucImagen_Img"]/@src',
        'cuerpo': '//div[@class="EmolText"]//div[text()] | //div[@class="EmolText"]/div/h2[text()]',
        'fecha': '//meta[@name="DC.date"]/@content'
    }
}

mostrador = {
    'name': 'mostrador',
    'base_url': 'https://www.elmostrador.cl',

    'sections': {
        'nacional': 'https://www.elmostrador.cl/noticias/pais/',
        'internacional': 'https://www.elmostrador.cl/noticias/mundo/',
        'opinion': 'https://www.elmostrador.cl/noticias/opinion/'
    },

    'article_links': {
        'default': '//section[contains(@class, "lo-ultimo")]/article//a/@href',
        'opinion': '//div[contains(@class, "columnas-posteo")]/article//h4/a/@href'
    },

    'rules': {
        'default': {
            'titular': '//h2[@class="titulo-single"]/text()',
            'autor': '//something',
            'image_url': '//article/figure/img[1]/@src',
            'bajada': '//figcaption/text()',
            'cuerpo': '//div[@id="noticia"]/p[text()]',
            'fecha': '//meta[@property="article:published_time"]/@content'
        },
        'opinion': {
            'titular': '//section[contains(@class, "datos-noticias")]//h2/text()',
            'autor': '//a[@rel="author"]/text()',
            'image_url': '//article/figure/img[1]/@src',
            'bajada': '//figcaption/text()',
            'cuerpo': '//div[@id="noticia"]/p',
            'fecha': '//meta[@property="article:published_time"]/@content'
        }
    }
}
