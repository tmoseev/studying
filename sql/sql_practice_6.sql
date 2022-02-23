--1. � ����� ������� ������ ������ ���������?
--������ �������: ������� ��������� ���������� � ������ ������, ����������� �� ������, 
--���������� ��� ������ ��������� having 
select city, count(airport_name) as "���������� ����������"
from airports a 
group by city
having count(airport_name) > 1

--2. � ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?
--� ������� ����������� ������ ���� ����������� ���������
--������ �������: ����������� ������� flight � aircrafts ��� ��������� � ���, ����� ������� ����� ���� ���������.
--���������� �� ���� range, ��� ����������� ��������� ������������ ��������� ������ � ������� ���������

select departure_airport
from flights f 
join aircrafts a using (aircraft_code)
where "range" =
	(select max("range") from aircrafts)
group by departure_airport 


--3. ������� 10 ������ � ������������ �������� �������� ������
--������ �������: ������ ������������ ������� �������� ������ ����� ������ ����� actual_departure � scheduled_departure.
--��������� � ������� ���� ����� ������� ��� �� �������� ���������� where ��������� ������ ��������.
--��������� �������� limit ������ ���������� ���������� ������

select flight_id, (actual_departure - scheduled_departure) as "�������� ������"
from flights f 
where (actual_departure - scheduled_departure) is not null
order by "�������� ������" desc
limit 10



--4.���� �� �����, �� ������� �� ���� �������� ���������� ������?
--������ �������: ����� ���������������� join ������� �������������� ������� ���� ����� book_ref ������� ����� seat_no (���� ���� ����� �����, ������ ���������� ����� �����)
--������� �����, ������� �� ������ � �������������� ������� ��� ������ ���������� � ������� where

select book_ref
from bookings b
where book_ref not in (
select book_ref
from bookings b 
join tickets using (book_ref)
join ticket_flights tf using (ticket_no)
join boarding_passes bp on tf.ticket_no = bp.ticket_no and tf.flight_id = bp.flight_id 
)


--5. ������� ��������� ����� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
--������ �������: �������� ���� cte, ������� ������� ����� ���������� ���� � �������� ����� �������� ������ ������� � ����������� �� ��������.
--�������� ������ cte, ������� ������� ����������� ���������� ���� � �������� ����� �������� ���������� ������� ������� � �������, ��� ���� ��� �������� ���������� ���������� ����������
--����� ��������� ������ �� ����� ������� �������� (������� ����� ������� actual_departure)
--� �������� ������� �������� �������� ����� � ������ ���������� ���� � ���� numeric, �������� �� 100, ��������� ��� ������ ������� round
--�������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
--�.�. � ���� ������� ������ ���������� ������������� ����� - ������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ �� ����.
--��������� ������� ������� sum �� ������� � �������� ���������� ���������� � ���������� rows between unbounded preceding and current row 
--���������� � �������� ���������

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
select flight_id, aircraft_code, totalcount-factcount as "��������� �����" , round((totalcount::numeric-factcount::numeric)/totalcount::numeric,2)*100 || ' %' as "��������� ����� (%)",
departure_airport, scheduled_departure::date, sum(factcount) over (partition by departure_airport order by departure_airport, scheduled_departure::date rows between unbounded preceding and current row ) as "�������� ���������� �� ����"
from flights f
join total using (aircraft_code)
join fact using (flight_id)


--6. ������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.
--������ �������: �� ������� flight ������� ���������� ������ ��� ������� ��������, ����� ���������� ������
--�������� ����������� ����� �������� ����� ���������� ���������
--�������� � ���������, ���������, ����������, ���������
select aircraft_code, round(count(aircraft_code)/(select count(flight_id) from flights)::float *100) as "������� �������, %"
from flights f
group by aircraft_code
order by "������� �������, %"


--7. ���� �� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?
--������ �������: ������� cte ��� ������ ������ � �������� ������ ������������ ���� ��� ������� ��������
--���������� ������� cte ��� ������� ������ ������ ��� ������ ����������� ����, �������� �������� ������ � �������
--� ������� ���������� ��� cte ���������� � �������� ���������� ������, ����� �������� ����� ������ � �������
--��������� �� �������, ����� ���� ������� ������ ���� ������ ��� ��������.
--� ���������� �������� ������ ������. ����� �������, �������, � ������� ����� ���������� ������ ������� �������, ��� �������� � ����������� �� ���.

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



--8. ����� ������ �������� ��� ������ ������?
--������ �������: ������� �������������, � ������� ������������ ������ ����� �������� ���� �����
--� ������� ������ ��������� ������������ �������, �������� �������� ���������� ������
--���������� except ��������� ������ ����� �������� ���� ����� 

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


--9. ��������� ���������� ����� �����������, ���������� ������� �������, �������� � ���������� ������������ ���������� ���������  � ���������, ������������� ��� �����
--d = arccos {sin(latitude_a)�sin(latitude_b) + cos(latitude_a)�cos(latitude_b)�cos(longitude_a - longitude_b)},
-- ��� latitude_a � latitude_b � ������, longitude_a, longitude_b � ������� ������ �������, 
--d � ���������� ����� �������� ���������� � �������� ������ ���� �������� ����� ������� ����.
--���������� ����� ��������, ���������� � ����������, ������������ �� �������:
--L = d�R, ��� R = 6371 �� � ������� ������ ������� ����.
--������ �������: ���������� ������� ������� � �����������, ����� �������� ������ �� ������ � �������. 
--��� ������� ���������� � ������� ���������� �������� ������ � ������� � �������� ��� ������ ������� radians ��������� � �������
--��� ������ case ��������� ������� �������/�� �������

select departure_airport, arrival_airport, aircraft_code, "range",
round(acos(sin(radians(a1.latitude))*sin(radians(a2.latitude)) + cos(radians(a1.latitude))*cos(radians(a2.latitude))*cos(radians(a1.longitude-a2.longitude)))*6371) as "���������� ����� �����������",
case 
	when round(acos(sin(radians(a1.latitude))*sin(radians(a2.latitude)) + cos(radians(a1.latitude))*cos(radians(a2.latitude))*cos(radians(a1.longitude-a2.longitude)))*6371) < "range" then '�������'
	else '�� �������'
	end
from flights f 
join airports a1 on f.departure_airport = a1.airport_code
join airports a2 on f.arrival_airport = a2.airport_code
join aircrafts a using (aircraft_code)
group by  departure_airport, arrival_airport, a1.longitude, a1.latitude, a2.longitude, a2.latitude, aircraft_code, "range" 

