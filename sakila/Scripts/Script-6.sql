/**
 * 조건식 
 * 
 * case 표현식 문법
 * 
 * case
 * 	when 조건 then 반환할 표현식
 * 	when 조건2 then 반환할 표현식2
 *  else 반환할 표현식3
 * end 
 * 
 * case 표현식의 장점
 * 	- sql 표준(sql 92) 대부분의 데이터베이스 제품에 구현되어 있다.
 *  - select, insert, update, delete 에서 사용 가능
 * 
 */


/*
 * 고객정보 조회. 활성화 고객, 비활성화 고객을 구분해서 출력.
 * 
 * customer.active : 1 : 활성화 고객(active)
 * 					 0 : 활성화 고객(inactive)
 */

desc customer ;

select first_name, last_name , active
from customer c;

select first_name, last_name,
		case /* 조건식 시작 */
			when active = 1 then 'ACTIVE'
			else 'INACTIVE'
		end active_type /* 조건식 끝 */
from customer c 


/*
 * 활성화 고객에 대해서는 대여횟수가 출력이 되도록하고,
 * 비활성화 고객에 대해서는 대여횟수가 0이 출력이 되도록 sql작성
 * first_name, last_name, 대여횟수 로 출력이 되도록 한다.
 * 단, case 표현식을 사용.
 * 
 * 사용 테이블 : customer, rental
 * 대여 횟수 계산 : active = 0, 0으로 출력
 * 				 active = 1, rental table 상관관계 조건
 * 
 * Main query : customer table 지정.
 * Sub query : 스칼라 Sub query 내에 대여 횟수 계산 처리
 * 
 * */

/* 강의 */

select c.first_name , c.last_name,
case 
	when active = 0 then 0
	else (
			select count(*)
			from rental r 
			where r.customer_id = c.customer_id
		)
end tot_rental_cnt
from customer c 




/* 내꺼 */
select first_name , last_name,
case 
	when c.active = 0 then '0'
	else count(c.customer_id)
end rental_cnt
from customer c inner join rental r on r.customer_id = c.customer_id 
group by c.customer_id

/*
 * 2005 년 5월, 6월, 7월 의 영화 대여 횟수를 출력하는 sql 작성
 * 조회 결과는 대여월, 대여횟수로 출력이 되도록 하고,
 * 단, case 표현식을 사용한 경우와 사용하지 않은 경우 모두 sql로 작성.
 * 
 * 그리고 case 표현식을 사용하지 않은 경우 결과는 3행으로 출력되도록 하고,
 * case 표현식을 사용한 경우는 1행으로 5월, 6월, 7월 의 월별 영화 대여 횟수가 출력이 되도록 한다.
 * 
 * 1. case 표현식을 사용하지 않은 경우
 * 
 * 2. case 표현식을 사용한 경우
 * 
 * 
 * 
 * */

/* 강의 */

/*
 * 1 번
 * 
 * 결과가 3rows 이다.
 * 2번에서 1 rows가 되도록 수정
 * 
 */

select monthname(rental_date), count(*)
from rental r 
where rental_date between '2005-05-01' and '2005-08-01'
group by monthname(rental_date)



/* 2 번 */

/* 1단계 : 5월, 6월, 7월 에 대한 각 한건에 대한 대여정보 */
select monthname(rental_date), 1
from rental r
where rental_date between '2005-05-01' and '2005-08-01'

/* 2단계 : 5월에 대한 대여 정보만 sum이 되도록 */
select 
sum((
case when monthname(rental_date) = 'May' then 1 else 0 end)
) may_rental
from rental r
where rental_date between '2005-05-01' and '2005-08-01';

/* 2단계 검증 : 5월 대여 정보 row 수 : 1156 건 */
select count(*)
from rental r
where rental_date between '2005-05-01' and '2005-06-01';

/* 3단계 : 6, 7 월 추가 */

  select 
    sum((
    	case when monthname(rental_date) = 'May' then 1 else 0 end) 
    ) may_rental,
    sum((
    	case when monthname(rental_date) = 'June' then 1 else 0 end) 
    ) june_rental,
    sum((
    	case when monthname(rental_date) = 'July' then 1 else 0 end) 
    ) july_rental
    from rental
   where rental_date between '2005-05-01' and '2005-08-01';


count(i.inventory_id)
/* 내꺼 */
select
case 
	when month(calendar.dt) = '5' then '5월'
	when month(calendar.dt) = '6' then '6월'
	when month(calendar.dt) = '7' then '7월'
	else 'NONE'
