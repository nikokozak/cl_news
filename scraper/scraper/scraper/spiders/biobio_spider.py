import scrapy
from scraper.spiders.rules import biobio

class BioBioSpider(scrapy.Spider):
    name = biobio['name']
    base_url = biobio['base_url']

    def start_requests(self):
        for section, url in biobio['sections'].items():
            yield scrapy.Request(url=url, callback=self.parse, cb_kwargs=dict(section=section))

    def parse(self, response, section):
        article_abs_links = biobio['article_links'](response)

        for abs_link in article_abs_links:
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

