
-- Drop table

DROP table if exists  public.t_risk_accessment_result;

CREATE TABLE public.t_risk_accessment_result (
	statistics_date varchar NULL,
	vehicle_index_code varchar NULL,
	driver_index_code varchar NULL,
	driver_time varchar NULL,
	online_time varchar NULL,
	driver_mileage varchar NULL,
	attendance_detail_id varchar NULL,
	begin_time varchar NULL,
	end_time varchar NULL,
	event_type int8 NULL,
	"name" varchar NULL,
	event_num int4 NULL,
	"percent" float4 NULL
);

insert into t_risk_accessment_result
select 
	t_1.statistics_date,
	t_2.vehicle_index_code,
	t_2.driver_index_code,
	t_1.driver_time,
	t_1.online_time,
	t_1.driver_mileage,
	t_1.t_attendance_detail_id,
	t_1.drive_start_time,
	t_1.drive_end_time,
	t_2.event_type,
	t_3."name",
	t_2.cur_type_sum,
	(t_2.cur_type_sum::float * 1.0/ t_1.driver_mileage::float) * 100000
from 
	t_task1_tab as t_1, 
	t_device_alarm_category as t_2,
	t_alarm_basic_config as t_3
where 
	t_1.router_id = t_2.router_id and
	t_2.event_type = t_3.event_type and 
	t_1.driver_mileage::integer > 0;
	




