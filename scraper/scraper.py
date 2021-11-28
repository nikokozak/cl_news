import scrapy
from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings

process = CrawlerProcess(get_project_settings())
process.crawl('biobio', limit=1, clear_cache=False)
process.crawl('tercera', limit=1, clear_cache=False)
process.start()
