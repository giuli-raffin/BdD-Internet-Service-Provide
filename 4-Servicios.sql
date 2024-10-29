--a. Proveer el mecanismo que crea más adecuado para que al ser invocado (una vez por mes), tome todos los servicios que son periódicos y genere la/s factura/s correspondiente/s. 
-- Indicar si se deben proveer parámetros adicionales para su generación. Explicar además cómo resolvería el tema de la invocación mensual (pero no lo implemente).

CREATE SEQUENCE sequence_4a_factura
 start 0 --asumimos que no hay facturas la primera vez que se llama al procedimiento y por eso inicia en 0 la clave primaria, de lo contrario debería iniciar en el valor máximo existente + 1
 increment 1;

create or replace procedure generacion_factura_4a()
as
$$
begin
      insert into comprobante (select nextval('sequence_4a_factura'),
                                      1, --1 es el tipo de comprobante factura
                                      current_timestamp, --fecha de hoy
                                      'no vencida', --comentario
                                      'sin pagar', --estado
                                      current_timestamp+interval '1 month', --vencimiento de hoy a un mes
                                      null, --turno es null porque aún no se sacó turno
                                      s.costo, --importe que se debe pagar
                                      e.id_cliente --el cliente que debe pagar
                                  from servicio s
                                  join (select id_cliente, id_servicio from equipo) e on s.id_servicio = e.id_servicio
                                  where s.periodico is true
                                  group by s.costo, e.id_cliente
                              );
  end
$$ language 'plpgsql';

call generacion_factura_4a();

--b. Proveer el mecanismo que crea más adecuado para que al ser invocado retorne el inventario consolidado de los equipos actualmente utilizados. 
-- Se necesita un listado que por lo menos tenga: el nombre del equipo, el tipo, cantidad y si lo considera necesario puede agregar más datos.
create or replace view inventario_equipos as
select nombre, tipo_conexion, tipo_asignacion, count(*) as cantidad
from equipo
where fecha_baja is null --actualmente utilizado
group by nombre, tipo_conexion, tipo_asignacion
order by nombre;

--ejemplo de ejecucion:
select * from inventario_equipos;

--c. Proveer el mecanismo que crea más adecuado para que al ser invocado entre dos fechas cualesquiera dé un informe de los empleados junto con la cantidad de turnos resueltos por localidad 
-- y los tiempos promedio y máximo del conjunto de cada uno.
create or replace function informe_empleados (fecha_ini timestamp with time zone, fecha_fin timestamp with time zone) --da informe de empleados que tengan al menos una fecha "hasta" entre sus turnos
returns table (personal int, idrol int,tdoc varchar(10), ndoc varchar(10), nom varchar (40), apell varchar(40), nac timestamp, cui varchar(20),turnos bigint, tiempo_prom interval, tiempo_max interval, city varchar(80))
as $$
begin
   return query
   select p.id_personal as id, p.id_rol as rol, tipodoc as tipo_doc, nrodoc as dni, per.nombre, apellido, fecha_nacimiento, CUIT ,count(id_turno) as cant_turnos, avg(t.hasta - t.desde) as tiempo_promedio, max(t.hasta - t.desde) as tiempo_maximo,c.nombre as ciudad
   from turno t
   join (select id_persona, id_barrio from direccion) d on t.id_personal = d.id_persona
   join (select id_barrio, id_ciudad from barrio) b on d.id_barrio = b.id_barrio
   join (select id_ciudad,nombre from ciudad) c on b.id_ciudad = c.id_ciudad
   join (select id_personal, id_rol from personal) p on t.id_personal = p.id_personal
   join (select id_persona, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, CUIT from persona) per on p.id_personal = per.id_persona
   where t.desde >= fecha_ini and t.hasta <= fecha_fin
   group by p.id_personal, p.id_rol, tipodoc, nrodoc, per.nombre, apellido, fecha_nacimiento, CUIT, c.nombre;
end
$$ language 'plpgsql';

--ejemplo de ejecución:
select informe_empleados(to_timestamp('2018-10-20','yyyy-MM-dd'), current_timestamp);

