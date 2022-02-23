--1. В каких городах больше одного аэропорта?
--Логика запроса: подсчет количесва аэропортов в каждом городе, группировка по городу, 
--фильтрация при помощи оператора having 
select city, count(airport_name) as "Количество аэропортов"
from airports a 
group by city
having count(airport_name) > 1

--2. В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
--В решении обязательно должно быть использован подзапрос
--Логика запроса: объединение таблицы flight с aircrafts для понимания о том, какой самолет какой рейс выполняет.
--Фильтрация по полю range, где подзапросом находится максимальная дальность полета в таблице самолетов

select departure_airport
from flights f 
join aircrafts a using (aircraft_code)
where "range" =
	(select max("range") from aircrafts)
group by departure_airport 


--3. Вывести 10 рейсов с максимальным временем задержки вылета
--Логика запроса: Расчет фактического времени задержки вылета путем вычета полей actual_departure и scheduled_departure.
--Поскольку в таблице есть рейсы которые еще не вылетили оператором where исключаем пустые значения.
--Используя оператор limit задаем необхоимое количество рейсов

select flight_id, (actual_departure - scheduled_departure) as "Задержка вылета"
from flights f 
where (actual_departure - scheduled_departure) is not null
order by "Задержка вылета" desc
limit 10



--4.Были ли брони, по которым не были получены посадочные талоны?
--Логика запроса: путем последовательных join получим результирующую таблицу того какой book_ref получил какой seat_no (если есть номер места, значит посадочный талон выдан)
--выведем брони, которые не попали в результирующую таблицу при помощи подзапроса в условии where

select book_ref
from bookings b
where book_ref not in (
select book_ref
from bookings b 
join tickets using (book_ref)
join ticket_flights tf using (ticket_no)
join boarding_passes bp on tf.ticket_no = bp.ticket_no and tf.flight_id = bp.flight_id 
)


--5. Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
--Логика запроса: создадим одно cte, которое считает общее количество мест в самолете путем подсчета номера сидения и группировки по самолету.
--создадим второе cte, которое считает фактическое заполнение мест в самолете путем подсчета количества номеров сидений в билетах, при этом для подсчета количества вывезенных пассажиров
--нужно учитывать только те рейсы которые вылетели (которые имеют колонку actual_departure)
--в итоговом расчете приводим значения факта и общего количества мест к типу numeric, умножаем на 100, округляем при помощи функции round
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.
--Применяем оконную функцию sum на столбец с подчетом вылетевших пассажиров с параметром rows between unbounded preceding and current row 
--Группируем и получаем результат

with total as (
	select aircraft_code, count(seat_no) as totalcount 
	from seats s 
	group by aircraft_code),
	fact as (
	select flight_id, count(seat_no) as factcount
	from boarding_passes bp 
	join flights f using (flight_id)
	where actual_departure is not null
	group by flight_id)
select flight_id, aircraft_code, totalcount-factcount as "Свободные места" , round((totalcount::numeric-factcount::numeric)/totalcount::numeric,2)*100 || ' %' as "Свободные места (%)",
departure_airport, scheduled_departure::date, sum(factcount) over (partition by departure_airport order by departure_airport, scheduled_departure::date rows between unbounded preceding and current row ) as "Вывезено пассажиров за день"
from flights f
join total using (aircraft_code)
join fact using (flight_id)


--6. Найдите процентное соотношение перелетов по типам самолетов от общего количества.
--Логика запроса: из таблицы flight считаем количество рейсов для каждого самолета, общее количество рейсов
--получаем подзапросом путем подсчета общее количества перелетов
--Выражаем в процентах, округляем, группируем, сортируем
select aircraft_code, round(count(aircraft_code)/(select count(flight_id) from flights)::float *100) as "Процент полетов, %"
from flights f
group by aircraft_code
order by "Процент полетов, %"


--7. Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
--Логика запроса: создаем cte для эконом класса с функцией поиска максимальной цены для каждого перелета
--аналогично создаем cte для бизнесс класса только для поиска минимальной цены, добавляя аэропрот вылета и прилета
--в запросе объединяем два cte объединяем с таблицей аэропортов дважды, чтобы получить город вылета и прилета
--фильтруем по условию, чтобы цена бизнесс класса была меньше чем экономом.
--В результате получаем пустой запрос. Таким образом, городов, в которые можно добравться бизнес классом дешевше, чем экономом в исследуемой БД нет.

with econ as(
select flight_id, fare_conditions, amount, max(amount) over (partition by flight_id, fare_conditions)
from ticket_flights tf 
join flights f using (flight_id)
group by flight_id, fare_conditions, amount
having fare_conditions = 'Economy'),
buss as(
select flight_id, fare_conditions, amount, departure_airport, arrival_airport, min(amount) over (partition by flight_id, fare_conditions)
from ticket_flights tf 
join flights f using (flight_id)
group by flight_id, fare_conditions, amount, departure_airport, arrival_airport
having fare_conditions = 'Business')
select flight_id, a1.city, a2.city
from econ
join buss using (flight_id)
join airports a1 on departure_airport = a1.airport_code
join airports a2 on arrival_airport = a2.airport_code
where econ.max > buss.min



--8. Между какими городами нет прямых рейсов?
--Логика запроса: создаем представление, в котором отображаются города между которыми есть рейсы
--В запросе делаем декартово произведение городов, фильтром искючаем одинаковые города
--оператором except исключаем города между которыми есть рейсы 

create view t8 as
select a1.city a1city, a2.city a2city
from flights f 
join airports a1 on f.departure_airport = a1.airport_code
join airports a2 on f.arrival_airport = a2.airport_code
group by a1.city, a2.city

select a1.city, a2.city
from airports a1
cross join airports a2
where a1.city != a2.city
except
select a1city, a2city
from t8


--9. Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы
--d = arccos {sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a - longitude_b)},
-- где latitude_a и latitude_b — широты, longitude_a, longitude_b — долготы данных пунктов, 
--d — расстояние между пунктами измеряется в радианах длиной дуги большого круга земного шара.
--Расстояние между пунктами, измеряемое в километрах, определяется по формуле:
--L = d·R, где R = 6371 км — средний радиус земного шара.
--Логика запроса: объединяем таблицу полетов с аэропортами, чтобы получить данные по широте и долготе. 
--Для расчета расстояния в формуле необходимы значения широты и долготы в радианах при помощи функции radians переводим в радианы
--при помощи case добавляем столбец долетит/не долетит

select departure_airport, arrival_airport, aircraft_code, "range",
round(acos(sin(radians(a1.latitude))*sin(radians(a2.latitude)) + cos(radians(a1.latitude))*cos(radians(a2.latitude))*cos(radians(a1.longitude-a2.longitude)))*6371) as "Расстояние между аэропортами",
case 
	when round(acos(sin(radians(a1.latitude))*sin(radians(a2.latitude)) + cos(radians(a1.latitude))*cos(radians(a2.latitude))*cos(radians(a1.longitude-a2.longitude)))*6371) < "range" then 'Долетит'
	else 'Не долетит'
	end
from flights f 
join airports a1 on f.departure_airport = a1.airport_code
join airports a2 on f.arrival_airport = a2.airport_code
join aircrafts a using (aircraft_code)
group by  departure_airport, arrival_airport, a1.longitude, a1.latitude, a2.longitude, a2.latitude, aircraft_code, "range" 

