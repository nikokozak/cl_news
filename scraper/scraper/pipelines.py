import psycopg2
from itemadapter import ItemAdapter
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html

class DBTranslatorPipeline:
    '''
    Handles normalizing and translating values
    for our DB.
    '''
    def process_item(self, item, spider):
        pass

class DBPipeline:
    '''
    Handles storing items in our database.
    '''
    def open_spider(self, spider):
        self.conn = psycopg2.connect("dbname=lector user=lector_chile")
        self.cur = self.conn.cursor()

    def process_item(self, item, spider):
        self.cur.execute("INSERT INTO noticias" 
        "(medio_id, seccion_id, autor, fecha, titular, bajada, imagen_url, cuerpo, url)"
        "VALUES"
        "(%s, %s, %s, %s, %s, %s, %s, %s, %s)",
        (1, 1, item['autor'], item['fecha'], item['titular'], 
            item['bajada'], item['imagen_url'], item['cuerpo'], item['url']))

        return item

    def close_spider(self, spider):
        self.conn.commit()
        self.conn.close()

class DefaultsPipeline:
    '''
    Simply sets default values for each item.
    '''
    def process_item(self, item, spider):
        item.setdefault('titular', None),
        item.setdefault('autor', None)
        item.setdefault('imagen_url', None)
        item.setdefault('bajada', None)
        item.setdefault('cuerpo', None)
        item.setdefault('fecha', None)
        item.setdefault('url', None)

        return item
