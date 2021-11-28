import scrapy
from scraper.spiders.site_rules import tercera
from scraper.spiders.base_spider import NoticiaSpider
from scraper.items import NoticiaItem, NoticiaLoader

class TerceraSpider(NoticiaSpider):
    name = tercera['name']
    base_url = tercera['base_url']

    def start_requests(self):
        if self.clear_cache: self.clear_cache

        for section, url in tercera['sections'].items():
            yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))
   
    def parse(self, response, section):
        limit_count = 0
        article_rel_links = response.xpath(tercera['article_links']).getall()

        for rel_link in article_rel_links:
            abs_link = self.base_url + rel_link
            if not self.cache.unique(abs_link) and limit_count < self.limit:
                limit_count += 1
                yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    def parse_article(self, response, section):
        rules = tercera['article']
        l = NoticiaLoader(item=NoticiaItem(), response=response)

        l.add_value('medio', tercera['name'])
        l.add_value('seccion', section)
        l.add_xpath('titular', rules['titular'])
        l.add_xpath('bajada', rules['bajada'])
        l.add_xpath('autor', rules['autor'])
        l.add_xpath('image_url', rules['image_url'])
        l.add_xpath('cuerpo', rules['cuerpo'])
        l.add_xpath('fecha', rules['fecha'])

        yield l.load_item() 
