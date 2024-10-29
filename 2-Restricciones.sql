-- 1. Escribir la restricción de la manera que considere más apropiada en SQL estándar declarativo, indicando su tipo y justificación correspondiente. 
-- 2. Para los 3 últimos controles (c, d, e), implementar la restricción en PostgreSQL de la forma más adecuada, según las posibilidades que ofrece el DBMS.


--a. Si una persona está inactiva debe tener establecida una fecha de baja, la cual se debe controlar que sea al menos 18 años posterior a la de nacimiento.
alter table PERSONA
	add constraint ck_a CHECK ( (activo is false 
and fecha_baja is not null 
and current_date - (cast (fecha_nacimiento as date)) >= 18*365)
or activo is true );

--b. El importe de un comprobante debe coincidir con la suma de los importes de sus líneas (si las tuviera).
create assertion ck_b CHECK ( NOT EXISTS (	
select 1
from COMPROBANTE c
join (select id_comp, id_tcomp, importe from
 LINEACOMPROBANTE) l
on c.id_comp = l.id_comp and c.id_tcomp = l.id_tcomp
group by c.id_comp, c.importe
having (sum(l.importe)) <> c.importe
) );

--c. Un equipo puede tener asignada un IP y, en este caso, la MAC resulta requerida.
alter table EQUIPO
add constraint ck_c CHECK ( (ip is not null and mac is null) or ip is null );

--2
create or replace function FN_inciso_c() returns trigger as $$
begin
 if ( exists ( select 1 from EQUIPO
       where id_equipo = new.id_equipo
       and ( new.ip is not null and new.mac is null ) ) ) then

 raise exception 'no se puede tener un equipo con IP pero sin MAC';
 end if;
 return new;
end
$$ language 'plpgsql';

create trigger TR_inciso_c
before insert or update of ip, mac
on EQUIPO
for each row execute procedure FN_inciso_c();

--d. Las IPs asignadas a los equipos no pueden ser compartidas entre clientes.
create assertion ck_d CHECK ( not exists (
						select 1 
from equipo e
						join equipo e2 on e.ip = e2.ip
						where e.id_cliente <> e2.id_cliente ) );

--2
create or replace function FN_inciso_d() returns trigger as $$
begin
 if ( exists ( select 1
            from equipo e
            where new.id_cliente not in (
            select id_cliente
            from equipo e2
            where new.ip = e2.ip) and new.ip = e.ip ) ) then

  raise exception 'las IPs asignadas a los equipos no pueden ser compartidas entre clientes diferentes';
  end if;
  return new;
end
$$ language 'plpgsql';


create trigger TR_inciso_d
before insert or update of ip, id_cliente
on EQUIPO
for each row execute procedure FN_inciso_d();

--e. No se pueden instalar más de 25 equipos por Barrio.
select 1
from equipo e
join direccion d on d.id_persona = e.id_cliente
group by (d.id_barrio)
having count(*) > 25
) );

--2
create or replace function or procedure FN_inciso_e_equipo() returns trigger as $$
begin
	if ( exists ( select 1
         		from direccion d
        		join EQUIPO e on id_persona = e.id_cliente
        		where e.id_cliente = new.id_cliente
         		having count(id_barrio) > 24 ) ) then
	raise exception ‘No se pueden instalar más de 25 equipos por Barrio’;
	end if;
	return new;
end; $$
language 'plpgsql';

create or replace function or procedure FN_inciso_e_direc() returns trigger as $$
begin
	if ( exists (
         		select 1
         		from direccion d
        		join EQUIPO e on id_persona = e.id_cliente
         		where d.id_barrio = new.id_barrio
        		having count(id_cliente) > 24 ) ) then
  	raise exception 'No puede haber más de 25 equipos por Barrio';
	end if;
	return new;
end; $$
language 'plpgsql';

create trigger TR_direccion_inciso_e
before update of id_barrio on DIRECCION
for each row
execute procedure FN_inciso_e_direc();

create trigger TR_cliente_inciso_e
before insert or update of id_cliente on EQUIPO
for each row
execute procedure FN_inciso_e_equipo();
