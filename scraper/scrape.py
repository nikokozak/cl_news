import scrapy
import argparse
from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings

sites = ['biobio', 'tercera']
process = CrawlerProcess(get_project_settings())

parser = argparse.ArgumentParser()
parser.add_argument('--sites', type=str, required=False, nargs='+', default="all")
parser.add_argument('--avoid', type=str, required=False, nargs='+', default=[])
parser.add_argument('--article-limit', type=int, required=False, default=1)
parser.add_argument('--clear-cache', action="store_true", required=False, default=False)
args = parser.parse_args()

sites = args.sites if args.sites != "all" else sites

# Remove from our site list sites we want to avoid
for avoid in args.avoid:
    sites.remove(avoid)

for site in sites:
    #print(site, args.article_limit, args.clear_cache)
    process.crawl(site, limit=args.article_limit, clear_cache=args.clear_cache)

process.start()
