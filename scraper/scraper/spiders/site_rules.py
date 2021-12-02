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
            'titular': 'normalize-space(//h1[@class="post-title" or @class="nota-title"]/text())',
            'bajada': '//div[@class="post-excerpt" or @class="extracto-nota"]/p//text()',
            'autor': '//a[@class="autor-link"]/text()',
            'image_url': '//meta[@property="og:image"]/@content',
            'cuerpo': '//div[contains(@class, "contenido-nota") or contains(@class, "nota-content")]/*[self::p or self::h1 or self::h2]',
            'fecha': '//meta[@property="article:published_time"]/@content'
           }
        }
