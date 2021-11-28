import psycopg2
import logging
import datetime
from scrapy.exceptions import DropItem

MEDIOS = { 
        'biobio': 1,
        'emol': 2,
        'tercera': 3, }

SECCIONES = {
        'Nacional': 1,
        'Política': 2,
        'Internacional': 3,
        'Economía': 4,
        'Educación': 5,
        'Opinión': 6,
        'Tendencias': 7
        }

class DBTranslatorPipeline:
    '''
    Handles normalizing and translating values
    for our DB.
    '''
    def process_item(self, item, spider):
        # Set the medio_id
        item['medio'] = MEDIOS[item['medio']]
        item['seccion'] = SECCIONES[item['seccion']]
        return item

class DBPipeline:
    '''
    Handles storing items in our database.
    '''
    def open_spider(self, spider):
        self.conn = psycopg2.connect("dbname=lector user=lector_chile")
        self.conn.set_session(autocommit=True)
        self.cur = self.conn.cursor()

    def process_item(self, item, spider):
        #TODO: Implement error catching here, unique keys and such.
        insert_sql = ("INSERT INTO noticias"
        "(medio_id, seccion_id, autor, fecha, titular, bajada, imagen_url, cuerpo, url)"
        "VALUES"
        "(%s, %s, %s, %s, %s, %s, %s, %s, %s)")

        insert_data = [
                item['medio'], item['seccion'], item['autor'], item['fecha'],
                item['titular'], item['bajada'], item['imagen_url'], item['cuerpo'],
                item['url'] 
                ]

        try:
            self.cur.execute(insert_sql, insert_data)
            logging.log(logging.INFO,
                    'Inserted item with url:\n\t{url}\ninto DB.'.format(url=item['url']))
            return item
        except psycopg2.errors.UniqueViolation:
            logging.log(logging.INFO, 
                    'Item for medio {medio}, with url:\n\t{url}\nalready exists in DB. Skipping.'.format(medio=item['medio'], url=item['url']))
            raise DropItem

    def close_spider(self, spider):
        # self.conn.commit() -- Use if no autocommit
        logging.log(logging.INFO, self.conn.notices)
        self.conn.close()

class ScreenerPipeline:
    '''
    Screen items for unacceptable values.
    '''
    def process_item(self, item, spider):
        if item['titular'] == None: raise DropItem
        if item['cuerpo'] == None or item['cuerpo'] == []: raise DropItem
        if item['url'] == None: raise DropItem

class DefaultsPipeline:
    '''
    Sets default values for each field.
    '''
    #TODO: Sanitize date values here, we're getting a few that throw errors, namely: Fri Mar 05 2021 22:00:00 GMT+0000 (Coordinated Universal Time) from La Tercera
    def process_item(self, item, spider):
        item.setdefault('titular', None),
        item.setdefault('autor', None)
        item.setdefault('imagen_url', None)
        item.setdefault('bajada', None)
        item.setdefault('cuerpo', None)
        item.setdefault('fecha', datetime.datetime.now())
        item.setdefault('url', None)

        return item
