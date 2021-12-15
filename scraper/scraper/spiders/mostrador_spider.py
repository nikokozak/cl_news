import scrapy, re, datetime
from scraper.spiders.site_rules import mostrador
from scraper.spiders.base_spider import NoticiaSpider
from scraper.items import NoticiaItem, NoticiaLoader

class MostradorSpider(NoticiaSpider):
    name = mostrador['name']
    base_url = mostrador['base_url']

    def start_requests(self):
        if self.clear_cache: self.cache.clear()

        self.stats.set_value('time_start', datetime.datetime.now())
        self.stats.set_value('spider_name', self.name)
        self.stats.set_value('parse_limit', self.limit)

        for section, url in mostrador['sections'].items():
            self.stats.get_value('sections_scraped', []).append(section)
            yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))

    def parse(self, response, section):
        limit_count = 0
        article_abs_links = response.xpath(mostrador['article_links'].get(section) or mostrador['article_links']['default']).getall()
        self.stats.set_value(section + '_links', len(article_abs_links))

        for abs_link in article_abs_links:
            if not self.cache.unique(abs_link) and limit_count < self.limit:
                limit_count += 1
                self.stats.inc_value(section + '_articles_requested')
                yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    def parse_article(self, response, section):
        self.stats.inc_value(section + '_articles_started')

        rules = mostrador['rules'].get(section) or mostrador['rules']['default']
        l = NoticiaLoader(item=NoticiaItem(), response=response)

        l.add_value('medio', mostrador['name'])
        l.add_value('seccion', section)
        l.add_xpath('titular', rules['titular'])
        l.add_xpath('bajada', rules['bajada'])
        l.add_xpath('autor', rules['autor'])
        l.add_xpath('imagen_url', rules['image_url'])
        l.add_xpath('cuerpo', rules['cuerpo'])
        l.add_value('url', response.url)
        l.add_xpath('fecha', rules['fecha'])

        yield l.load_item()
