--=============== ������ 3. ������ SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.

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


--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.

select store_id, count(customer_id)
from customer
group by store_id


--����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.

select store_id, count(customer_id)
from customer
group by store_id
having count(customer_id) > 300



-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
--� ����� ������� � ��� ��������, ������� �������� � ���� ��������.

select store_id, count(customer_id) as "���������� �����������", 
city.city as "�����",
concat_ws(' ', staff.first_name, staff.last_name) as "��������"
from customer
join store using (store_id)
join address on (address.address_id = store.address_id)
join city using (city_id)
join staff using (store_id)
group by store_id, city.city, staff.first_name, staff.last_name
having count(customer_id) > 300 



--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������

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



--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������

select 
concat_ws(' ', customer.last_name, customer.first_name) as "������� � ��� ����������", 
count(rental_id) as "���������� �������",
round(sum(amount)) as "����� ��������",
min(amount) as "����������� �������� ������",
max(amount) as "������������ �������� ������"
from payment p 
join customer using (customer_id)
group by customer_id


--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
 --����� � ���������� �� ���� ��� � ����������� ���������� �������. 
 --��� ������� ���������� ������������ ��������� ������������.
select 
c1.city as "����� 1", c2.city as "����� 2"
from city as c1
cross join city as c2
where c1.city != c2.city



--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.
select customer_id, round(avg(return_date::DATE - rental_date::DATE)) as "������� ����� ������ (����)"
from rental 
group by customer_id 




--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� ������ ������� ��� ��� ����� � ������ � �������� ����� ��������� ������ ������ �� �� �����.
select inventory.film_id, count(inventory.film_id) as "���������� ��� �������", 
sum(payment.amount) as "����� ��������� �����"
from rental 
join inventory using (inventory_id) 
join payment using(customer_id)
group by film_id


--������� �2
--����������� ������ �� ����������� ������� � �������� � ������� ������� ������, ������� �� ���� �� ����� � ������.
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



--������� �3
--���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� "������".
--���� ���������� ������ ��������� 7300, �� �������� � ������� ����� "��", ����� ������ ���� �������� "���".
select staff_id, count(payment_id),
	case 
		when count(payment_id) > 7300 then '��'
		else '���'
	end
from payment
group by staff_id 
