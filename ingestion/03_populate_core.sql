insert into core.genero(id,nome)
select distinct genero_id, genero
from stg_victims
where genero_id is not null;

insert into core.estado(id,nome)