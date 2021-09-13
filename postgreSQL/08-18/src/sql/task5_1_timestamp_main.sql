
drop table if exists t_alarm_router_timestamp;

CREATE TABLE public.t_alarm_router_timestamp (
	router_id integer NULL,
	event_type bigint NULL,
	begin_time timestamp NULL
);

drop function if exists return_route_event_timestamp(varchar);


create or replace function return_route_event_timestamp(
	cur_date varchar)
    returns table(router_id integer, event_type bigint, begin_time timestamp) as
$$
begin
    return query execute format(
		'select 
			router_id,
			event_type,
			begin_time
		from
			t_task1_tab as t_1,
			t_device_alarm_'|| cur_date || ' as t_2
		where 
			(case when 
				t_2.begin_time >= t_1.drive_start_time::timestamp 
				and t_2.begin_time <= t_1.drive_end_time::timestamp 
				then true else false END) 
			and (-- 记录有效的标签
		        t_2.label::jsonb @> ''[{"labels": [{"key": "effective", "value": "0"}], "component": "irtsafedriving"}]''::jsonb 
		        or  t_2.label is null)
		    and t_2.vehicle_index_code = t_1.vehicle_index_code'
		);
end;
$$ LANGUAGE 'plpgsql';

DO $$
declare 
	cur_year varchar := '2021';
	cur_month varchar := '7';
	from_date_ varchar := '1';
	to_date_ varchar := '2';

	cnt integer := from_date_::integer;
	cur_full_date varchar;
	cur_full_date_res varchar;
begin

	while cnt <= to_date_::integer loop
		/* 2021/7/1 */
		cur_full_date = concat(cur_year, 
							concat('/', 
								concat(cur_month, 
									concat('/', 
										concat(cnt::varchar)
										)
									)
								)
							);
		/* 20210701 */
		cur_full_date_res = unify_date(
			cur_full_date
		);
--		RAISE NOTICE 'full_date_res: %', cur_full_date_res;
--		RAISE NOTICE 'cur_full_date: %', cur_full_date;
		
		/* 插入结果表 */
		insert into t_alarm_router_timestamp(
		   router_id, 
		   event_type  ,
		   begin_time
		) 
		select * from return_route_event_timestamp(cur_full_date_res);
	
		cnt := cnt + 1;
	end loop;

	create table return_route_event_timestamp_ 
	select * from t_alarm_router_timestamp order by router_id, begin_time ASC;

END; $$