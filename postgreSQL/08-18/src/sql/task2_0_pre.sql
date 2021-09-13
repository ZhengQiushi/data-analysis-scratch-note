
drop function if exists check_per_event(varchar, varchar, bigint, varchar);


/*
 * @brief 判断该alarm event 是否属于该段行程（时间判断）
 * @return integer （某天某行程 event_type 的数量）
 * */
create or replace function check_per_event(
	drive_start_time varchar,
	drive_end_time varchar,
	event_type_ bigint,
	vehicle_index_code_ varchar
	)
returns integer as 
$func$
declare
var record;
begin
		-- 需要按照event_type
	return (
		select 
			-- 统计在时间范围内的数量 
			sum(case when 
					begin_time >= drive_start_time::timestamp 
					and begin_time <= drive_end_time::timestamp 
					then 1 else 0 END)
		from 
			-- 筛选表
			t_device_alarm_20210701 as alarm_d
			-- t_task1 as t_t1
		where 
			(
			-- 记录有效的标签
				alarm_d.label::jsonb @> '[{"labels": [{"key": "effective", "value": "0"}], "component": "irtsafedriving"}]'::jsonb 
				or  alarm_d.label is null
			)
			and alarm_d.vehicle_index_code = vehicle_index_code_ -- '000251c094c8417d870b7f1c72f540a1' 
			and alarm_d.event_type = event_type_
		);
end
$func$ language plpgsql;



/*
 * @brief 判断该alarm event 是否属于该段行程（时间判断）
 * @return integer （某天某行程 event_type 的数量）
 * */
create or replace function check_per_event_dynamic(
	drive_start_time varchar,
	drive_end_time varchar,
	event_type_ bigint,
	vehicle_index_code_ varchar, 
	statitic_date text
	)
returns integer as 
$func$
declare
result_ integer;
begin
		-- 需要按照event_type
	    execute format(
        'select 
			-- 统计在时间范围内的数量 
			sum(case when 
					begin_time >= $1::timestamp 
					and begin_time <= $2::timestamp 
					then 1 else 0 END)
		from 
			-- 筛选表
			t_device_alarm_%s as alarm_d
			-- t_task1 as t_t1
		where 
			(
			-- 记录有效的标签
				alarm_d.label::jsonb @> ''[{"labels": [{"key": "effective", "value": "0"}], "component": "irtsafedriving"}]''::jsonb 
				or  alarm_d.label is null
			)
			and alarm_d.vehicle_index_code = $3
			and alarm_d.event_type = $4
		',
        statitic_date)
        using drive_start_time, drive_end_time, vehicle_index_code_, event_type_
    	into result_;
		return result_;
end
$func$ language plpgsql;





