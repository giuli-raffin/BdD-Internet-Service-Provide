1. Consultas

--a
select cl.id_cliente, apellido, p.nombre, tipodoc, nrodoc, fecha_nacimiento, count(*)
from cliente cl
join (select id_persona, nombre, apellido, tipodoc, nrodoc, fecha_nacimiento from persona) p on cl.id_cliente = p.id_persona
join (select id_cliente from equipo) e on cl.id_cliente = e.id_cliente
group by cl.id_cliente, apellido, p.nombre, tipodoc, nrodoc, fecha_nacimiento
order by apellido, p.nombre;

--b
select ci.nombre as ciudad, ci.id_ciudad, b.nombre as barrio, b.id_barrio, count(e.id_equipo) as cant_equipos
from ciudad ci
join (select id_ciudad, id_barrio, nombre from barrio) b on ci.id_ciudad = b.id_ciudad
join (select id_barrio, id_persona from direccion) d on b.id_barrio = d.id_barrio
join (select id_persona from persona) p on d.id_persona = p.id_persona
join (select id_cliente from cliente) c on p.id_persona = c.id_cliente
join (select id_cliente, id_equipo, fecha_baja, fecha_alta from equipo) e on c.id_cliente = e.id_cliente
where e.fecha_baja is null and ((extract(year from current_timestamp) - extract(year from e.fecha_alta) = 2) and
    (extract(month from e.fecha_alta) - extract(month from current_timestamp) >= 0)) --2 años menos
    or (extract(year from current_timestamp) - extract(year from e.fecha_alta) = 1) --1 año menos
    or extract(year from current_timestamp) = extract(year from e.fecha_alta) --el mismo año
group by ci.nombre, ci.id_ciudad, b.nombre, b.id_barrio
order by count(e.id_equipo) desc;

--c
select d.id_direccion, calle, numero, piso, depto, id_barrio
from direccion d
join (select id_cliente from cliente) c on d.id_persona = c.id_cliente
join (select id_cliente, fecha, id_comp, id_tcomp from comprobante) comp on c.id_cliente = comp.id_cliente
join (select id_comp, id_tcomp, id_servicio from lineacomprobante)l on comp.id_comp = l.id_comp and comp.id_tcomp = l.id_tcomp
join (select id_servicio, periodico from servicio)s on l.id_servicio = s.id_servicio
where s.periodico is true and extract(year from current_timestamp) - extract(year from comp.fecha) <= 3
group by d.id_direccion, calle, numero, piso, depto, id_barrio
order by count(*) desc
limit 3;

--d
select p.nombre, apellido, tipodoc, nrodoc
from cliente cl
join (select id_persona,nombre,apellido,tipodoc,nrodoc from persona) p on cl.id_cliente = p.id_persona
where not exists(
  (select s.id_servicio
  from servicio s
  where s.periodico is true and intervalo between 5 and 10)
  except
  (select e.id_servicio
  from equipo e
      where e.id_cliente = cl.id_cliente
  )
);
