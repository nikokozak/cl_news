import scrapy, re, datetime
from scraper.spiders.site_rules import tercera
from scraper.spiders.base_spider import NoticiaSpider
from scraper.items import NoticiaItem, NoticiaLoader

class TerceraSpider(NoticiaSpider):
    name = tercera['name']
    base_url = tercera['base_url']
    fecha_reg = re.compile('\w+\s\w+\s\d+\s\d+\s\d+:\d+:\d+\sGMT[+-]\d+')

    def start_requests(self):
        if self.clear_cache: self.cache.clear()

        self.stats.set_value('time_start', datetime.datetime.now())
        self.stats.set_value('spider_name', self.name)
        self.stats.set_value('parse_limit', self.limit)

        for section, url in tercera['sections'].items():
            self.stats.get_value('sections_scraped', []).append(section)
            yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))

    def parse(self, response, section):
        limit_count = 0
        article_rel_links = response.xpath(tercera['article_links']).getall()
        self.stats.set_value(section + '_links', len(article_rel_links))

        for rel_link in article_rel_links:
            abs_link = self.base_url + rel_link
            if not self.cache.unique(abs_link) and limit_count < self.limit:
                limit_count += 1
                self.stats.inc_value(section + '_articles_requested')
                yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    def parse_article(self, response, section):
        self.stats.inc_value(section + '_articles_started')
        rules = tercera['article']
        l = NoticiaLoader(item=NoticiaItem(), response=response)

        l.add_value('medio', tercera['name'])
        l.add_value('seccion', section)
        l.add_xpath('titular', rules['titular'])
        l.add_xpath('bajada', rules['bajada'])
        l.add_xpath('autor', rules['autor'])
        l.add_xpath('imagen_url', rules['image_url'])
        l.add_xpath('cuerpo', rules['cuerpo'])
        l.add_value('url', response.url)
        l.add_value('fecha', self.sanitize_date(response, rules['fecha']))

        yield l.load_item()

    def sanitize_date(self, response, rule):
        '''If the extracted date matches La Tercera's incompatible date
        format, parse it into a correct Python datetime object
        '''
        fecha = response.xpath(rule).get()
        fecha_match = self.fecha_reg.match(fecha)

        if fecha_match:
            fecha_parsed = datetime.datetime.strptime(fecha_match.group(0), '%a %b %d %Y %H:%M:%S %Z%z')
            return fecha_parsed
        else:
            return fecha
