tercera = {
        'name': 'tercera',
        'base_url': 'https://www.latercera.com',

        'sections': {
            'Política': 'https://www.latercera.com/canal/politica/',
            'Nacional': 'https://www.latercera.com/canal/nacional/',
            'Tendencias': 'https://www.latercera.com/canal/tendencias/',
            'Internacional': 'https://www.latercera.com/canal/mundo',
            'Opinión': 'https://www.latercera.com/canal/opinion' 
            },

        'article_links': lambda r: r.xpath('//section[@class="middle-mainy"]//h3/a/@href').getall(),

        'article': {
            'headline': lambda r: r.xpath('//div[contains(@class, "titulares")]//h1//text()').get(),
            'author': lambda r: r.xpath('//div[contains(@class, "titulares")]//div[@rel="author"]//text()').get(),
            'image': lambda r: r.xpath('//div[@class="main-figure"]//img/@src').get(),
            'excerpt': lambda r: r.xpath('//p[@class="excerpt"]/text()').get(),
            'body': lambda r: r.xpath('//p[contains(@class, "paragraph")]').getall(),
            'published': lambda r: r.xpath('//time/@datetime').get()
            }
        }

biobio = {
        'name': 'biobio',
        'base_url': 'https://www.biobiochile.cl',

        'sections': {
            'Nacional': 'https://www.biobiochile.cl/lista/busca-2020/categorias/nacional',
            'Internacional': 'https://www.biobiochile.cl/lista/busca-2020/categorias/internacional',
            'Economía': 'https://www.biobiochile.cl/lista/busca-2020/categorias/economia',
            'Tendencias': 'https://www.biobiochile.cl/lista/busca-2020/categorias/tendencias',
            'Opinión': 'https://www.biobiochile.cl/lista/busca-2020/categorias/opinion',
            },

        'article_links': lambda r: r.xpath('//section[contains(@class, "section-busca")]//div[@class="results"]/article/a/@href').getall(),

        'article': {
            'headline': lambda r: r.xpath('normalize-space(//h1[@class="post-title" or @class="nota-title"]/text())').get(),
            'author': lambda r: r.xpath('//a[@class="autor-link"]/text()').get(),
            'image': lambda r: r.xpath('//meta[@property="og:image"]/@content').get(),
            'excerpt': lambda r: r.xpath('//div[@class="post-excerpt"]/p//text()').getall() or r.xpath('//div[@class="extracto-nota"]/p//text()').getall(),
            'body': lambda r: r.xpath('//div[contains(@class, "contenido-nota") or contains(@class, "nota-content")]/*[self::p or self::h1]//text()').getall(),
            'published': lambda r: r.xpath('//meta[@property="article:published_time"]/@content').get()
           }
        }
