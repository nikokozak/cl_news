import scrapy

class TerceraSpider(scrapy.Spider):
    name = "tercera"
    base_url = 'https://www.latercera.com'

    def start_requests(self):
        secciones = { 
                'Política': self.base_url + '/canal/politica/',
                'Nacional': self.base_url + '/canal/nacional/',
                'Tendencias': self.base_url + '/canal/tendencias/',
                'Mundo': self.base_url + '/canal/mundo',
                'Opinión': self.base_url + 'canal/opinion' 
                }

        for section, url in secciones:
            yield scrapy.Request(url=url, callback=self.parse)
    
    def parse(self, response):
        article_rel_links = response.xpath('//section[@class="middle-mainy"]//h3/a/@href').getall()
        for rel_link in article_rel_links:
            abs_link = self.base_url + rel_link
            yield scrapy.Request(url=abs_link, callback=self.parse_article)

    def parse_article(self, response):
        headline = response.xpath('//div[contains(@class, "titulares")]//h1//text()').get()
        author = response.xpath('//div[contains(@class, "titulares")]//div[@rel="author"]//text()').get()
        image = response.xpath('//div[@class="main-figure"]//img/@src')
        excerpt = response.xpath('//p[@class="excerpt"]/text()').get()
        body = response.xpath('//p[contains(@class, "paragraph")]').getall()
        published = response.xpath('//time/@datetime').get()

        yield {
                "headline": headline,
                "author": author,
                "image": image,
                "excerpt": excerpt,
                "body": body,
                "published": published
                }

class BioBioSpider(scrapy.Spider):
    name = "biobio"
    base_url = 'https://www.biobiochile.cl'









