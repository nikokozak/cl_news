# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy.loader import ItemLoader
from itemloaders.processors import TakeFirst, Identity

class NoticiaLoader(ItemLoader):

    default_output_processor = TakeFirst()

    bajada_out = Identity()
    cuerpo_out = Identity()

class NoticiaItem(scrapy.Item):

    #TODO set defaults here
    #TODO add data conversions in Pipeline
    medio = scrapy.Field()
    seccion = scrapy.Field()
    titular = scrapy.Field()
    bajada = scrapy.Field()
    autor = scrapy.Field()
    image_url = scrapy.Field()
    cuerpo = scrapy.Field()
    fecha = scrapy.Field()

    
