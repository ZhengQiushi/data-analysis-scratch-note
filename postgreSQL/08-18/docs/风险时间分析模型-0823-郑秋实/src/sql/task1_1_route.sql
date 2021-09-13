-- 新增属性列 
-- ALTER TABLE public.t_attendance_detail ADD statistics_date varchar NULL;
drop index if exists t_attendance_detail_index;
create index t_attendance_detail_index on t_attendance_detail("index");


update t_attendance_detail as out_tab set (statistics_date) = (
	select 
		split_part(in_tab.begin_time ,' ', 1) as in_date 
	from 
		t_attendance_detail as in_tab
	where
		in_tab."index" = out_tab."index"
)
-- where driver_index_code = 'e33a2f8a2e3d4f559d32fada46793df8'
;
-- 提取详细行程, 并统计行驶时间

drop table if exists t_task1; -- 依赖于下面的
drop table if exists t_attendance_time_period -- 统计出发、结束时间，校验持续时间;

create table t_attendance_time_period as 
	select 
		vehicle_index_code,
		driver_index_code, 
		statistics_date, 
		min(t_details.begin_time) as drive_start_time, 
		max(t_details.end_time) as drive_end_time,
		min(t_details.attendance_detail_id) as t_attendance_detail_id, 
		sum(extract(epoch FROM (t_details.end_time::timestamp - t_details.begin_time::timestamp ))) as drive_period -- 计算持续时间
	from detailed_router as t_details -- t_attendance_detail as t_details
--	where statistics_date = '2021/7/14'
	group by router_index, vehicle_index_code, driver_index_code, statistics_date -- = '96998634640a44a0819d9e85c7e5a758'
;


drop table if exists t_task1;


drop table if exists t_task1_tab;
-- 需要一个事件的主键...
create table t_task1_tab(
   router_id serial NOT NULL,
   statistics_date varchar, 
   t_attendance_detail_id varchar,
   driver_index_code varchar, 
   vehicle_index_code varchar,
   driver_mileage varchar,
   driver_time varchar,
   online_time varchar,
   drive_start_time varchar,
   drive_end_time varchar,
   PRIMARY KEY ( router_id )
);

insert into t_task1_tab(
   statistics_date , 
   t_attendance_detail_id, 
   driver_index_code , 
   vehicle_index_code ,
   driver_mileage ,
   driver_time,
   online_time, 
   drive_start_time ,
   drive_end_time
)
select 
		time_p.statistics_date, 
		time_p.t_attendance_detail_id,
		time_p.driver_index_code,
		time_p.vehicle_index_code,
		all_p.driver_mileage,
		all_p.driver_time,
		all_p.online_time,
		drive_start_time,
		drive_end_time
	from t_attendance_time_period as time_p, t_attendance_statistics as all_p
	where 
		time_p.vehicle_index_code = all_p.vehicle_index_code and
		time_p.driver_index_code = all_p.driver_index_code and 
		time_p.statistics_date = all_p.statistics_date and 
		driver_time > 0 -- and
		-- abs(time_p.drive_period - all_p.driver_time) <= 3600 -- 误差不超过1个小时？
		; 
