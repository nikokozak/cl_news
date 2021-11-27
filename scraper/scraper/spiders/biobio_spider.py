import scrapy
from scraper.spiders.rules import biobio
from scraper.spiders.cache import Cache
from scraper.items import NoticiaItem, NoticiaLoader

class BioBioSpider(scrapy.Spider):
    name = biobio['name']
    base_url = biobio['base_url']

    @classmethod 
    def from_crawler(cls, crawler, *args, **kwargs):
        '''Override proxy to __init__ used by scrapy to create spiders
        so we can access scrapy's settings and assign the correct cache
        folder to our cache handler.
        '''
        spider = cls(*args, **kwargs)
        spider._set_crawler(crawler)
        cache_file = crawler.settings.get('SPIDER_CACHE_FOLDER') + 'biobio_cache.json'
        spider.cache = Cache(cache_file)
        return spider

    def __init__(self, *args, **kwargs):
        '''Override the __init__ function so that we might pass in keyword args
        and set defaults for our spider'''
        super(BioBioSpider, self).__init__(*args, **kwargs)
        # Accept a "limit" kwarg that sets how many articles we scrape per page
        self.limit = 1000 if not hasattr(self, 'limit') else self.limit

    def start_requests(self):
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

        l.add_value('medio', 'biobio')
        l.add_value('seccion', section)
        l.add_xpath('titular', rules['titular'])
        l.add_xpath('bajada', rules['bajada'])
        l.add_xpath('autor', rules['autor'])
        l.add_xpath('image_url', rules['image_url'])
        l.add_xpath('cuerpo', rules['cuerpo'])
        l.add_xpath('fecha', rules['fecha'])

        yield l.load_item()

    def closed(self, reason):
        if reason == 'finished':
            self.cache.save()
            print('Successfully saved cache for BioBio')

