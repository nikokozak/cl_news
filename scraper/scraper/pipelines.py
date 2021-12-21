import psycopg2, logging, datetime, os
from zoneinfo import ZoneInfo
import lxml.html.clean as clean
from scrapy.exceptions import DropItem

class SanitizePipeline:
    '''
    Sanitizes our article bodies.
    '''
    # Setup for cleansing html tags of attrs we don't want.
    safe_attrs = set(['src', 'href', 'alt'])
    kill_tags = ['object', 'iframe', 'script']
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
        user = os.environ.get('USER')
        self.conn = psycopg2.connect(f"dbname=lector_chile user={user}")
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
            logging.info('INSERTED item into DB:\n\tURL: {url}\n\tTitular: {titular}\n\tMedio: {medio}\n'.format(url=item['url'], titular=item['titular'], medio=item['medio']))
            spider.stats.inc_value(item['seccion'] + '_storage_success')
            return item
        except psycopg2.errors.UniqueViolation:
            logging.debug('EXISTS already in DB: \n\tURL: {url}\n\tMedio: {medio}\n'.format(medio=item['medio'], url=item['url']))
            spider.stats.inc_value(item['seccion'] + '_storage_skipped')
            return None #In this case we can do this, given it's the last pipeline

    def close_spider(self, spider):
        # self.conn.commit() -- Use if no autocommit
        # logging.info(self.conn.notices)
        self.conn.close()

class ScreenerPipeline:
    '''
    Screen items for unacceptable values.
    '''
    def process_item(self, item, spider):
        if item['titular'] == None:
            logging.warn('NULL TITULAR\narticle:\n\t{url}\nmedio:\n\t{name}\nDropping.'.format(url=item['url'], name=spider.name))
            spider.stats.inc_value(item['seccion'] + '_errors')
            raise DropItem
        if item['cuerpo'] == None or item['cuerpo'] == []:
            logging.warn('NULL BODY\narticle:\n\t{url}\nmedio:\n\t{name}\nDropping.'.format(url=item['url'], name=spider.name))
            spider.stats.inc_value(item['seccion'] + '_errors')
            raise DropItem
        if item['url'] == None:
            logging.warn('NULL URL in spider {name}\nDropping.'.format(name=spider.name))
            spider.stats.inc_value(item['seccion'] + '_errors')
            raise DropItem


        spider.stats.inc_value(item['seccion'] + '_parse_success')
        return item

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
        item.setdefault('fecha', datetime.datetime.now(ZoneInfo('America/Santiago')))
        item.setdefault('url', None)

        return item