end calendar_month,
count(r.rental_id) tot_day_rental_cnt
from rental r 
right outer join
(select date_add('2005-01-01', interval(ones.num + tens.num + hundreds.num) day) dt
from 
 (SELECT 0 num UNION ALL
 SELECT 1 num UNION ALL
 SELECT 2 num UNION ALL
 SELECT 3 num UNION ALL
 SELECT 4 num UNION ALL
 SELECT 5 num UNION ALL
 SELECT 6 num UNION ALL
 SELECT 7 num UNION ALL
 SELECT 8 num UNION ALL
 SELECT 9 num) ones
 CROSS JOIN
 (SELECT 0 num UNION ALL
 SELECT 10 num UNION ALL
 SELECT 20 num UNION ALL
 SELECT 30 num UNION ALL
 SELECT 40 num UNION ALL
 SELECT 50 num UNION ALL
 SELECT 60 num UNION ALL
 SELECT 70 num UNION ALL
 SELECT 80 num UNION ALL
 SELECT 90 num) tens
 CROSS JOIN
 (SELECT 0 num UNION ALL
 SELECT 100 num UNION ALL
 SELECT 200 num UNION ALL
 SELECT 300 num) hundreds
where date_add('2005-01-01', interval(ones.num + tens.num + hundreds.num) day) < '2006-01-01') 
as calendar on calendar.dt =  date(rental_date)
group by calendar_month


/* case 문 안쓰고 */
select 
from rental r 
right outer join
(select date_add('2005-01-01', interval(ones.num + tens.num + hundreds.num) day) dt
from 
 (SELECT 0 num UNION ALL
 SELECT 1 num UNION ALL
 SELECT 2 num UNION ALL
 SELECT 3 num UNION ALL
 SELECT 4 num UNION ALL
 SELECT 5 num UNION ALL
 SELECT 6 num UNION ALL
 SELECT 7 num UNION ALL
 SELECT 8 num UNION ALL
 SELECT 9 num) ones
 CROSS JOIN
 (SELECT 0 num UNION ALL
 SELECT 10 num UNION ALL
 SELECT 20 num UNION ALL
 SELECT 30 num UNION ALL
 SELECT 40 num UNION ALL
 SELECT 50 num UNION ALL
 SELECT 60 num UNION ALL
 SELECT 70 num UNION ALL
 SELECT 80 num UNION ALL
 SELECT 90 num) tens
 CROSS JOIN
 (SELECT 0 num UNION ALL
 SELECT 100 num UNION ALL
 SELECT 200 num UNION ALL
 SELECT 300 num) hundreds
where date_add('2005-01-01', interval(ones.num + tens.num + hundreds.num) day) < '2006-01-01')
as calendar on calendar.dt = date(r.rental_date) 

/*
 * 영화의 재고 수량에 따라 품절, 부족, 여유, 충분 으로 분류되어 출력이 되도록 sql을 작성.
 * 출력은 영화 제목, 재고 수량에 따른 분루명으로 출력이 되도록 함
 * case 표현식을 사용해서 sql 작성
 * 
 * 분류 기준은
 * 		- 품절 : 재고수량 0
 * 		- 부족 : 재고수량 1 or 2
 * 		- 여유 : 재고수량 3 or 4
 * 		- 충분 : 재고수량 5 이상
 * 
 * 사용 테이블 : film, inventory
 * 
 * 분류 기준 정보는 테이블의 칼럼처럼 출력되도록 해야한다. => 스칼라 서브쿼리
 * 
 * 스칼라 sub query 에서 case ... when... 하면 되지 않을까?
 * 
 * Main Query : film
 * 스칼라 sub query : inventory
 * 
 * */

desc inventory ;
select * from inventory;
select * from rental r
where r.rental_date is not null;;
select * from film f ;

/* 문제 */
select f.title,
case(
		select count(*)
		from inventory i 
		where i.film_id = f.film_id
    )
	when 0 then '품절'
	when 1 then '부족'
	when 2 then '부족'
	when 3 then '여유'
	when 4 then '여유'
	else '충분'
end film_inventory
from film f;
/*where f.film_id in (6,15); 검증용 sql 조건 */

/* 검증용 sql 
 * 
 * 검증용 데이터
 * 		- 재고가 1인경우 : 없음
 * 		- 재고가 2인경우 : 29, 30 => '부족' => OK
 * 		- 재고가 3인경우 : 2, 5 => '여유' => OK
 * 		- 재고가 4인경우 : 3, 8 => '여유' => OK
 * 		- 재고가 5인경우 : 7, 9 => '충분' => OK
 * 		- 재고가 6인경우 : 6, 15 => '충분' => OK
 * */

select film_id , count(*)
from inventory i 
group by film_id 
having count(*) = 6

/*
 * View
 * 
 * 1. 사용 목적
 * 		- 데이터 보안
 * 		- 사용자 친화적 SQL이 되도록 해야한다.
 * 		- 재사용성, 유지보수성
 * 
 * 2. View 생성 방법
 * 		create view view_name( col1, col2 .... ) as
 * 		select ( col1, col2 .... ) from table_name;
 * 
 * 3. View 에 대한 사용 권한 제어
 * 		- 현재는 root 유저.
 * 		- 스키마 별로 유저를 생성.
 * 		  스키마 별로 View에 대한 사용 권한을 부여한다.
 * 
 * 		- marketing user, insa user, other user 등으로 생성.
 * 		  customer_v 고객 table 뷰를 생성해서, other user 에게 접근 권한 부여.(grant)
 * 		  customer table 접근 권한 회수(revoke)
 * 
 * 		- 경우에 따라서, 갱신 view를 생성해서 제공해야 할 경우도 있다.
 * 		
 * 
 * */


