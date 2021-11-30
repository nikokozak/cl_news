import scrapy
from scrapy.loader import ItemLoader
from itemloaders.processors import TakeFirst, Identity, Join

class NoticiaLoader(ItemLoader):

    #TODO define conversion here instead of in pipeline
    default_output_processor = TakeFirst()

    bajada_out = Join()
    cuerpo_out = Identity()

class NoticiaItem(scrapy.Item):

    #TODO add data conversions in Pipeline
    medio = scrapy.Field()
    seccion = scrapy.Field()
    titular = scrapy.Field()
    bajada = scrapy.Field()
    autor = scrapy.Field()
    imagen_url = scrapy.Field()
    cuerpo = scrapy.Field()
    fecha = scrapy.Field()
    url = scrapy.Field()

    
