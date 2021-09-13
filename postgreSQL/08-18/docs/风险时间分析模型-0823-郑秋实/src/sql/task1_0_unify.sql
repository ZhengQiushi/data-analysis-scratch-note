
/* 合并时间段 */


drop table if exists detailed_router;
create table detailed_router( 
			per_id serial not null, 
			router_index varchar, 
			driver_index_code varchar,
			vehicle_index_code varchar, 
			diff_time varchar,
			begin_time varchar,
			end_time varchar,
			statistics_date varchar,
			attendance_detail_id varchar,
			PRIMARY KEY ( per_id )
);
CREATE INDEX test1_id_index ON detailed_router (per_id);    

drop table if exists detailed_router_;


/* 按照时间间隔重新合并行程， 合并后的格式如下：
    head_type_index-1
    10
    10
    10 
    head_type_index-2
    head_type_index-3
    10
    head_type_index-4 
*/
insert into detailed_router  (
			router_index , 
			driver_index_code ,
			vehicle_index_code , 
			diff_time ,
			begin_time ,
			end_time ,
			statistics_date,
			attendance_detail_id
)
	select 
			router_index, 
			driver_index_code,
			vehicle_index_code, 
			diff_time,
			begin_time,
			end_time,
			statistics_date,
			attendance_detail_id
		from
			(select 
				driver_index_code,
				vehicle_index_code, 
				driver_index_code = lag(driver_index_code) over() as same_driver,
				vehicle_index_code = lag(vehicle_index_code) over() as same_vehicle,
				-- 筛选时间间隔，前后两条行程时间差小于50才考虑
				(case when 
	                  begin_time::timestamp - lag(end_time::timestamp) over () < '00:50:00' 
	                  and begin_time::timestamp - lag(end_time::timestamp) over () >= '00:00:00'
	                  then '10'
	                  else lead("index") over()  
	            end) as router_index, 
				begin_time::timestamp - lag(end_time::timestamp) over () as diff_time,
				begin_time,
				end_time,
				statistics_date,
				attendance_detail_id
			from 
                -- 从排好序的内容筛出来
				(select * 
					from t_attendance_detail 
					where end_time::timestamp > begin_time::timestamp
					order by statistics_date, driver_index_code, vehicle_index_code, begin_time) as t_ordered
			where
				'2021/7/1' < statistics_date and statistics_date < '2021/7/31' 
			) as trans_fst
        -- 最后在按照相应序列进行排序
		order by statistics_date, driver_index_code, vehicle_index_code, begin_time

		-- where same_driver = true and same_vehicle = true
		--	and driver_index_code = '08128a3c3cba4ba5af29ec7c209e85d2'
		;
	
/*
 将padding的10全部赋值成head_type_index
*/

do $$
declare 
	cnt integer := 0;
	head_index_id varchar := '0';
	cur_index_id varchar := '0';
	fixed_index varchar := '10';
	cnt_limit integer;
begin
    -- 循环上限
	select max(per_id) from detailed_router into cnt_limit;
	
    while cnt <= cnt_limit loop
        -- 依次取出每一条type_index
		select router_index from detailed_router where per_id = cnt into cur_index_id;
		
	    if head_index_id = '0' and cur_index_id != fixed_index then
            -- 第一条，先赋值给head
	        head_index_id := cur_index_id;
	    else
	        if cur_index_id = fixed_index then
	            -- 如果当前为10，说明和上面是同一段，故update
	            update detailed_router set router_index = head_index_id where per_id = cnt;
	        else
                -- 不然，说明进入了新一段
	        	select router_index from detailed_router where per_id = cnt into head_index_id;	
			end if;
		end if;
	
		raise notice 'cnt %', cnt;
		raise notice 'cur_index_id %', cur_index_id;
		raise notice 'head_index_id %', head_index_id;
		cnt := cnt + 1;
	end loop;
		

end $$