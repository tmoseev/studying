--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--	Пронумеруйте все платежи от 1 до N по дате
--	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
-- Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

--	Пронумеруйте все платежи от 1 до N по дате
select payment_id, customer_id, payment_date, row_number() over (order by payment_date)
from payment p


--	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
select payment_id, customer_id, payment_date, row_number() over (partition by customer_id order by payment_date)
from payment p 


--	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
select payment_id, customer_id, payment_date, sum(amount) over (partition by customer_id order by payment_date, amount) as summary
from payment p 


--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
select payment_id, customer_id, payment_date, amount, rank() over (partition by customer_id order by amount desc)
from payment p 


--ЗАДАНИЕ №2
-- С помощью оконной функции выведите для каждого покупателя стоимость платежа 
-- и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
select customer_id, payment_id, payment_date, amount, lag(amount, 1, 0.0) over (partition by customer_id order by payment_date) as last_amount
from payment p 

 

--ЗАДАНИЕ №3
-- С помощью оконной функции определите, на сколько каждый 
-- следующий платеж покупателя больше или меньше текущего.
select customer_id, payment_id, payment_date, amount, 
amount - lead(amount, 1, 0.0) over (partition by customer_id order by payment_date) as differences
from payment p 


--ЗАДАНИЕ №4
-- С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select customer_id, payment_id, payment_date, amount
from (
	select 
	customer_id, payment_date, payment_id, amount, row_number() over (partition by customer_id order by payment_date desc) as rn
	from payment p  
) as t
where t.rn = 1


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за март 2007 года
-- с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.
 

select p.staff_id, payment_date::date, sum(sum(amount)) over (partition by p.staff_id order by payment_date::date)
from payment p
where date_trunc('month', payment_date) = '01.03.2007'
group by p.payment_date::date, p.staff_id
order by 1, 2


--ЗАДАНИЕ №2
--10 апреля 2007 года в магазинах проходила акция: покупатель, совершивший каждый 100ый платеж
-- получал дополнительную скидку на следующую аренду.
-- С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.

with tt as (
	select payment_id, customer_id, payment_date, amount, row_number() over (order by payment_date) as "payment_number"
	from payment p
	where payment_date::date = '2007-04-10'
	)
select tt.*, customer.first_name, customer.last_name
from tt
join customer using (customer_id)
where tt.payment_number % 100 = 0


--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм


with z1 as(
	select country, customer_id, count(rental_id) over (partition by customer_id), first_name, last_name
	from rental 
	join customer using (customer_id)
	join address using (address_id)
	join city using (city_id)
	join country using (country_id)
)
select country, concat_ws(' ', first_name, last_name) as "Покупатель арендовавший больше вс" 
from z1
group by z1.customer_id, z1.country, z1.count, z1.first_name, z1.last_name
order by country


with z2 as (
	select country, customer_id, sum(amount) over (partition by customer_id), first_name, last_name
	from payment
	join customer using (customer_id)
	join address using (address_id)
	join city using (city_id)
	join country using (country_id)
)
select country, concat_ws(' ', first_name, last_name) as "Покупатель максимальная сумма" 
from z2
group by z2.customer_id, z2.country, z2.sum, z2.first_name, z2.last_name
order by country


with z3 as(
	select country, customer_id, rental_date, first_name, last_name, row_number() over (partition by country order by rental_date desc)
	from rental 
	join customer using (customer_id)
	join address using (address_id)
	join city using (city_id)
	join country using (country_id)
)
select country, concat_ws(' ', first_name, last_name) as "Покупатель последняя аренда" 
from z3
where z3.row_number = 1



with c1 as (
group by customer_id, payment_id, payment_date),
c2 as (
	select customer_id, country_id,
		row_number () over (partition by country_id order by count desc) cf,
		row_number () over (partition by country_id order by sum desc) sa,
		row_number () over (partition by country_id order by max desc) md
	from c1
)
select c.country, c_1.customer_id, c_2.customer_id, c_3.customer_id
from country c
left join c2 c_1 on c_1.country_id = c.country_id and c_1.cf = 1
left join c2 c_2 on c_2.country_id = c.country_id and c_2.sa = 1
left join c2 c_3 on c_3.country_id = c.country_id and c_3.md = 1
order by 1


