import scrapy, json, datetime
from scraper.spiders.site_rules import emol
from scraper.spiders.base_spider import NoticiaSpider
from scraper.items import NoticiaItem, NoticiaLoader

class BioBioSpider(NoticiaSpider):
    name = emol['name']
    base_url = emol['base_url']

    def start_requests(self):
        if self.clear_cache: self.cache.clear()

        for section, url in emol['sections'].items():
            yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))

    def parse(self, response, section):
        if section in ['nacional', 'internacional', 'tecnologia', 'educacion']:
            articles_dump = json.loads(response.body)
            for article_dump in articles_dump["hits"]["hits"]:
                article = article_dump["_source"]
                l = NoticiaLoader(item=NoticiaItem(), response=response)
                l.add_value('medio', emol['name'])
                l.add_value('seccion', section)
                l.add_value('titular', article["titulo"])
                l.add_value('bajada', article["bajada"][0]["texto"])
                l.add_value('autor', article["fuente"])
                l.add_value('imagen_url', article["tablas"]["tablaMedios"][0]["Url"])
                l.add_value('cuerpo', article["texto"])
                l.add_value('fecha', self.parse_date(article["fechaPublicacion"]))
                yield l.load_item()
        else:
            limit_count = 0
            article_abs_links = response.xpath(emol['article_links']).getall()

            for abs_link in article_abs_links:
                if not self.cache.unique(abs_link) and limit_count < self.limit:
                    limit_count += 1
                    yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    def parse_article(self, response, section):
        rules = emol['article']
        l = NoticiaLoader(item=NoticiaItem(), response=response)

        l.add_value('medio', emol['name'])
        l.add_value('seccion', section)
        l.add_xpath('titular', rules['titular'])
        l.add_xpath('bajada', rules['bajada'])
        l.add_xpath('autor', rules['autor'])
        l.add_xpath('imagen_url', rules['image_url'])
        l.add_xpath('cuerpo', rules['cuerpo'])
        l.add_xpath('fecha', rules['fecha'])
        l.add_value('url', response.url)

        yield l.load_item()

    def parse_date(self, strdate):
        return datetime.datetime.strptime(strdate, '%Y-%m-%dT%H:%M:%S')
