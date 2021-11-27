import scrapy
from scraper.spiders.rules import biobio
from scraper.spiders.cache import Cache

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

    def start_requests(self):
        count = 0
        for section, url in biobio['sections'].items():
            if count < 1:
                count += 1
                yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))

    def parse(self, response, section):
        article_abs_links = biobio['article_links'](response)

        for abs_link in article_abs_links:
            if not self.cache.unique(abs_link):
                yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    def parse_article(self, response, section):
        yield {
                "section": section,
                "headline": biobio['article']['headline'](response),
                "author": biobio['article']['author'](response),
                "image": biobio['article']['image'](response),
                "excerpt": biobio['article']['excerpt'](response),
                "body": biobio['article']['body'](response),
                "published": biobio['article']['published'](response)
                }

    def closed(self, reason):
        if reason == 'finished':
            self.cache.save()
            print('Successfully saved cache for BioBio')

