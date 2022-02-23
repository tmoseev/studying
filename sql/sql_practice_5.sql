--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
select film_id, title, replacement_cost, rating 
from film
where array['Behind the Scenes'] <@ special_features 
order by film_id 



--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

select film_id, title, replacement_cost, rating 
from film
where array['Behind the Scenes'] && special_features 
order by film_id 


select film_id, title, replacement_cost, rating 
from film
where 'Behind the Scenes' = any(special_features) 
order by film_id 

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

with cte3 as(
select customer_id, count(rental_id)
	from rental
	join customer using (customer_id)
	join inventory using (inventory_id)
	join film using (film_id)
	where array['Behind the Scenes'] <@ special_features
	group by customer_id)
select *
from cte3
order by customer_id 

--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

select *
from (select customer_id, count(rental_id)
	from rental
	join customer using (customer_id)
	join inventory using (inventory_id)
	join film using (film_id)
	where array['Behind the Scenes'] <@ special_features
	group by customer_id) t4
order by customer_id 


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view task5 as 
	select *
	from (select customer_id, count(*) over (partition by customer_id)
		from rental
		join customer using (customer_id)
		join inventory using (inventory_id)
		join film using (film_id)
		where array['Behind the Scenes'] <@ special_features) t4
	group by customer_id, t4.count
	order by customer_id 
with no data

refresh materialized view task5 


--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:
explain analyze
select film_id, title, replacement_cost, rating 
from film
where array['Behind the Scenes'] <@ special_features 
order by film_id 
--Sort  (cost=90.90..92.25 rows=538 width=30) (actual time=0.459..0.474 rows=538 loops=1)


explain analyze 
select film_id, title, replacement_cost, rating 
from film
where array['Behind the Scenes'] && special_features 
order by film_id 
--Sort  (cost=90.90..92.25 rows=538 width=30) (actual time=0.473..0.489 rows=538 loops=1)

explain analyze 
select * 
	from (
	select film_id, title, replacement_cost, rating, array['Behind the Scenes'] && special_features as bts
	from film
	) a
where bts = true 
order by film_id 
--Sort  (cost=92.25..93.59 rows=538 width=31) (actual time=2.101..2.171 rows=538 loops=1)



explain analyze 
with cte3 as(
select customer_id, count(*) over (partition by customer_id)
	from rental
	join customer using (customer_id)
	join inventory using (inventory_id)
	join film using (film_id)
	where array['Behind the Scenes'] <@ special_features)
select *
from cte3
group by customer_id, cte3.count
--HashAggregate  (cost=1486.36..1572.68 rows=8632 width=12) (actual time=33.438..33.623 rows=599 loops=1)


explain analyze 
select *
from (select customer_id, count(*) over (partition by customer_id)
	from rental
	join customer using (customer_id)
	join inventory using (inventory_id)
	join film using (film_id)
	where array['Behind the Scenes'] <@ special_features) t4
group by customer_id, t4.count
--HashAggregate  (cost=1486.36..1572.68 rows=8632 width=12) (actual time=14.707..14.862 rows=599 loops=1)


--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

--Использование оператора where в задании 1-2 c различными функциями для действий над массивами (&&, <@) как отдельно, так и в подзапросе приводило к вермени выполения запроса 90-93 cost.
--Использование сte или подзапроса для заданий 3-4 приводило к одинаковому времени исполнения запроса в 1486 cost



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

--Были разобраны на вебинаре



--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день




