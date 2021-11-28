import scrapy
from scraper.spiders.cache_manager import Cache

class NoticiaSpider(scrapy.Spider):
    @classmethod 
    def from_crawler(cls, crawler, *args, **kwargs):
        '''Override proxy to __init__ used by scrapy to create spiders
        so we can access scrapy's settings and assign the correct cache
        folder to our cache handler. We have to do this here because settings is initialized 
        in the base class AFTER this class's __init__
        '''
        spider = cls(*args, **kwargs)
        spider._set_crawler(crawler)
        cache_file = crawler.settings.get('SPIDER_CACHE_FOLDER') + spider.name + '_cache.json'
        spider.cache = Cache(cache_file)
        return spider

    def __init__(self, *args, **kwargs):
        '''Override the __init__ function so that we might pass in keyword args
        and set defaults for our spider'''
        super(NoticiaSpider, self).__init__(*args, **kwargs)

        # Clears the cache of values before starting
        if not hasattr(self, 'clear_cache'): self.clear_cache = False

        # Accept a "limit" kwarg that sets how many articles we scrape per page
        if not hasattr(self, 'limit'): self.limit = 1000

    def closed(self, reason):
        if reason == 'finished':
            self.cache.save()
            print('Successfully saved cache for ' + self.name)

