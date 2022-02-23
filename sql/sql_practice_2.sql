--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select 
customer.customer_id,
customer.first_name,
customer.last_name,
address.address,
city.city,
country.country 
from customer
inner join address on address.address_id = customer.address_id 
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id 


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select store_id, count(customer_id)
from customer
group by store_id


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select store_id, count(customer_id)
from customer
group by store_id
having count(customer_id) > 300



-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select store_id, count(customer_id) as "Количество покупателей", 
city.city as "Город",
concat_ws(' ', staff.first_name, staff.last_name) as "Продавец"
from customer
join store using (store_id)
join address on (address.address_id = store.address_id)
join city using (city_id)
join staff using (store_id)
group by store_id, city.city, staff.first_name, staff.last_name
having count(customer_id) > 300 



--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select 
customer_id,
count(rental_id) as "rent"
from payment p 
group by customer_id
order by rent desc 
limit 5


select 
customer_id,
count(rental_id) as "rent"
from rental r 
group by customer_id 
order by rent desc 
limit 5



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select 
concat_ws(' ', customer.last_name, customer.first_name) as "Фамилия и имя покупателя", 
count(rental_id) as "Количество фильмов",
round(sum(amount)) as "Сумма платежей",
min(amount) as "Минимальное значение аренды",
max(amount) as "Максимальное значение аренды"
from payment p 
join customer using (customer_id)
group by customer_id


--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
select 
c1.city as "Город 1", c2.city as "Город 2"
from city as c1
cross join city as c2
where c1.city != c2.city



--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
select customer_id, round(avg(return_date::DATE - rental_date::DATE)) as "Среднее время аренды (дней)"
from rental 
group by customer_id 




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select inventory.film_id, count(inventory.film_id) as "Количество раз проката", 
sum(payment.amount) as "Общая стоимость арены"
from rental 
join inventory using (inventory_id) 
join payment using(customer_id)
group by film_id


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.
select title, rating, release_year, 
category.name, language.name
from film
join film_category using (film_id)
join category using (category_id)
join "language" using (language_id)
where film_id not in 
		(select distinct inventory.film_id
		from rental
		join inventory using (inventory_id))	



--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select staff_id, count(payment_id),
	case 
		when count(payment_id) > 7300 then 'Да'
		else 'Нет'
	end
from payment
group by staff_id 
