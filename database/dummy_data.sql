\set lectoruser `echo $LECTOR_PSQL_USER`
\set lectorpass `echo $LECTOR_PSQL_PASS`
\set lectordatabase `echo $LECTOR_PSQL_DATABASE`

\c :lectordatabase :lectoruser

insert into medios (nombre)
values
    ('Radio Bío Bío'),
    ('El Mercurio Online'),
    ('La Tercera'),
    ('CIPER Chile');

insert into secciones (seccion)
values
    ('Nacional'),
    ('Política'),
    ('Internacional'),
    ('Economía'),
    ('Educación');

insert into noticias 
(medio_id, seccion_id, autor, fecha, titular, bajada, imagen_url, cuerpo, url)
values
    (1, 1, 'Alfredo Castro', '2021-11-24 08:00 -6', 'Cumple años Nikolai', 'El jóven cumplió 29 años', 'https://picsum.photos/200', ARRAY['Hoy cumplió años Nikolai.', 'Gran persona, dicen varios.', 'Veremos cómo le va este año.'], 'https://www.biobiochile.cl/noticias/nacional/region-de-la-araucania/2021/11/26/contratistas-forestales-acusan-que-delegacion-incumplio-mesa-de-trabajo-acordada-manoli-desmiente.shtml'),
    (1, 4, 'José Muñoz', '2021-11-26 19:00 -6', '"Hay claras señales de colusión": comisión del gas llama al FNE a presentar requerimiento al TDLC', null, 'https://picsum.photos/200', ARRAY['“Esperamos que la Fiscalía Nacional Económica (FNE) ponga esos antecedentes ante el Tribunal de Defensa de la Libre Competencia (TDLC) para que se investigue y sancione con todas las fuerzas de la ley”, agregó la comisión.', 'Al mismo tiempo, se presentó propuestas en materia regulatoria para bajar los precios y aumentar la competencia no solamente privada, sino que además pública.', 'Esto, por medio de la Empresa Nacional del Petróleo (Enap) y de los municipios que se muestren interesados en la iniciativa.'], 'https://www.biobiochile.cl/noticias/economia/negocios-y-empresas/2021/11/26/hay-claras-senales-de-colusion-comision-del-gas-llama-al-fne-a-presentar-requerimiento-al-tdlc.shtml'),
    (2, 1, 'J. Peña', '2021-11-26 11:18 -6', 'En fallo unánime, Tribunal declara culpables a Hugo Bustamante y Denisse Llanos por el homicidio de Ámbar', 'Asimismo sentenció a ambos imputados por el caso del hermano de la adolescente. La pena que deberán cumplir se conocerá el 7 de diciembre.', 'https://picsum.photos/200', ARRAY['En fallo unánime, el Tribunal de juicio oral en lo penal de Viña de Mar declaró culpables a Hugo Bustamante y Denisse Llanos en calidad de autores de violación con femicidio y de violación con homicidio de Ámbar C.LL., ocurrido en la comuna de Villa Alemana en 2020.', '"Se condena a Hugo Bustamante Pérez como autor del delito de violación con femicidio prescrito y sancionado en el artículo 372 bis del Código Penal, que se encuentra en grado de desarrollo consumado perpetrado el día 29 de julio de 2020 en la comuna de Villa Alemana en perjuicio de la menor Ambar", sentenció la jueza Rocío Oscariz.', 'Asimismo informó que al sujeto, pareja de la madre de la menor, también se le declara culpable "como autor de los delitos de estupro, delito sancionado en el artículo 363 número 2 del Codigo Penal, abuso sexual a menor de 14 años prescrito y sancionado en el artículo 366 inciso segundo en relación con el artículo 363 número 2 y corrupción de menores (en el caso del hermano de Ambar) en el carácter de reiterado perpetrados en las comunas de Limache y Villa Alemana durante el segundo semestre de 2019 hasta junio de 2020".'], 'https://www.emol.com/noticias/Nacional/2021/11/26/1039559/lectura-veredicto-caso-ambar.html');