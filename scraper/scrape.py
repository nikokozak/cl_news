import scrapy
import argparse
from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings

parser = argparse.ArgumentParser()
process = CrawlerProcess(get_project_settings())
sites = ['biobio', 'tercera']

parser.add_argument('--sites', type=str, required=False, nargs='+', default="all")
parser.add_argument('--article-limit', type=int, required=False, default=1)
parser.add_argument('--clear-cache', action="store_true", required=False, default=False)

args = parser.parse_args()

if args.sites != "all":
    for site in args.sites:
        process.crawl(site, limit=args.article_limit, clear_cache=args.clear_cache)
else:
    for site in sites:
        process.crawl(site, limit=args.article_limit, clear_cache=args.clear_cache)

#process.crawl('biobio', limit=1, clear_cache=True)
#process.crawl('tercera', limit=1, clear_cache=True)
process.start()
