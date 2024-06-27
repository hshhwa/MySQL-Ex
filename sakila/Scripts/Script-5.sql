/* ==================== 서브 쿼리 ==================== */
/* 
 * 데이터 베이스의 내부 구조
 * 
 * 1. 데이터 캐시 ( 정리 필수 )
 * 	1.1 위치
 * 		데이터베이스의 공유 메모리 내에 존재 한다.
 * 
 * 	1.2 용도
 * 		DB서버프로세서가 SQL클라이언트의 select 요청에 대한 데이터가 메모리에 없는 경우
 * 		속도가 느린 디스크에서 읽어올 수 밖에 없으므로 그만큼 SQL의 처리가 느려지게 된다.
 *		( DISK I/O 가 발생함으로 속도가 느려지게 된다 )
 *  
 * 		따라서, 한 번 조회된 데이터는 데이터 캐시에 저장해두고 재활용하려고 한다.
 * 		내부 알고리즘에 의해서, 캐시가 갱신됨.
 * 
 * 	1.3 검색 결과 반환 단계( 이해를 돕기 위해 간단하게 설명. )
 *		- SQL 클라이언트가 select 문을 DB 서버로 문자열 전송.
 *		- DB 서버 프로세스가 메모리(데이터 캐시 또는 버퍼 캐시 라고한다)에 데이터가 있는지 확인.
 *		- 캐시된 데이터가 없으면, DISK에서 직접 읽어와서, 메모리에 캐싱한다. 	
 * 
 * 2. 딕셔너리 캐시, 라이브러리 캐시 ( 참고, SQL 성능이라는 부분이 이런 거구나.. )
 * 	2.1 위치
 * 		데이터 베이스의 고유 메모리 내에 존재
 * 
 * 	2.2 용도
 * 		딕셔너리 캐시는 주로 SQL 의 실행에 필요한 메타 정보를 보관한다.
 * 		라이브러리 캐시는 실행 계획 등의 SQL 정보가 저장된다.
 * 
 * 		SQL 문에는 구체적인 처리방법이 적혀 있지 않기 때문에 데이터베이스가 처리 방법(실행 계획)을 스스로
 * 		생성해야할 필요가 없음. 따라서, 실행 계획의 좋고 나쁜에 따라 성능이 크게 변할 수 있따.
 * 		( Oracle 기준 : rule based, cost based 
 * 		  10 버전 부터는 cost based 만 있다. 어떤 경로를 타면 저비용으로 탐색이 되나??
 * 		)
 * 
 * 		단순한 예로 1,000 만건의 데이터가 있는 table A 와 100 만건의 데이터가 있는
 * 		table B가 있고, table A에 vaule 칼럼에 값은 99% 가 1로 저장되어 있는 상태.
 * 		
 * 		select * from
 * 		 inner join B
 * 		  on A.id = B.id
 * 			where A.value = 1 and B.value = 1
 * 
 * 		- table A -> table B( cost가 높다. )
 * 			최악의 경우 1000만 번의 디스크 I/O 가 발생할 수 있다.
 * 
 * 
 * 
 * 		- table B -> table A( cost가 낮다. )
 * 			B.value = 1 인 데이터에 대한 I/O 만 발생할 수 있다.
 * 
 * 	2.3 실행계획의 수립에 필요한 정보
 * 		옵티마이저가 실행 계획을 세우기 위해서 3가지 정보를 활용해서,
 * 		비용을 계산하여 최적의 실행 계획을 세우게 된다.
 * 
 * 		- SQL 문 의 정보
 * 			어떤 테이블의 어떤 데이터인지, 어떤 검색조건인지, 테이블 간의 관계는...
 * 		- 초기화 파라미터
 * 			세션에서 사용할 수 있는 메모리의 크기, 단일 I/O로 읽어올 수 있는 블록 수
 * 			( cost 비용 산출시 필요한 정보. )
 * 		- 옵티마이저 통계( 시계열 정보 )
 * 			테이블 통계, 컬럼 통계( 컬럼의 데이터 값, 데이터의 분포도 등등 )
 * 			인덱스 통계( 인덱스 깊이 등 ) , 시스템 통계( I/O )
 * 		
 * 
 */

desc customer;

/* 마지막으로 가입한 고객 정보 
 * 
 * customer_id : smallint unsigned, auto_increment => 가장 큰 값 => 최근 가입 고객
 * 
 * */

select customer_id , first_name , last_name 
from customer c
where customer_id = ( select max(customer_id) from customer c2)

