import scrapy, json, datetime, re
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
        # These are returned as a JSON dump, 6 articles at a time. We load
        # the JSON and navigate it to extract values.
        if section in ['nacional', 'internacional', 'tecnologia', 'educacion']:
            return self.parse_json_dump(response, section)
        else:
            return self.dispatch_to_article_parser(response, section)

    def dispatch_to_article_parser(self, response, section):
        limit_count = 0
        article_rel_links = response.xpath(emol['article_links']).getall()

        for rel_link in article_rel_links:
            abs_link = self.base_url + rel_link
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
        l.add_xpath('imagen_url', rules['imagen_url'])
        l.add_value('cuerpo', self.sanitize_body(response, rules['cuerpo']))
        l.add_xpath('fecha', rules['fecha'])
        l.add_value('url', response.url)

        yield l.load_item()

    def parse_json_dump(self, response, section):
        articles_dump = json.loads(response.body)
        for article_dump in articles_dump["hits"]["hits"]:
            article = article_dump["_source"]
            l = NoticiaLoader(item=NoticiaItem(), response=response)
            l.add_value('medio', emol['name'])
            l.add_value('seccion', section)
            l.add_value('titular', article["titulo"])
            l.add_value('bajada', article["bajada"][0]["texto"])
            l.add_value('autor', article["fuente"])
            if len(article["tablas"]["tablaMedios"]) > 0:
                l.add_value('imagen_url', article["tablas"]["tablaMedios"][0]["Url"])
            else:
                l.add_value('imagen_url', None)
            l.add_value('cuerpo', self.sanitize_body_text(article["texto"]))
            l.add_value('fecha', self.parse_date(article["fechaPublicacion"]))
            l.add_value('url', article["permalink"])
            yield l.load_item()

    def sanitize_body(self, response, rule):
        cuerpo = response.xpath(rule).getall()
        return map(self.sanitize_body_text, cuerpo)

    def sanitize_body_text(self, text):
        return re.sub(r'{.*}', "", text)

    def parse_date(self, strdate):
        strdate = strdate + "UTC-0400"
        return datetime.datetime.strptime(strdate, '%Y-%m-%dT%H:%M:%S%Z%z')
