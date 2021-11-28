# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
from itemadapter import ItemAdapter

class ScraperPipeline:
    def process_item(self, item, spider):
        return item

class DefaultsPipeline:
    '''
    Simply sets default values for each item.
    '''
    def process_item(self, item, spider):
        item.setdefault('titular', None),
        item.setdefault('autor', None),
        item.setdefault('image_url', None),
        item.setdefault('bajada', None),
        item.setdefault('cuerpo', None),
        item.setdefault('fecha', None)

        return item
