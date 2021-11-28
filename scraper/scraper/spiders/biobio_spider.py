import scrapy
from scraper.spiders.rules import biobio
from scraper.spiders.base_spider import NoticiaSpider
from scraper.items import NoticiaItem, NoticiaLoader

class BioBioSpider(NoticiaSpider):
    name = biobio['name']
    base_url = biobio['base_url']

    def start_requests(self):
        if self.clear_cache: self.cache.clear()

        for section, url in biobio['sections'].items():
            yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))

    def parse(self, response, section):
        limit_count = 0
        article_abs_links = response.xpath(biobio['article_links']).getall()

        for abs_link in article_abs_links:
            if not self.cache.unique(abs_link) and limit_count < self.limit:
                limit_count += 1
                yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    def parse_article(self, response, section):
        rules = biobio['article']
        l = NoticiaLoader(item=NoticiaItem(), response=response)

        l.add_value('medio', biobio['name'])
        l.add_value('seccion', section)
        l.add_xpath('titular', rules['titular'])
        l.add_xpath('bajada', rules['bajada'])
        l.add_xpath('autor', rules['autor'])
        l.add_xpath('image_url', rules['image_url'])
        l.add_xpath('cuerpo', rules['cuerpo'])
        l.add_xpath('fecha', rules['fecha'])

        yield l.load_item()

