import scrapy, json, datetime, re
from scrapy import Selector
from scraper.spiders.site_rules import emol
from scraper.spiders.base_spider import NoticiaSpider
from scraper.items import NoticiaItem, NoticiaLoader

class BioBioSpider(NoticiaSpider):
    name = emol['name']
    base_url = emol['base_url']

    def start_requests(self):
        if self.clear_cache: self.cache.clear()

        self.stats.set_value('time_start', datetime.datetime.now())
        self.stats.set_value('spider_name', self.name)
        self.stats.set_value('parse_limit', self.limit)

        for section, url in emol['sections'].items():
            self.stats.get_value('sections_scraped', []).append(section)
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
        self.stats.set_value(section + '_links', len(article_rel_links))

        for rel_link in article_rel_links:
            abs_link = self.base_url + rel_link
            if not self.cache.unique(abs_link) and limit_count < self.limit:
                limit_count += 1
                self.stats.inc_value(section + '_articles_requested')
                yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    def parse_article(self, response, section):
        self.stats.inc_value(section + '_articles_started')

        rules = emol['article']
        l = NoticiaLoader(item=NoticiaItem(), response=response)

        l.add_value('medio', emol['name'])
        l.add_value('seccion', section)
        l.add_xpath('titular', rules['titular'])
        l.add_xpath('bajada', rules['bajada'])
        l.add_xpath('autor', rules['autor'])
        l.add_xpath('imagen_url', rules['imagen_url'])
        l.add_value('cuerpo', self.sanitize_body(response, rules['cuerpo']))
        # add timezone info to EMOL scrape-derived date
        datetime = self.add_tz(response.xpath(rules['fecha']).get())
        #l.add_xpath('fecha', rules['fecha'])
        l.add_value('fecha', datetime)
        l.add_value('url', response.url)

        yield l.load_item()

    def parse_json_dump(self, response, section):
        self.stats.inc_value(section + '_json_dump_started')

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
            l.add_value('fecha', self.add_tz(article["fechaPublicacion"]))
            l.add_value('url', article["permalink"])

            # Skip this item if it's a multimedia item
            if (article["fuente"] == "Por Equipo Multimedia Emol"):
                return
            else:
                yield l.load_item()

    def sanitize_body(self, response, rule):
        cuerpo = response.xpath(rule).getall()
        return map(self.sanitize_body_text, cuerpo)

    def sanitize_body_text(self, text):
        return re.sub(r'{.*}', "", text)

    def add_tz(self, strdate):
        return strdate + ' America/Santiago'
