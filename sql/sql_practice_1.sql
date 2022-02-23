--=============== ������ 2. ������ � ������ ������ =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� �������� �� ������� �������

SELECT DISTINCT district FROM address


--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� �������, 
--�������� ������� ���������� �� "K" � ������������� �� "a", � �������� �� �������� ��������
SELECT DISTINCT district FROM address
where district like 'K%a' and district not like '% %'


--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ����� 2007 ���� �� 19 ����� 2007 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.

select payment_id, payment_date, amount from payment 
where payment_date between '2007-03-17' and '2007-03-20' and amount > 1
order by payment_date



--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.

select payment_id, payment_date, amount from payment 
order by payment_date desc limit 10


--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.

select concat(last_name,' ',first_name ) as "������� ���", 
email as "��.�����",
length(email) as "����� ���� email",
date_trunc('DAY', last_update)::DATE as "���� ���������� ����������"
from customer 

--

--������� �6
--�������� ����� �������� �������� �����������, ����� ������� Kelly ��� Willie.
--��� ����� � ������� � ����� �� ������� �������� ������ ���� ���������� � ������� �������.
select upper(first_name), upper(last_name) from customer 
where (first_name = 'Kelly' or first_name = 'Willie') and active = 1



--======== �������������� ����� ==============

--������� �1
--�������� ����� �������� ���������� � �������, � ������� ������� "R" 
--� ��������� ������ ������� �� 0.00 �� 3.00 ������������, 
--� ����� ������ c ��������� "PG-13" � ���������� ������ ������ ��� ������ 4.00.

select film_id, title, description, rating, rental_rate from film 
where rating = 'R' and rental_rate between 0 and 3.00 or 
rating = 'PG-13' and rental_rate >= 4.00


--������� �2
--�������� ���������� � ��� ������� � ����� ������� ��������� ������.

select film_id, title, description from film 
order by length(title) desc
limit 3


--������� �3
-- �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
--� ������ ������� ������ ���� ��������, ��������� �� @, 
--�� ������ ������� ������ ���� ��������, ��������� ����� @.

select customer_id, email,
substring(email from 0 for position('@' in email)) as "email before @",
substring(email from position('@' in email)+1 for length(email)) as "email after @"
from customer
order by customer_id


--������� �4
--����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
--������ ����� ������ ���� ���������, ��������� ���������.

select customer_id, email,
concat(upper(left(substring(email from 0 for position('@' in email)),1)),
substring(substring(email from 0 for position('@' in email)),2))
as "email before @",
concat(upper(left(substring(email from position('@' in email)+1 for length(email)),1)),
substring(substring(email from position('@' in email)+1 for length(email)),2))
as "email after @"
from customer
order by customer_id