select Max(customer_id) from customer;

select customer_id , first_name , last_name 
from customer c
where customer_id = 599;

desc city; /* 국가별 도시 정보 */
desc country; /* 국가 정보 */


select city_id, city
from city c
where country_id <> (select country_id from country c2
					where  c2.country = 'India'	
					);

/* in 연산자 subquery */
select city_id, city 
from city c
where country_id
in ( 
select country_id
from country c
where country in('Canada','Mexico')
)


select city_id, city 
from city c
where country_id
in ( 
select country_id
from country c
where country not in('Canada','Mexico')
)


/* DVD 대여시 실제 결제를 한 고객 정보 */

select first_name ,last_name 
from customer c
where customer_id not in (
						   select customer_id 
						   from payment p
						   where amount = 0
)

/* 무료 DVD를 대여한 고객 정보 : 23rows */

select first_name ,last_name 
from customer c
where customer_id in (
						   select customer_id 
						   from payment p
						   where amount = 0
)

/* DVD 대여시 실제 결제를 한 고객 정보 : 576 rows 
 * 
 * all 연산자 : 서브쿼리에서 반환되는 여러개의 결과에서 모두 만족해야 한다.
 * 
 * any 연산자 : 서브쿼리에서 반환되는 여러개의 결과중에서 한 가지만 만족해도 된다.
 * 
 * */

select first_name, last_name
from customer c
where customer_id <> all (
							select customer_id 
							from payment p
							where amount = 0
)

/*
 * any 연산자
 * 
 * 볼리비아(bolivia), 파라과이(Paraguay) 또는 칠레(Chile)의 모든 고객에 대한 총 영화 대여료를 초과하는 총 결제금액을 가진 모든 고객정보를 조회
 * payment, customer, address, city, country
 */


select customer_id, sum(amount)
from payment
group by customer_id 
having sum(amount) > any(
select sum(p.amount)
  from payment p 
  	inner join customer c 
  		on p.customer_id = c.customer_id 
  	inner join address a 
  		on a.address_id = c.address_id 
  	inner join city ct
  		on ct.city_id = a.city_id 
  	inner join country co
  		on ct.country_id = co.country_id 
  where co.country in ('Bolivia','Paraguay','Chile')
  group by co.country 
  /* Bolivia : 183.53, Paraguay : 275.38, Chile : 328.29 */
)

/* 다중 열 서브 쿼리 : 반환되는 결과가 다중 열인 서브 쿼리 */

select actor_id, film_id 
from film_actor
where ( actor_id, film_id ) in (
									/* 카테시안 프러덕트 : cross join */
									select  a.actor_id, f.film_id 
										from actor a
											cross join film f 
												where a.last_name = 'MONROE' and f.rating = 'PG'
									
							   );
							  

/* 상관 서브 쿼리 
 * 
 * 메인 쿼리에서 사용한 데이터를 sub query 에서 사용하고
 * sub query의 결과값을 다시 메인 쿼리로 반환하는 방식
 * => 비상관 서브 쿼리에는 서브쿼리가 독립적으로 실행이 된다.
 * 
 *  아래의 상관관계 sql의 동작 순서
 * 
 *  1. Main sql 에서 customer_id 를 모두 구함. 599 명의 고객 id를 조회 한다.
 *  2. customer_id 를 sub query에 제공.
 *     sub query가 한번씩 실행이 되도록 customer_id를 제공.
 *  3. sub query 에서는 제공 받은 customer_id 로 실행.
 *  4. sub query의 결과를 Main query 로 반환.
 *  5. Main query 에서 20번 대여 횟수가 동일한지 확인이 가능.
 * 
 * */

select c.first_name ,c.last_name 
from customer c
where 20 = (
				select count(*)
				from   rental r
				where r.customer_id = c.customer_id 
			);
		
select count(*) from rental r where r.customer_id = 191;

/*
 *  상관관계 Query 를 사용해서 SQL을 작성.
 *  대여 총 지불액이 180 달러에서 240달러 사이인 모든 고객 리스트
 * */
select * from customer;

select c.first_name ,c.last_name 
from customer c 
where (
				select sum(p.amount)
				from payment p 
				where p.customer_id = c.customer_id 
)/* 상관관계 sub query 가 599 번 실행, 599번 반환 */
between 180.0 and 240.0 ;

/* exists 연산자
 * 
 * exists 연산자 다음에 sub query가 위치하고 ,
 * 그 sub query 의 결과가 row 수에 관계없이 존재 자체만 확인하고자 하는 경우에 사용.
 * 
 * */

