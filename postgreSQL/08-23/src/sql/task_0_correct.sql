
create or replace function correct_content(
	ori_pos varchar
)
returns varchar as 
$func$
declare
	tmp_vals double precision;
	tmp_coef integer := 10;
	cor_res varchar;
begin
	select cast(ori_pos as double precision) into tmp_vals;

	tmp_vals := tmp_vals / 1000000;
	
	
	return tmp_vals::varchar;
end;
$func$ language plpgsql 






-- 车辆_出发_地球经度
update ods_july_only 
set 
	cl_cfa_dqjd = correct_content(cl_cfa_dqjd)
where
	cast(cl_cfa_dqjd as double precision) > 1000
	and char_length(cl_cfa_dqjd) = 9
;

-- 车辆_出发_地球纬度
update ods_july_only 
set 
	cl_cfa_dqwd = correct_content(cl_cfa_dqwd)
where
	cast(cl_cfa_dqwd as double precision) > 1000
	and char_length(cl_cfa_dqwd) > 0
;

-- 车辆_到达_地球经度
update ods_july_only 
set 
	cl_dd_dqjd = correct_content(cl_dd_dqjd)
where
	cast(cl_dd_dqjd as double precision) > 1000
	and char_length(cl_dd_dqjd) > 0
;

-- 车辆_到达_地球纬度
update ods_july_only 
set 
	cl_dd_dqwd = correct_content(cl_dd_dqwd)
where
	cast(cl_dd_dqwd as double precision) > 1000
	and char_length(cl_dd_dqwd) > 0
;

select
	char_length(cl_cfa_dqjd),
	*
from ods_july_only
where 
	char_length(cl_cfa_dqjd) = 9
	-- and char_length(cl_cfa_dqjd) > 10 
	-- and cast(cl_cfa_dqjd as double precision) > 1000
;
	