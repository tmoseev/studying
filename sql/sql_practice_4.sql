--=============== ������ 5. ������ � POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:
--	������������ ��� ������� �� 1 �� N �� ����
--	������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
--	���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ ���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������
--	������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� ���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
-- ����� ��������� �� ������ ����� ��������� SQL-������, � ����� ���������� ��� ������� � ����� �������.

--	������������ ��� ������� �� 1 �� N �� ����
select payment_id, customer_id, payment_date, row_number() over (order by payment_date)
from payment p


--	������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
select payment_id, customer_id, payment_date, row_number() over (partition by customer_id order by payment_date)
from payment p 


--	���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ ���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������
select payment_id, customer_id, payment_date, sum(amount) over (partition by customer_id order by payment_date, amount) as summary
from payment p 


--������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� ���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
select payment_id, customer_id, payment_date, amount, rank() over (partition by customer_id order by amount desc)
from payment p 


--������� �2
-- � ������� ������� ������� �������� ��� ������� ���������� ��������� ������� 
-- � ��������� ������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����.
select customer_id, payment_id, payment_date, amount, lag(amount, 1, 0.0) over (partition by customer_id order by payment_date) as last_amount
from payment p 

 

--������� �3
-- � ������� ������� ������� ����������, �� ������� ������ 
-- ��������� ������ ���������� ������ ��� ������ ��������.
select customer_id, payment_id, payment_date, amount, 
amount - lead(amount, 1, 0.0) over (partition by customer_id order by payment_date) as differences
from payment p 


--������� �4
-- � ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������.
select customer_id, payment_id, payment_date, amount
from (
	select 
	customer_id, payment_date, payment_id, amount, row_number() over (partition by customer_id order by payment_date desc) as rn
	from payment p  
) as t
where t.rn = 1


--======== �������������� ����� ==============

--������� �1
--� ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ���� 2007 ����
-- � ����������� ������ �� ������� ���������� � �� ������ ���� ������� (��� ����� �������) � ����������� �� ����.
 

select p.staff_id, payment_date::date, sum(sum(amount)) over (partition by p.staff_id order by payment_date::date)
from payment p
where date_trunc('month', payment_date) = '01.03.2007'
group by p.payment_date::date, p.staff_id
order by 1, 2


--������� �2
--10 ������ 2007 ���� � ��������� ��������� �����: ����������, ����������� ������ 100�� ������
-- ������� �������������� ������ �� ��������� ������.
-- � ������� ������� ������� �������� ���� �����������, ������� � ���� ���������� ����� �������� ������.

with tt as (
	select payment_id, customer_id, payment_date, amount, row_number() over (order by payment_date) as "payment_number"
	from payment p
	where payment_date::date = '2007-04-10'
	)
select tt.*, customer.first_name, customer.last_name
from tt
join customer using (customer_id)
where tt.payment_number % 100 = 0


--������� �3
--��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
-- 1. ����������, ������������ ���������� ���������� �������
-- 2. ����������, ������������ ������� �� ����� ������� �����
-- 3. ����������, ������� ��������� ��������� �����


with z1 as(
	select country, customer_id, count(rental_id) over (partition by customer_id), first_name, last_name
	from rental 
	join customer using (customer_id)
	join address using (address_id)
	join city using (city_id)
	join country using (country_id)
)
select country, concat_ws(' ', first_name, last_name) as "���������� ������������ ������ ��" 
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
select country, concat_ws(' ', first_name, last_name) as "���������� ������������ �����" 
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
select country, concat_ws(' ', first_name, last_name) as "���������� ��������� ������" 
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


