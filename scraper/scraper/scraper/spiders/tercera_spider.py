import scrapy
from scraper.spiders.rules import tercera

class TerceraSpider(scrapy.Spider):
    name = tercera['name']
    base_url = tercera['base_url']

    def start_requests(self):
        for section, url in tercera['sections'].items():
            yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))
   
    # Get all article links in a given section page, delegate to parse_article
    def parse(self, response, section):

        article_rel_links = tercera['article_links'](response)

        for rel_link in article_rel_links:

            abs_link = self.base_url + rel_link
            yield scrapy.Request(url=abs_link, callback=self.parse_article, cb_kwargs=dict(section=section))

    #Parse individual articles
    def parse_article(self, response, section):

        yield {
                "section": section,
                "headline": tercera['article']['headline'](response),
                "author": tercera['article']['author'](response),
                "image": tercera['article']['image'](response),
                "excerpt": tercera['article']['excerpt'](response),
                "body": tercera['article']['body'](response),
                "published": tercera['article']['published'](response)
                }
