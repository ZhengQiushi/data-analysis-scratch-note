


create or replace function find_K_hotest_router(
	freqency integer,
	K_top integer
)
returns table(cl_cfa_geohash_short varchar, cl_dd_geohash_short varchar, total_sum integer) as 
$func$
declare
begin
	return query select 
					t_1.cl_cfa_geohash_short::varchar, 
					t_1.cl_dd_geohash_short::varchar,
					count(*)::integer as total_num
				from
					ods_july_only_restruct_0701_0731 as t_1
				where
					char_length(t_1.cl_cfa_geohash_short) = 6 and
					char_length(t_1.cl_dd_geohash_short) = 6
				group by t_1.cl_cfa_geohash_short, t_1.cl_dd_geohash_short
				having 
					count(*) > freqency
				order by total_num desc
				-- limit K_top
;
	
end
$func$ language 'plpgsql'

drop table if exists K_top_router;

create table K_top_router as 
	select 
		t_2.*,
		t_1.total_sum
	from
		find_K_hotest_router(0, 10) as t_1,
		ods_july_only_restruct_0701_0731 as t_2
	where 
		t_1.cl_cfa_geohash_short = t_2.cl_cfa_geohash_short and
		t_1.cl_dd_geohash_short = t_2.cl_dd_geohash_short
	;


--select * from ods_july_only_restruct_0701_0731 where did_bh = 17737648778807;