/*
 * 고객 정보 table을 기준으로 view를 생성.
 * 고객ID, first_name, last_name 항목은 그대로 다 보여지도록 하고,
 * 단, 이메일 주소는 부분 ***로 마킹해서 보여지도록 한다.
 * 
 * 이메일 주소 마킹처리 된 예
 * Ma*****.org
 * MAster0001.org
 * 
 * 문자열처리 : substr()
 * 
 */


desc customer ;

create view customer_v as
select first_name, last_name, email
from customer c;

/* 강의 */

select concat(substr('MAster0001.org', 1, 2),'*****',substr('MAster0001.org', -4)) email;


create view customer_vw
(customer_id, first_name, last_name, email) as
select customer_id, first_name ,last_name,
concat(substr(email, 1, 2),'*****',substr(email, -4)) as email
from customer c; 

drop view customer_vw;



/* 내꺼 */
create view customer_v as
select first_name, last_name, email
from customer c;

select c.first_name, c.last_name, c.email
from customer_v c;


SELECT
    first_name,
    last_name,
    CONCAT(
        SUBSTRING(email, 1, 2), REPEAT('*', LENGTH(email) -4  - INSTR(email, '@')), SUBSTRING(email, INSTR(email, '@'))          -- @ 이후의 문자열
    ) AS email_masked
FROM
    customer_v;
/*
 * 목적 : 복잡성을 낮추는 것이다.
 * 
 * 각 영화 정보에 대해서
 * film_id, title, description, rating 가 출력이 되고,
 * 추가적으로 각 영화에 대한 영화 카테고리, 영화 출연 배우의 수,
 * 총 재고수, 각 영화의 대여 횟수가 조회되도록 view를 생성.
 * 
 * film 의 기본 칼럼을 제외하고 나머지 4개의 데이터는 스칼라 sub query 이다.
 * 그리고, 스칼라 sub query 연관 관계의 조건
 * 
 */
 
   /*
    * 공통화 작업, 가독성 높이고, 유지보수 향상이 되도록 => 스칼라 Sub Query
    */
   
-- 강의
create view film_total_info
as
select f.film_id ,f.title , f.description , f.rating,
		(
			select c.name
			from category c
			inner join film_category fc
			on c.category_id = fc.category_id -- 일반적인 inner join, 결과 : Multi rows
			where fc.film_id = f.film_id -- 상관관계 , 결과 : single row
		) category_info, -- 영화에 대한 영화 카테고리 정보
		(
			select count(*)
			from film_actor fa 
			where fa.film_id = f.film_id 
		) actor_cnt, -- 영화 출연 배우의 수
		(
			select count(*)
			from inventory i 
			where i.film_id = f.film_id 
		) inventory_cnt, -- 총 재고수
		(
			select count(*)
			from inventory i 
			inner join rental r on i.inventory_id = r.inventory_id
			where i.film_id = f.film_id 
		) rental_cnt -- 영화의 대여 횟수
from film f;


select * from film_total_info;

-- 내꺼   
select f.film_id ,f.title , f.description , f.rating,
	(
		select fc.category_id
		from film_category fc 
		where f.film_id = fc.film_id
	) as film_category_id,
	(
		select c.name
		from category c 
		where c.category_id = film_category_id
	) as category_name,
	(
		select count(*)
		from actor a join film_actor fa on fa.actor_id = a.actor_id and f.film_id = fa.film_id
	) as film_actor_cnt
	from film f 
 
	
 /* 영화 카테고리별 총 대여량을 조회하는 View를 생성. 
  * 
  * 영화 제작시 발생하는 투자금에 대한 ROI를 높이고,확보
  * 안정적이고 지속적이고 높은 ROI 확보하기 위한 정보를 가공.
  * 
  * 담당하는 개발자는 도메인 지식이 높아야 하고, 정확한 분석, 사용자를 배려한 SQL을 작성.
  * - 유지보수성, 안정성, 가독성, 등등등
  * 
  * 필요한 정보 : 영화 카테고리명( cateogory.name ), 총대여 금액 ( sum(payment.amount) )
  * 필요한 테이블 : rental, payment, inventory, film, film_category, category
  * 
  * */

	select c.name category_name , sum(p.amount) tot_rental_amount
	from payment p
	inner join rental r ON r.rental_id = p.rental_id 
	inner join inventory i on r.inventory_id = i.inventory_id 
	inner join film f on i.film_id = f.film_id
	inner join film_category fc on f.film_id = fc.film_id
	inner join category c on c.category_id = fc.category_id
	group by c.name 
	order by tot_rental_amount desc