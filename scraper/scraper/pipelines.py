import psycopg2
import logging
import datetime
import lxml.html.clean as clean
from scrapy.exceptions import DropItem

class SanitizePipeline:
    '''
    Sanitizes our article bodies.
    '''
    # Setup for cleansing html tags of attrs we don't want.
    safe_attrs = set(['src', 'href', 'alt'])
    kill_tags = ['object', 'iframe']
    cleaner = clean.Cleaner(safe_attrs_only=True, safe_attrs=safe_attrs, kill_tags=kill_tags)

    def process_item(self, item, spider):
        # Clean all tags in cuerpo. Cuerpo is a list of tags, essentially.
        item['cuerpo'] = list(map(self.cleaner.clean_html, item['cuerpo']))

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
        insert_sql = ("INSERT INTO noticias"
        "(medio_id, seccion_id, autor, fecha, titular, bajada, imagen_url, cuerpo, url)"
        "VALUES"
        "((select medio_id from medios where std = %s),"
          "(select seccion_id from secciones where std = %s),"
          "%s, %s, %s, %s, %s, %s, %s)")

        insert_data = [
                item['medio'], item['seccion'], item['autor'], item['fecha'],
                item['titular'], item['bajada'], item['imagen_url'], item['cuerpo'],
                item['url'] ]

        try:
            self.cur.execute(insert_sql, insert_data)
            logging.info('INSERTED item with:\n\tURL: {url}\n\tTitular: {titular}\n\tMedio: {medio}\ninto DB.'.format(url=item['url'], titular=item['titular'], medio=item['medio']))
            return item
        except psycopg2.errors.UniqueViolation:
            logging.info('EXISTS already: \n\t{url}\nSkipping.'.format(medio=item['medio'], url=item['url']))
            raise DropItem

    def close_spider(self, spider):
        # self.conn.commit() -- Use if no autocommit
        logging.info(self.conn.notices)
        self.conn.close()


class ScreenerPipeline:
    '''
    Screen items for unacceptable values.
    '''
    def process_item(self, item, spider):
        if item['titular'] == None:
            logging.warn('NULL TITULAR for article: \n\t{url}\nDropping.'.format(url=item['url']))
            raise DropItem
        if item['cuerpo'] == None or item['cuerpo'] == []:
            logging.warn('NULL BODY for article: \n\t{url}\nDropping.'.format(url=item['url']))
            raise DropItem
        if item['url'] == None:
            logging.warn('NULL URL in spider {spider_name}\nDropping.'.format(url=spider.name))
            raise DropItem


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