/* 2005-05-25 일 이전에 한 편 이상의 영화를 대여한 모든 고객 */

select c.first_name , c.last_name 
from customer c 
where exists 
(
	select 1 /* SQL 처리 속도 향상을 위함니다. */
		from rental r
		where r.customer_id = c.customer_id 
		and date(r.rental_date) < '2005-05-25'
);

select 1
from rental r
where r.customer_id = 130
and date(r.rental_date) < '2005-05-25'


/*
 * 상관관계 SUB Query 사용.
 * R 등급 영화에 출한 적이 한 번도 없는 모든 배우명을 검색
 * 
 * - 영화 배우 한 명만을 생각해보는 것으로 논리적으로 생각해봄
 *   A 영화배우, 10편에 출연. => 10편 영화가 R 등급 영화에 출연 여부.
 * 		Main 					Sub
 * 	
 * 	 영화배우 테이블에 영화 배우가 100명이라면, 위의 처리 방법을 100번 수행
 * 
 * 	 => 상관관계 쿼리
 * 		Main Query에서 조회된 데이터를 Sub Query에서 조건 사용하고,
 * 		Sub Query 결과를 Main Query로 반환
 */

/* 강의 
 * 
 * 지금 예제는 상관관계를 사용하면 좋은 경우.
 * */
select a.first_name , a.last_name 
from actor a /* 배우 데이터를 Sub Query의 검색 조건으로 사용. */
where not exists /* Sub Query로 R등급으로만 조회 */
(
	select 1
		from film_actor fa 
		inner join film f  on f.film_id = fa.film_id
		where fa.actor_id = a.actor_id /* Main Query의 데이터 */
		and f.rating = 'R'
);


/* 내꺼 */
select a.first_name ,a.last_name
from actor a 
where a.actor_id not in (
			select a.actor_id 
			from film_actor fa join film f on f.film_id = fa.film_id  
			where a.actor_id = fa.actor_id and f.rating = 'R'
		);
	
desc film;
desc film_actor;
desc actor;

select * from film;
select * from 
/*
 * Sub Query 사용.
 * 고객별 고객정보 (first_name, last_name), 대여횟수, 대여결제총액을 조회
 * 
 * 
 * inner join 문에 사용되는 Sub Query
 * 대여횟수, 대여결제총액 은 집계 합수 사용.
 * 
 * 이렇게 하면 향후에 함수 또는 프로시저(funtion, procedure 등 ) 가 될 후보군이 보이게 된다.
 * 
 */

/* 강의 */
select c.first_name ,c.last_name , payInfo.rentals_cnt, payInfo.payments_tot
from customer c /* 고객정보 전용 */
	inner join
	(
		select customer_id , count(*) rentals_cnt, sum(amount) payments_tot
			from payment p
			group by customer_id 
	) as payInfo /* 대여 정보 전용 SQL */
	on c.customer_id = payInfo.customer_id


/* 내꺼 */
select c.first_name , c.last_name, count(*), sum(rr.amount)
from customer c 
join 
(select r.customer_id, p.amount
from rental r join payment p on r.rental_id = p.rental_id 
)as rr on rr.customer_id = c.customer_id
group by c.first_name , c.last_name 


select c.first_name , c.last_name, count(*), sum(p.amount)
from customer c 
join rental r  on r.customer_id = c.customer_id
join payment p on c.customer_id = p.customer_id
where r.rental_id = p.rental_id 
group by c.first_name, c.last_name 


desc rental ;
select * from rental;
desc payment;
select * from payment p 


/*
 * 난이도가 있음.
 * 대여 결제 총액 기준으로 크게 3개 그룹의 고객을 분류.
 * 낮은 결제 고객 : 0 ~ 74.99 
 * 중간 결제 고객 : 75 ~149.99
 * 높은 결제 고객 : 150 ~ 9,999,999.99
 * 
 * 상기의 기준으로 해당 그룹에 속하는 고객수를 조회 
 * 
 * => 분류 테이블 처럼 생각해야 한다. 하지만, 실제 테이블이 아니다.
 * 		=> 마치 테이블 처럼 되도록만 하면, 관계만 맺어주게 되면 해결
 * 			=> 마스터 코드 및 분류 테이블이 될 후보군이 보인다.
 * 
 * 
 * 1. 논리적인 테이블이 되도록 해야한다.
 */

