
use SCHEMA "INTERVIEW_DB"."PLAYGROUND_GAUTHAM_K";
create table demo_country
(
  country_id INT IDENTITY(1,1),
  country_name varchar(100)
)
insert into demo_country values (1,'INDONESIA');

SELECT * FROM demo_country;

create table demo_island
(
  island_id INT IDENTITY(1,1),
  country_id int,
  island_name varchar(100)
)
insert into demo_island
select row_number() over (order by island) rn,* from (
select distinct 1, island from "FIVETRAN_INTERVIEW_DB"."GOOGLE_SHEETS"."COVID_19_INDONESIA_GAUTHAM_K");


create table demo_province
(
  province_id INT IDENTITY(1,1),
  country_id int,
  island_id int,
  province_name varchar(100),
  iso_code varchar(50),
  time_zone varchar(50),
  area int,
  area_bucket varchar(50),
population_density decimal(19,2),
pop_den_bucket varchar(50),
population int,
pop_bucket varchar(50),
total_regencies int,
total_cities int,
total_districts int,
total_rural_villages int,
total_urban_villages int,
urbanization_per decimal(19,2),
lat_lon varchar(100)
);

insert into demo_province
select row_number() over (order by island_id,province) rn,* from (
select distinct 1,ilnd.island_id,province,location_iso_code,time_zone, area_km_2_ as area,
   case 
when area_km_2_ < 31000 then 'small' 
when area_km_2_ between 31000 and 51000 
then 'medium' 
else 'large' 
end area_bucket,
population_density,
   case 
when population_density < 100 then 'low' 
when population_density between 100 and 500 
then 'medium' 
else 'high' 
end pop_den_bucket,
population,
    case 
when population < 4000000 then 'low' 
when population between 4000000 and 9000000 
then 'medium' 
else 'high' 
end pop_bucket,
total_regencies,
total_cities,
total_districts,
total_rural_villages,
total_urban_villages,
round((total_urban_villages / total_rural_villages)*100,2) urbanization_per,
concat(latitude,',',longitude) lat_lon
from "FIVETRAN_INTERVIEW_DB"."GOOGLE_SHEETS"."COVID_19_INDONESIA_GAUTHAM_K" src
left join demo_island ilnd
on ilnd.island_name=src.island);

select * from demo_province;

use SCHEMA "INTERVIEW_DB"."PLAYGROUND_GAUTHAM_K";
create table date_info as 
WITH CTE_MY_DATE AS (
SELECT DATEADD(HOUR, SEQ4(), '2018-01-01 00:00:00') AS MY_DATE
FROM TABLE(GENERATOR(ROWCOUNT=>20000))
)
SELECT row_number() over (order by TO_DATE(MY_DATE))date_id,
TO_DATE(MY_DATE) as date
,YEAR(MY_DATE) as year
,MONTH(MY_DATE) as month
,MONTHNAME(MY_DATE) as monthname
,DAYOFWEEK(MY_DATE) as dayofweek
,DAYNAME(MY_DATE) as dayname
,WEEKOFYEAR(MY_DATE) as weekofyear
FROM CTE_MY_DATE
;
select * from date_info;

create table recovered_info as 
select 
date_id,
case when province_id is null then 99 else province_id end province_id,
new_recovered,
total_recovered,
case_recovered_rate
from "FIVETRAN_INTERVIEW_DB"."GOOGLE_SHEETS"."COVID_19_INDONESIA_GAUTHAM_K" src
left join demo_province dp
on dp.province_name=src.province
left join date_info di
on to_date(src.date)=di.date;


drop table cases_info as 
select 
date_id,
case when province_id is null then 99 else province_id end province_id,
new_cases,
total_cases,
new_active_cases,
new_cases_per_million,
total_active_cases,
total_cases_per_million,
growth_factor_of_new_cases
from "FIVETRAN_INTERVIEW_DB"."GOOGLE_SHEETS"."COVID_19_INDONESIA_GAUTHAM_K" src
left join demo_province dp
on dp.province_name=src.province
left join date_info di
on to_date(src.date)=di.date;

create table deaths_info as 
select 
date_id,
case when province_id is null then 99 else province_id end province_id,
new_deaths,
total_deaths,
new_deaths_per_million,
total_deaths_per_million,
growth_factor_of_new_deaths,
case_fatality_rate
from "FIVETRAN_INTERVIEW_DB"."GOOGLE_SHEETS"."COVID_19_INDONESIA_GAUTHAM_K" src
left join demo_province dp
on dp.province_name=src.province
left join date_info di
on to_date(src.date)=di.date;
