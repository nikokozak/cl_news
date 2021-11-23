import scrapy
from scraper.spiders.rules import biobio
from scraper.spiders.cache import Cache

class BioBioSpider(scrapy.Spider):
    name = biobio['name']
    base_url = biobio['base_url']
    cache = Cache('/Users/niko/Documents/Code/LectorChile/scraper/scraper/scraper/cache/biobio_cache.json')

    def start_requests(self):
        for section, url in biobio['sections'].items():
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
