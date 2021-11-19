import scrapy

class TerceraSpider(scrapy.Spider):
    name = "tercera"
    base_url = 'https://www.latercera.com'

    def start_requests(self):
        secciones = { 
                'Política': self.base_url + '/canal/politica/',
                'Nacional': self.base_url + '/canal/nacional/',
                'Tendencias': self.base_url + '/canal/tendencias/',
                'Internacional': self.base_url + '/canal/mundo',
                'Opinión': self.base_url + 'canal/opinion' 
                }

        for section, url in secciones.items():
            yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))
    
    def parse(self, response, section):
        article_rel_links = response.xpath('//section[@class="middle-mainy"]//h3/a/@href').getall()
        for rel_link in article_rel_links:
            abs_link = self.base_url + rel_link
            yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    def parse_article(self, response, section):
        headline = response.xpath('//div[contains(@class, "titulares")]//h1//text()').get()
        author = response.xpath('//div[contains(@class, "titulares")]//div[@rel="author"]//text()').get()
        image = response.xpath('//div[@class="main-figure"]//img/@src')
        excerpt = response.xpath('//p[@class="excerpt"]/text()').get()
        body = response.xpath('//p[contains(@class, "paragraph")]').getall()
        published = response.xpath('//time/@datetime').get()

        yield {
                "section": section,
                "headline": headline,
                "author": author,
                "image": image,
                "excerpt": excerpt,
                "body": body,
                "published": published
                }

class BioBioSpider(scrapy.Spider):
    name = "biobio"
    base_url = "https://www.biobiochile.cl"

    def start_requests(self):
        secciones = {
                'Nacional': self.base_url + '/lista/busca-2020/categorias/nacional',
                'Internacional': self.base_url + '/lista/busca-2020/categorias/internacional',
                'Economía': self.base_url + '/lista/busca-2020/categorias/economia',
                'Tendencias': self.base_url + '/lista/busca-2020/categorias/tendencias',
                'Opinión': self.base_url + '/lista/busca-2020/categorias/opinion',
                }

        for section, url in secciones.items():
            yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))

    def parse(self, response, section):
        article_abs_links = response.xpath('//section[contains(@class, "section-busca")]//div[@class="results"]/article/a/@href').getall()

        for abs_link in article_abs_links:
            yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    def parse_article(self, response, section):
        headline = response.xpath('//h1[@class="post-title" or @class="nota-title"]/text()').get()
        author = response.xpath('//a[@class="autor-link"]/text()').get()
        image = response.xpath('//meta[@property="og:image"]/@content').get()
        excerpt = response.xpath('//div[@class="post-excerpt"]/p//text()').getall() or response.xpath('//div[@class="extracto-nota"]/p//text()').getall()
        body = response.xpath('//div[contains(@class, "contenido-nota") or contains(@class, "nota-content")]/*[self::p or self::h1]//text()').getall()
        published = response.xpath('//meta[@property="article:published_time"]/@content').get()

        yield {
                "section": section,
                "headline": headline,
                "author": author,
                "image": image,
                "excerpt": excerpt,
                "body": body,
                "published": published
                }

class EmolScraper(scrapy.Spider):
    name = "emol"
    base_url = "https://www.emol.com"

    def start_requests(self):
        secciones = {
                'Nacional': self.base_url + '/nacional/',
                'Economía': self.base_url + '/economia/',
                'Educación': self.base_url + '/educacion/',
                'Tendencias': self.base_url + '/tendencias/'
                }

