--=============== ������ 4. ���������� � SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--���� ������: ���� ����������� � �������� ����, �� �������� ����� ������� � �������:
--�������_�������, 
--���� ����������� � ���������� ��� ���������� �������, �� �������� ����� ����� � � ��� �������� �������.


-- ������������� ���� ������ ��� ��������� ���������:
-- 1. ���� (� ������ ����������, ����������� � ��)
-- 2. ���������� (� ������ �������, ���������� � ��)
-- 3. ������ (� ������ ������, �������� � ��)



--������� ���������:
-- �� ����� ����� ����� �������� ��������� �����������
-- ���� ���������� ����� ������� � ��������� �����
-- ������ ������ ����� �������� �� ���������� �����������

 
--���������� � ��������-������������:
-- ������������� �������� ������ ������������� ���������������
-- ������������ ��������� �� ������ ��������� null �������� � �� ������ ����������� ��������� � ��������� ���������
 
--�������� ������� �����
CREATE SCHEMA moseev

create table language (
language_id serial primary key,
language varchar (50) unique not null
) 


--�������� ������ � ������� �����

insert into language (language)
values
('����������'),
('����������'),
('�������'),
('��������'),
('���������'),
('�����������')


--�������� ������� ����������
create table nation(
nation_id serial primary key,
nation varchar (50) unique not null
)



--�������� ������ � ������� ����������

insert into nation (nation)
values
('���������'),
('��������'),
('�������'),
('�����'),
('�������'),
('���������')

--�������� ������� ������

create table country(
country_id serial primary key,
country varchar (50) unique not null
)


--�������� ������ � ������� ������

insert into country (country)
values
('������'),
('�������'),
('������'),
('��������'),
('�������'),
('������')


--�������� ������ ������� �� �������
create table country_nation (
id serial,
country_id integer references country(country_id),
nation_id integer references nation(nation_id),
primary key (id, country_id, nation_id)
)


--�������� ������ � ������� �� �������
insert into country_nation (country_id, nation_id)
values
(1,1),
(1,2),
(1,4),
(2,2),
(3,3),
(4,4),
(5,5),
(5,6),
(6,6)


--�������� ������ ������� �� �������

create table language_nation (
id serial,
country_id integer references country(country_id),
language_id integer references language(language_id),
primary key (id, country_id, language_id)
)


--�������� ������ � ������� �� �������
insert into language_nation (country_id, language_id)
values
(1,1),
(1,5),
(2,2),
(2,1),
(3,3),
(3,5),
(3,6),
(4,4),
(5,5),
(6,6),
(6,3)



--======== �������������� ����� ==============


--������� �1 
--�������� ����� ������� film_new �� ���������� ������:
--�   	film_name - �������� ������ - ��� ������ varchar(255) � ����������� not null
--�   	film_year - ��� ������� ������ - ��� ������ integer, �������, ��� �������� ������ ���� ������ 0
--�   	film_rental_rate - ��������� ������ ������ - ��� ������ numeric(4,2), �������� �� ��������� 0.99
--�   	film_duration - ������������ ������ � ������� - ��� ������ integer, ����������� not null � �������, ��� �������� ������ ���� ������ 0
--���� ��������� � �������� ����, �� ����� ��������� ������� ������� ������������ ����� �����.

create table film_new(
film_name varchar(255) not null,
film_year integer check (film_year > 0),
film_rental_rate numeric (4,2) default 0.99,
film_duration integer not null check (film_duration > 0))

--������� �2 
--��������� ������� film_new ������� � ������� SQL-�������, ��� �������� ������������� ������� ������:
--�       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--�       film_year - array[1994, 1999, 1985, 1994, 1993]
--�       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--�   	  film_duration - array[142, 189, 116, 142, 195]

insert into film_new
values(
unnest(array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']),
unnest(array[1994, 1999, 1985, 1994, 1993]),
unnest(array[2.99, 0.99, 1.99, 2.99, 3.99]),
unnest(array[142, 189, 116, 142, 195]))



--������� �3
--�������� ��������� ������ ������� � ������� film_new � ������ ����������, 
--��� ��������� ������ ���� ������� ��������� �� 1.41
update film_new 
set film_rental_rate = film_rental_rate + 1.41


--������� �4
--����� � ��������� "Back to the Future" ��� ���� � ������, 
--������� ������ � ���� ������� �� ������� film_new
delete from film_new 
where film_name = 'Back to the Future'


--������� �5
--�������� � ������� film_new ������ � ����� ������ ����� ������
insert into film_new 
values('Batman', 1989, 3.4, 126)


--������� �6
--�������� SQL-������, ������� ������� ��� ������� �� ������� film_new, 
--� ����� ����� ����������� ������� "������������ ������ � �����", ���������� �� �������
select *, round(film_duration/60::numeric, 1) as "������������ ������ � �����" 
from film_new fn 


--������� �7 
--������� ������� film_new
drop table film_new restrict