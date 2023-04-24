CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
delete from activity;
insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');

--The activity table shows the app installed and app purchased activities for spotify app along with country details

select * from activity

--1. find total active users each day 
select event_date,count(distinct user_id)as active_users
from activity
group by event_date

--2. find total active users each week
select datepart(week,event_date)as wk,count(distinct user_id)as active_users
from activity
group by datepart(week,event_date)

--3. date wise total number of users who made the purchase same day they installed the app

select event_date,count(new_user) as no_of_users from(
select user_id,event_date, case when count(distinct event_name)=2 then user_id else null end as new_user
from activity
group by user_id,event_date

)a
group by event_date

--4. percentage of paid users in India,USA and any other country should be tagged as others

with cte as(
select 
case when country in('India','USA') then country else 'others'end as country, count(user_id) as perc
from
activity 
where event_name='app-purchase'
group by case when country in('India','USA') then country else 'others'end
),
total as(
select sum(perc)as total_count from cte)
select country, 1.0*perc/total_count *100 as perc_users
 from cte,total

 --5 Among all the users who installed the app on given day,how many did in app purchase on the very next day, output day wise
 --result

 with prev_data as(
 select *,
 lag(event_date) over(partition by user_id order by event_date) as prev_date,
 lag(event_name) over(partition by user_id order by event_date) as prev_event
 from activity)

 select event_date, count(case when event_name='app-purchase' 
 and prev_event='app-installed' and datediff(day,prev_date,event_date)=1 then user_id else null end) as cnt_users
 from prev_data
 group by event_date