/* 강의 */
/*
 * 
 * 고객 정보 테이블
 * 
 * 결제 기준 분류 테이블
 *  낮은 결제 고객 : 0(low_limit) ~ 74.99(high_limit) 
 *  중간 결제 고객 : 75 ~149.99
 *  높은 결제 고객 : 150 ~ 9,999,999.99
 */

select 'small', 0 low_limit, 74.99 high_limit
union all
select 'average', 75 low_limit, 149.99 high_limit
union all
select 'heavy', 150 low_limit, 99999999.99 high_limit;

/* 논리적인 테이블과의 관계를 설정 
 * 
 * 논리적인 테이블이 inner join 안에 들어가고 관계를 맺어주면 된다.
 * */
select payGroupInfo.name, count(*) num_cus
from 
(
	select customer_id, count(*) rentals_cnt, sum(amount) payments_tot
	from payment p
	group by customer_id
) payInfo /* 고객 정보 + 결제 정보 */
inner join
(
	select 'small' name, 0 low_limit, 74.99 high_limit
	union all
	select 'average'name, 75 low_limit, 149.99 high_limit
	union all
	select 'heavy' name, 150 low_limit, 9999999.99 high_limit
) as payGroupInfo /* 결제 분류 논리 테이블 */
on payInfo.payments_tot between low_limit and high_limit
group by payGroupInfo.name;


/* 내꺼 */
select c.first_name ,c.last_name, sum(p.amount) , '0 ~ 74.99' SumAmount
from customer c join payment p on p.customer_id = c.customer_id 
group by c.first_name ,c.last_name
having sum(p.amount) between 0 and 74.99
union all
select c.first_name,c.last_name, sum(p.amount), '75 ~ 149.99' 
from customer c join payment p on p.customer_id = c.customer_id 
group by c.first_name ,c.last_name
having sum(p.amount) between 75 and 149.99
union all
select c.first_name ,c.last_name, sum(p.amount), ' >= 150 ' 
from customer c join payment p on p.customer_id = c.customer_id 
group by c.first_name ,c.last_name
having sum(p.amount) >= 150
order by 3 





SELECT grade, count(*) FROM 
(SELECT (CASE
      WHEN  pay.total_cost BETWEEN 0 AND 74.99
      THEN '낮은 결제 고객'
      WHEN pay.total_cost BETWEEN 75 AND 149.99
      THEN '중간 결제 고객'
      ELSE '높은 결제 고객'
      END) AS grade
FROM (
SELECT p.customer_id, sum(amount) AS total_cost FROM payment p 
GROUP BY p.customer_id ) AS pay
) AS sample
GROUP BY sample.grade;

/*
 * SQL을 작성하되, 가독성 높은 SQL로 작성할 것
 * 
 * 고객명 (first, last name, 도시명) 총 대여 지불 금액, 총 대여 횟수 를 조회하는 SQL 작성.
 */
desc address;
desc city;
desc payment;
desc rental;
desc customer;

/* 공통화 작업을 하지 않은 SQL
 * 
 * : 조회를 table을 기준으로만 직접 조인해서 사용
 * 
 * 테이블 간의 조인의 목적성이 잘 보이지 않음.
 * 따라서, 코드를 좀 읽어서, 분석이 필요.
 * 통계적인 정보의 조회를 위해서 테이블간의 조인 부분을 공통화 하면 어떨까?
 * 
 *  */
select c.first_name ,c.last_name ,ct.city , sum(p.amount) pay_tot, count(*) rental_tot_cnt
from payment p
inner join customer c on p.customer_id = c.customer_id 
inner join address a on c.address_id = a.address_id 
inner join city ct on a.city_id = ct.city_id 
group by c.first_name , c.last_name , ct.city; 


/* 통계 정보 기능만 별도의 SQL 로 작성 : 공통화 작업 */
select customer_id , 
		sum(p.amount) pay_tot , count(*) rental_tot_cnt
  from payment p 
 group by customer_id ;

/*
 * 공통화 작업을 한 SQL
 * : Sub Query 를 작성해서 다시 조인해서 사용.
 * 
 */   
select c.first_name , c.last_name , ct.city ,
		payInfo.pay_tot , payInfo.rental_tot_cnt
  from (
		select customer_id , 
				sum(p.amount) pay_tot , count(*) rental_tot_cnt
		  from payment p 
		 group by customer_id /* view 의 후보군 */
  ) payInfo
 inner join customer c 
    on payInfo.customer_id = c.customer_id 
 inner join address a 
    on c.address_id = a.address_id 
 inner join city ct
    on a.city_id = ct.city_id ;
  

