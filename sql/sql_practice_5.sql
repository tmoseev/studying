--=============== ������ 6. POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� SQL-������, ������� ������� ��� ���������� � ������� 
--�� ����������� ��������� "Behind the Scenes".
select film_id, title, replacement_cost, rating 
from film
where array['Behind the Scenes'] <@ special_features 
order by film_id 



--������� �2
--�������� ��� 2 �������� ������ ������� � ��������� "Behind the Scenes",
--��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.

select film_id, title, replacement_cost, rating 
from film
where array['Behind the Scenes'] && special_features 
order by film_id 


select film_id, title, replacement_cost, rating 
from film
where 'Behind the Scenes' = any(special_features) 
order by film_id 

--������� �3
--��� ������� ���������� ���������� ������� �� ���� � ������ ������� 
--�� ����������� ��������� "Behind the Scenes.

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, 
--���������� � CTE. CTE ���������� ������������ ��� ������� �������.

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

--������� �4
--��� ������� ���������� ���������� ������� �� ���� � ������ �������
-- �� ����������� ��������� "Behind the Scenes".

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1,
--���������� � ���������, ������� ���������� ������������ ��� ������� �������.

select *
from (select customer_id, count(rental_id)
	from rental
	join customer using (customer_id)
	join inventory using (inventory_id)
	join film using (film_id)
	where array['Behind the Scenes'] <@ special_features
	group by customer_id) t4
order by customer_id 


--������� �5
--�������� ����������������� ������������� � �������� �� ����������� �������
--� �������� ������ ��� ���������� ������������������ �������������

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


--������� �6
--� ������� explain analyze ��������� ������ �������� ���������� ��������
-- �� ���������� ������� � �������� �� �������:
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


--1. ����� ���������� ��� �������� ����� SQL, ������������ ��� ���������� ��������� �������, 
--   ����� �������� � ������� ���������� �������
--2. ����� ������� ���������� �������� �������: 
--   � �������������� CTE ��� � �������������� ����������

--������������� ��������� where � ������� 1-2 c ���������� ��������� ��� �������� ��� ��������� (&&, <@) ��� ��������, ��� � � ���������� ��������� � ������� ��������� ������� 90-93 cost.
--������������� �te ��� ���������� ��� ������� 3-4 ��������� � ����������� ������� ���������� ������� � 1486 cost



--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� � ����� ������ �� ����� ���������

--������� �2
--��������� ������� ������� �������� ��� ������� ����������
--�������� � ����� ������ ������� ����� ����������.

--���� ��������� �� ��������



--������� �3
--��� ������� �������� ���������� � �������� ����� SQL-�������� ��������� ������������� ����������:
-- 1. ����, � ������� ���������� ������ ����� ������� (���� � ������� ���-�����-����)
-- 2. ���������� ������� ������ � ������ � ���� ����
-- 3. ����, � ������� ������� ������� �� ���������� ����� (���� � ������� ���-�����-����)
-- 4. ����� ������� � ���� ����




