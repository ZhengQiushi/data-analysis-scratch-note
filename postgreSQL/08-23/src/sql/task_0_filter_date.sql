
create or replace function check_date(
	record_time timestamp,
	which_month timestamp
)
returns integer as 
$func$
declare 
	result_ integer;
begin
	select (case when
			which_month <= record_time 
			and record_time < which_month + '1 month'
			then 1 else 0 end)
			into result_;
	return result_;
end

$func$ language plpgsql;



create or replace function return_date(
	record_time varchar
)
returns varchar as 
$func$
declare 
	result_ varchar;
begin
	select 
		split_part(record_time ,' ', 1)
	into result_;
	return result_;
end



$func$ language plpgsql;

drop table if exists ods_july_only;

-- create table ods_july_only as 
	select 
		*,
		return_date(shch_rqsj::varchar) as stastics_date
	from 
		ods_wyc_ordermatch_merge
	where 
		check_date(shch_rqsj, '2021-07-01 0:0:0'::timestamp) = 1
	 	and return_date(shch_rqsj::varchar) = '2021-07-01';
	