/* 내꺼 */
select c.first_name , c.last_name, sum(p.amount)
from customer c 
join address a 
join payment p 
join city ci 
join country co 
join rental r 
on c.address_id = a.address_id 
and a.city_id = ci.city_id 
and ci.country_id = co.country_id 
and p.customer_id = c.customer_id 
and r.customer_id = c.customer_id
group by c.first_name, c.last_name


/* 공통 테이블 표현식 : CTE, with 절 
 * CTE : Common Table Expression
 * 
 * 서브 쿼리가 몇 십줄 씩 되는 경우 ( 서브쿼리의 규모가 큰 경우 )
 * 실제 수행해야 할 Main Query 와 Sub query를 구분할때 유용하다.
 */


/* 성이 'S'로 시작하는 배우가 출연하는 PG 등급 영화 대여로 발생한
 * 총 수익(대여료)을 조회 
 * 
 * 영화 배우명(first_name, last_name), 총 수익 으로 조회.
 * */

/* CTE 절을 사용하면 좋은 경우 */




/* 강의 */

/* 1. 성이 'S'로 시작하는 배우*/

with actors_s as
(
	select actor_id, first_name, last_name
		from actor a 
			where last_name like 'S%'
),

/* 2. 배우 및 필름 정보 
 * 		1의 sql 문장을 사용.
 * */
actor_s_pg as
(
	select s.actor_id, s.first_name, s.last_name, f.film_id, f.title
		from actors_s s
			inner join film_actor fa on s.actor_id = fa.actor_id
				inner join film f on f.film_id = fa.film_id
					where f.rating = 'PG'
),

/* 3. 영화 배우명(first_name, last_name), 총 수익 으로 조회.
 * 		2의 sql 사용
 * */
actors_s_pg_income as
(
	select spg.first_name, spg.last_name, p.amount
		from actor_s_pg spg
			inner join inventory i on i.film_id = spg.film_id
				inner join rental r on r.inventory_id = i.inventory_id
					inner join payment p on p.rental_id = r.rental_id
)
select spg_income.first_name, spg_income.last_name, sum(spg_income.amount) tot_income
from actors_s_pg_income spg_income
group by spg_income.first_name, spg_income.last_name
order by 3 desc;


/* 내꺼 */
select a.first_name, a.last_name ,filmcostInfo.filmcost
from actor a 
join
(
select fa.actor_id, sum(p.amount) filmcost
from film_actor fa 
join film f on f.film_id = fa.film_id
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
join payment p on r.rental_id = p.rental_id
where f.rating = 'PG'
group by fa.actor_id
) as filmcostInfo
where a.actor_id = filmcostInfo.actor_id and a.last_name like 'S%'

   

select * from actor;
   
/* 영화 배우를 조회. 영화 배우 ID, 영화 배우명(first_name, last_name) 
 * 
 * 단, 정렬 조건은 영화 배우가 출연한 영화수로 내림차순 정렬이 되도록 하고,
 * 정렬 조건을 Sub Query로 작성할 것.
 * */

select a.actor_id, a.first_name, a.last_name
from actor a 
order by (
select count(*)
from film_actor fa 
where fa.actor_id = a.actor_id /* 연관 관계 sub Query */
) desc;


/* 내꺼 */
select a.first_name , a.last_name, filminfo.film_count
from actor a 
join
(
select fa.actor_id, count(fa.actor_id) film_count
from film_actor fa join film f on fa.film_id = f.film_id
group by fa.actor_id
) as filminfo
on a.actor_id = filminfo.actor_id
order by filminfo.film_count desc

/*
 * 스칼라 서브 쿼리
 * 
 * select 절에 사용되는 sub Query
 * - 칼럼의 형태 => 하나의 열로 사용할 수 있도록 해야 한다.
 * - 반드시 하나의 결과만 반환되도록 해야 한다. => 연관관계 임을 나타낸다
 * - Main query의 from절 다음에 inner join 절이 없어도 된다.
 * */

/* 아래의 SQL을 스칼라 sub query로 변경해보세요. */
select c.first_name , c.last_name , ct.city , payInfo.pay_tot , payInfo.rental_tot_cnt
  from (
		select customer_id , sum(p.amount) pay_tot , count(*) rental_tot_cnt
		  from payment p 
		 group by customer_id /* view 의 후보군 */
  ) payInfo
 inner join customer c on payInfo.customer_id = c.customer_id 
 inner join address a on c.address_id = a.address_id 
 inner join city ct on a.city_id = ct.city_id ;


