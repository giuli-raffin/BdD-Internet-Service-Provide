-- Escribir la sentencia SQL para crear las vistas detalladas a continuación. Indicar y justificar si es actualizable o no en PostgreSQL, indicando la/s causa/s 
-- (Importante: siempre que sea posible, se deberán generar vistas automáticamente actualizables para PostgreSQL). 

-- Para una de la/s vista/s no actualizable/s, implemente los triggers instead of necesarios para su actualización.

--a. Realice una vista que contenga el saldo de cada uno de los clientes que tengan domicilio en la ciudad ‘X’.
create or replace view saldo_clientes_domicilio as
select id_cliente, saldo
from cliente c
where exists(
 select 1
 from ciudad ci
 join (select id_ciudad, id_barrio from barrio) b on ci.id_ciudad = b.id_ciudad
 join (select id_barrio, id_persona from direccion) d on b.id_barrio = d.id_barrio
 where ci.nombre = 'X' and c.id_cliente = d.id_persona
       );

--b. Realice una vista con la lista de servicios activos que posee cada cliente junto con el costo del mismo al momento de consultar la vista.
create view servicios_activos_costo as
select s.*, c.id_cliente
from servicio s
join (select id_servicio, id_cliente from equipo) e on s.id_servicio = e.id_servicio
join (select id_cliente from cliente) c on e.id_cliente = c.id_cliente
where s.activo is true
group by c.id_cliente, s.id_servicio;

--no es automaticamente actualizable
create or replace function  fn_insert_servicios_activos_costo() returns trigger
as $$
     begin
         if exists (select 1 from persona where id_persona = new.id_cliente)
             then
                 if exists (select 1 from categoria where categoria.id_cat = new.id_cat)
                 then
                     if(not exists(select 1 from cliente  where id_cliente=new.id_cliente))
                         then
                             insert into cliente(id_cliente) VALUES (new.id_cliente);
                     end if;
                     if(not exists(select 1 from servicio where id_servicio=new.id_servicio))
                         then
                             insert into servicio(id_servicio, nombre, periodico, costo, intervalo, tipo_intervalo, activo, id_cat)
                                 values (new.id_servicio, new.nombre, new.periodico, new.costo, new.intervalo, new.tipo_intervalo, new.activo, new.id_cat);
                     end if;
                 else
                     raise exception 'no se puede agregar un servicio de una categoria que no existe';
                 end if;
         else
             raise exception 'no se puede agregar un cliente que no es persona';
         end if;
         return new;
     end;
 $$ language 'plpgsql';

create trigger TR_insert_servicios_activo_costo
 instead of insert on servicios_activos_costo
 for each row execute procedure fn_insert_servicios_activos_costo();

create or replace function fn_update_servicios_activos_costo() returns trigger
as $$
   begin
           update cliente set id_cliente = new.id_cliente
           where id_cliente in (select equipo.id_cliente from equipo);

           update servicio set nombre = new.nombre
               , periodico = new.periodico
               , costo = new.costo
               , intervalo = new.intervalo
               , tipo_intervalo = new.tipo_intervalo
               , activo = new.activo
               , id_cat = new.id_cat
           where id_servicio = new.id_servicio;
   return new;
   end;
  $$ language 'plpgsql';

create trigger TR_update_servicios_activo_costo
  instead of update on servicios_activos_costo
  for each row execute procedure fn_update_servicios_activos_costo();

create or replace function  fn_delete_servicios_activos_costo() returns trigger
as $$
  begin
      delete from servicio where old.id_servicio = servicio.id_servicio;
      delete from cliente where old.id_cliente = cliente.id_cliente;
      delete from equipo where old.id_servicio = equipo.id_servicio 
      and old.id_cliente = equipo.id_cliente;
  return old;
  end;
 $$ language 'plpgsql';

create trigger TR_delete_servicios_activo_costo
 instead of delete on servicios_activos_costo
 for each row execute procedure fn_delete_servicios_activos_costo();

--c. Realice una vista que contenga, por cada uno de los servicios periódicos registrados, el monto facturado mensualmente durante los últimos 5 años ordenado por servicio, año, mes y monto.
create or replace view periodico_monto_5anios as
select s.id_servicio, sum(c.importe) as monto
from servicio s
join (select id_servicio, id_comp, id_tcomp from lineacomprobante) l on s.id_servicio = l.id_servicio
join (select id_tcomp, id_comp, importe, fecha from comprobante) c on l.id_comp = c.id_comp and l.id_tcomp = c.id_tcomp
join (select id_tcomp, tipo from tipocomprobante) t on c.id_tcomp = t.id_tcomp
where extract(year from current_timestamp) - extract(year from c.fecha) <= 5 and t.tipo = 'factura'
and s.periodico is true
group by s.id_servicio, extract(month from c.fecha), extract(year from c.fecha)
order by s.id_servicio, extract(year from c.fecha), extract(month from c.fecha), sum(c.importe);
-- no es automaticamente actualizable
