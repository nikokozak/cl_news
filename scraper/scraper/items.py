# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy.loader import ItemLoader
from itemloaders.processors import TakeFirst

class NoticiaLoader(ItemLoader):

    default_output_processor = TakeFirst()
    #TODO add functions to deal with data conversion here

class NoticiaItem(scrapy.Item):

    medio = scrapy.Field()
    seccion = scrapy.Field()
    titular = scrapy.Field()
    bajada = scrapy.Field()
    autor = scrapy.Field()
    image_url = scrapy.Field()
    cuerpo = scrapy.Field()
    fecha = scrapy.Field()

    
