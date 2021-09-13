
drop table if exists t_device_alarm_category;
-- 需要一个事件的主键...
CREATE TABLE public.t_device_alarm_category (
        category_id serial NOT NULL,
        router_id int4 NULL,
        statistics_date varchar NULL,
        event_type int8 NULL,
        cur_type_sum int4 NULL,
        vehicle_index_code varchar NULL,
        driver_index_code varchar ,
        CONSTRAINT t_device_alarm_category_pk PRIMARY KEY (category_id)
);


/*
 * @brief 简单的日期转换
 * @param full_date( '2021/7/2' )
 * @return 20210702
 * */
create or replace function unify_date(
        full_date varchar
)
returns varchar as 
$$
declare
        cur_month varchar;
        cur_date varchar;
        cur_year varchar;

        cur_full_date_src varchar = full_date;
        full_date_res varchar;
    /**
     * '2021/7/2' -> '20210702'
     * */
begin

        cur_year := split_part(cur_full_date_src ,'/', 1);
        cur_month := split_part(cur_full_date_src ,'/', 2);
        cur_date := split_part(cur_full_date_src ,'/', 3);

        if char_length(cur_month) < 2 then
                cur_month = concat('0'::varchar, cur_month);
        end if;
        if char_length(cur_date) < 2 then
                cur_date = concat('0'::varchar, cur_date);
        end if; 

        full_date_res = concat(cur_year, concat(cur_month, cur_date));
         RAISE NOTICE 'full_date_res: %', full_date_res;        

        return full_date_res;
end;
$$ language 'plpgsql';

/*
 正儿八经统计alarm的次数
*/
DO $$
declare 
	cur_year varchar := '2021';
	cur_month varchar := '7';
	from_date_ varchar := '1';
	to_date_ varchar := '31';

	cnt integer := from_date_::integer;
	cur_full_date varchar;
	cur_full_date_res varchar;
begin

	while cnt <= to_date_::integer loop
		/*逐天遍历 2021/7/1 */
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
		insert into t_device_alarm_category(
		   router_id  , 
		   statistics_date  , 
		   event_type  ,
		   cur_type_sum ,
		   vehicle_index_code,
		   driver_index_code
		) 
		select  
			t_t1.router_id,
			cur_full_date, 
			t_c1.event_type, 
            /* 依次遍历各个alarm事件，需要保证在当前行程的时间段内 */
			check_per_event_dynamic(
				t_t1.drive_start_time,
				t_t1.drive_end_time,
				t_c1.event_type,
				t_t1.vehicle_index_code,
				cur_full_date_res --'20210702'
				),
			t_t1.vehicle_index_code,
			t_t1.driver_index_code
		from
			t_task1_tab as t_t1,
			t_alarm_basic_config as t_c1
		where 
			t_t1.statistics_date = cur_full_date  -- '2021/7/2'
			-- 保证不是null
			and check_per_event_dynamic(
				t_t1.drive_start_time,
				t_t1.drive_end_time,
				t_c1.event_type,
				t_t1.vehicle_index_code,
				cur_full_date_res -- '20210702'
			) is not null
		;	
	
		cnt := cnt + 1;
	end loop;

END; $$