/* 강의 */
/* 
 * 1. Main Query 의 from 절에 사용할 테이블 결정
 * 		payment : 한 번 이라도 결제한 고객이 대상.
 * 2. first_name : sub query + 조건( 연관관계 : payment )
 * 3. last_name : sub query + 조건( 연관관계 : payment )
 * 4. city
 * 		sub query(customer, address, city) + 조건 ( 연관관계 : pament )
 * 5. 총 결제 금액
 *    총 대여 횟수
 * 		Main Query의 from 절 table을 이용해서 집계함수로 통계처리
 * 6. Main Query에 group by 적용.
 * 
 * 
 * */
select 
(select c.first_name
from customer c where c.customer_id = p.customer_id 
) First_name,
(select c.last_name
from customer c where c.customer_id = p.customer_id 
) Last_name,
(
select ct.city
from customer c
inner join address a on c.address_id = a.address_id
inner join city ct on a.city_id = ct.city_id
where c.customer_id = p.customer_id 
) city,
sum(p.amount) tot_pay,
count(*) tot_pay_cnt
from payment p
group by p.customer_id 




/* 내꺼 미완성 */
desc city;
desc address;
desc rental;
desc payment;
select 
(
select c.first_name
from customer c where c.customer_id = p.customer_id 
) first_name,
(select c.last_name
from customer c where c.customer_id = p.customer_id 
) last_name,
(
select ct.city
from city ct
join address a on ct.city_id = a.city_id
join customer c on a.address_id = c.address_id
where c.customer_id = p.customer_id 
) city,
sum(p.amount) tot_pay, count(*) tot_pay_cnt
from payment p
group by p.customer_id 




/* 대여 가능한 DVD 영화 리스트를 조회.
 * film id, 제목, 재고번호, 대여일 이 조회도록 SQL 작성. 
 * 
 * 단, 모든 영화가 빠짐없이 조회가 되도록 해야 하고,
 *   film id 는 13, 14, 15 로 한정. 
 * 
 * => 필요한 테이블 => film, inventory, rental
 * => film 정보가 inventory 뿐만이 아니라, rental에도 없는 경우 가 있다.
 * 		이런경우 join은??
 * */

select f.film_id ,f.title , i.inventory_id , r.rental_date 
from film f
left outer join inventory i on f.film_id = i.film_id /* film 테이블 기준 : left */
left outer join rental r on i.inventory_id = r.inventory_id /* inventory 테이블 기준 : left */
where f.film_id between '13' and '14'

/* 강의 */

/* 
 * film 에는 데이터가 있지만,
 * inventory 에는 데이터가 없는 경우 => outer join
 * */

/* count() 의 값이 null 이면 0으로 처리한다.  */
select f.film_id , f.title , count(i.inventory_id)
from film f 
left outer join inventory i on f.film_id = i.film_id
group by f.film_id , f.title

/* film_id 에 14번은 존재하지 않는다. */
select * from inventory i where film_id = 14;




/* cross join(교차 조인) : 카테시안 프로덕트 */

/* 0 ~ 399 => DATE_ADD() 를 사용할때 interval 용 데이터 ( DAY, MONTH, YEAR ) */    
SELECT ones.num + tens.num + hundreds.num
 FROM
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
order by 1;

/*
 * DATE_ADD(), INTERVAL()
 * 
 * 생성되는 날짜 범위 : 2020-01-01 ~ 2020-12-31
 */
select date_add('2020-01-01', interval(ones.num + tens.num + hundreds.num) day) dt
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
where date_add('2020-01-01', interval(ones.num + tens.num + hundreds.num) day) < '2021-01-01'
order by 1;




/*
 * 상기의 달력을 만든 후, 
 * rental table의 대여일 별로 대여 수를 조회
 * 단, 검색 기간은 2005 년도에 대해서만 조회
 * 
 * Main Query : rental table ( 왼쪽 )
 * Sub Query  : 달력 table ( 오른쪽 )
 * 
 * 
 * 두 테이블의 관계 : 달력의 데이터가 rental table에는 없을 수 가 있다
 * 					right outer join
 * 
 */

desc rental; /* rental_date 의 형식은 datetime 
				그래서, rental_date 를 date 형식으로.	*/

select rental_date,date(rental_date)
from rental r; 

select calendar.dt, count(r.rental_id) tot_day_rental_cnt
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
group by calendar.dt
order by 1;



select * from rental;

