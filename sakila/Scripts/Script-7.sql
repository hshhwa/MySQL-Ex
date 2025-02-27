
/* ============================== 스토어드 프로시저 =============================== */
create database shoppingmall;

-- 스키마 지정
use shoppingmall;

-- 테스트용 테이블 : 도메인 테이블이 아님!

create table usertbl
(
userID varchar(8) not null primary key, -- 쇼핑몰 사용자 ID, 제약조건 primary key
name varchar(30) not null, -- 회원명
birthYear int not null, -- 출생년도
addr varchar(8) not null, -- 지역 (경기, 서울, 경남...)
mobile1 varchar(3) not null,-- 휴대폰의 국번(011, 017,...)
mobile2 varchar(8), -- 휴대폰의 나머지 번호
height int, -- 신장
mdate date -- 회원가입일
);

-- 회원 구매 테이블
create table buytbl
(
num int auto_increment not null primary key, -- 순번
userID varchar(8) not null, -- 회원ID
prodName varchar(8) not null, -- 구매한 제품명
groupName varchar(4), -- 제품 분류
price int not null, -- 단가
amount int not null, -- 수량
foreign key(userID) references usertbl(userID) -- 제약조건
)

desc usertbl;
INSERT INTO usertbl VALUES('LSG', '이승훈', 1987, '서울', '010', '1111111', 182, '2008-8-8');
INSERT INTO usertbl VALUES('KBS', '김범수', 1990, '경남', '010', '2222222', 173, '2012-4-4');
INSERT INTO usertbl VALUES('KKH', '김경호', 2000, '전남', '010', '3333333', 177, '2007-7-7');
INSERT INTO usertbl VALUES('JYP', '조용수', 2005, '경기', '010', '4444444', 166, '2009-4-4');
INSERT INTO usertbl VALUES('SSK', '하준경', 1979, '서울', NULL  , NULL, 186, '2013-12-12');
INSERT INTO usertbl VALUES('LJB', '임재호', 1999, '서울', '010', '6666666', 182, '2009-9-9');
INSERT INTO usertbl VALUES('YJS', '윤호신', 1987, '경남', 010  , NULL      , 170, '2005-5-5');
INSERT INTO usertbl VALUES('EJW', '은지효', 1997, '경북', '010', '8888888', 174, '2014-3-3');
INSERT INTO usertbl VALUES('JKW', '조현우', 2002, '경기', '010', '9999999', 172, '2010-10-10');
INSERT INTO usertbl VALUES('BBK', '하준희', 2001, '서울', '010', '0000000', 176, '2013-5-5');
INSERT INTO usertbl VALUES('BBQ', '홍성화', 1111, '부산', '010', '0000000', 176, '2013-5-5',null);


INSERT INTO buytbl VALUES(NULL, 'KBS', '운동화', NULL   , 30,   2);
INSERT INTO buytbl VALUES(NULL, 'KBS', '노트북', '전자', 1000, 1);
INSERT INTO buytbl VALUES(NULL, 'JYP', '모니터', '전자', 200,  1);
INSERT INTO buytbl VALUES(NULL, 'BBK', '모니터', '전자', 200,  5);
INSERT INTO buytbl VALUES(NULL, 'KBS', '청바지', '의류', 50,   3);
INSERT INTO buytbl VALUES(NULL, 'BBK', '메모리', '전자', 80,  10);
INSERT INTO buytbl VALUES(NULL, 'SSK', '책', '서적', 15, 5);
INSERT INTO buytbl VALUES(NULL, 'EJW', '책'    , '서적', 15,   2);
INSERT INTO buytbl VALUES(NULL, 'EJW', '청바지', '의류', 50,   1);
INSERT INTO buytbl VALUES(NULL, 'BBK', '운동화', NULL   , 30,   2);
INSERT INTO buytbl VALUES(NULL, 'EJW', '책'    , '서적', 15,   1);
INSERT INTO buytbl VALUES(NULL, 'BBK', '운동화', NULL   , 30,   2);


select * from usertbl u;
select * from buytbl u;


/* ============ 스토어드 프로시저 ============ 
 * 
 * 개요
 *    - 쿼리문의 집합. 특별한 동작을 처리하기 위한 용도로 사용.
 *    - 재사용, 모듈화 개발이 됨.
 * 
 * 특징
 *    - 프로시저는 현장에 따라서 취사 선택 사항임.
 *    - 성능 향상.
 *      몇 백 라인의 SQL 문장이 문자열로 네트워크를 경유해서 서버로 전송하면,
 *      경우에 따라서(수 많은 유저, 수 많은 데이터) 네트워크 부하가 발생될 수 있음.
 * 
 *      이런 문제점에 대해서 필요한 기능에 따른 SQL 문장들을 서버에 보관해서,
 *      호출해서 사용하는 형태가 되면 네트워크의 부하를 낮추는데 도움이 될 수 있음.
 * 
 *      SQL 파싱, 실행계획 등의 전처리 작업이 캐싱된 상태임으로 재사용하게 되어,
 *      성능이 높아지게 됨.
 * 
 *    - 유지 관리가 편리
 *      JAVA 쪽에서 개발을 하지 않고, 필요한 기능을 데이터 베이스 서버에 두게 됨으로
 *      기존방법의 경우 관리 포인트가 두 군데임.( JAVA, 미들웨어 ,데이터베이스 )
 *      데이터베이스에 프로시저를 사용하게 되면, 관리포인트가 하나가 될 수 있음.
 * 
 *      JAVA 의 백엔드 단에 sql 을 작성해서 운영중인데, sql 문장에 칼럼을 추가,
 *      where 문장 수정이 발생하면, 수정 => 테스트 => 빌드 => 배포 등의
 *      작업이 수행해야 함.
 *       
 *      스토어드 프로시저를 사용하게 되면, java 단에서 수정해야 하는 부분이
 *      많이 줄어들게 됨. 데이터 베이스의 프로시저의 sql 만 수정하면 됨.
 * 
 *    - 모듈식 개발이 가능해짐.
 *      함수처럼 사용할 수 있기 때문에, 다른 프로시저에서도 호출해서 사용 가능.
 * 
 *    - 보안 강화.
 *      table 에 직접 접근 대신에 스토어드 프로시저을 통해서 접근하게 됨. 
 * 
 * 문법 
 *     create procedure 프로시저명 ( in , out ) in : 입력, out : 출력(결과)
 *     begin
 * 			sql...
 * 			조건문 ....
 * 			반복문 ....
 * 			함수 ...
 * 			프로시저 ....
 *     end;
 * 
 *     call 프로시저명( 매개변수 );
 * 
 * */




/* ============ 매개변수가 없는 프로시저 ============ */

drop procedure if exists userProc;

create procedure userProc()
begin
	select * from usertbl;
end;

call userProc(); 


/* ============ in 매개변수가 하나가 있는 프로시저 ============ */


drop procedure if exists userProc1;

create procedure userProc1( in userName varchar(10) )
begin
	select * from usertbl where name = userName;
end;

call userProc1('은지효'); 


/* ============ in 매개변수가 두 개가 있는 프로시저 ============ */

drop procedure if exists userProc2;

create procedure userProc2( in userBirthyear int,
							in userHeight int )
begin
	select * from usertbl 
	where birthYear > userBirthyear and height > userHeight; 
end;

call userProc2(1970, 178);
/* ============ in out 매개변수가 두 개가 있는 프로시저 ============ */
drop procedure if exists userProc3;

create table if not exists testtbl
(
	id int auto_increment primary key,
	txt varchar(10)
);

create procedure userProc3(	in textValue varchar(10),
							out outValue int )
begin
	insert into testtbl values(null, textValue);
	select max(id) into outValue from testtbl;
end;

call userProc3 ('텍스트값', @outValue);

select * from testtbl t;

select @outValue;

call userProc3('테스트값2', @outValue);

select * from testtbl t;

select @outValue;


/* ======================= in 매개변수, if 조건절이 있는 프로시저 ==================== */

drop procedure if exists ifElseProc;

create procedure ifElseProc(in userName varchar(10))
begin
	declare address varchar(8); -- 프로시저의 지역변수
	
	select addr into address from usertbl
	 where name = userName;
	
	if (address = '서울' or address = '경기') then 
		select '수도권 거주';
	else
		select '지방 거주';
	end if;
end;

call ifElseProc('김경호'); -- 전남
call ifElseProc('하준경'); -- 전남

/* ========================= in 매개변수, 반복문이 있는 프로시저 ===================== */
drop table if exists gugudanTBL;

create table gugudanTBL ( txt varchar(100) );

drop procedure if exists gugudanProc;

create procedure gugudanProc()
begin
	declare dan int; -- 구구단의단
	declare i int; -- 단의 1 ~ 9
	declare str varchar(1000);
	set dan = 2;

	delete from gugudanTBL;
	while ( dan < 10 ) do -- 2~9단 반복
		set str = '';
		set i = 1;
		while (i < 10) do -- 각 단에서 1~9 반복
			set str = concat(str, ' ', dan, 'X', i, ' = ', dan * i);
			set i = i + 1;
		end while; -- 단 종료	
		insert into gugudanTBL values(str);
		set dan = dan + 1;
	end while;
end;


call gugudanProc();

select * from gugudanTBL;


/* ========================= 동적(dynaimic) SQL이 있는 프로시저 ===================== 
 * 
 * 상황에 따라 SQL 변경이 실시간으로 필요한 경우.
 * 동적 SQL을 사용하여, 실시간으로 수정 및 실행해서 사용.
 * 
 * 
 */
 
drop procedure if exists dynamicSqlProc;

create procedure dynamicSqlProc ( in tblName varchar(20) )
begin
	-- 매개변수로 받은 테이블명을 사용해서 sql 문자열을 생성.
	set @sqlQuery = concat('select * from ', tblName);

	prepare myQuery from @sqlQuery; -- 동적 sql 실행 준비
									-- syntax, 테이블 존재 유무, 생성 권한 체크...
	execute myQuery;-- 동적 sql 실행
end;

call dynamicSqlProc('usertbl');
call dynamicSqlProc('buytbl');
 
 
/* ========================= 프로시저 - cursor 활용 ===================== 
 * 
 * 가장 많이 사용되어지는 형태
 * 
 * 커서(cursor)
 * 		테이블에서 여러 개의 행을 쿼리한 후 쿼리의 결과인 행 집합에서
 * 		한 행씩 처리 하기 위한 방식이다.
 * 
 * 커서 처리단계
 * 		커서 선언(declare) -> 커서 열기(open) -> 커서 fetch -> 커서 close
 * 		커서 fetch : 가져온 한 row에 대해 데이터 처리를 수행.
 * 
 * 실습 내용
 * 		대량의 고객 정보를 업데이트 하기 위한 프로시저를 개발
 * 
 * 		고객 정보 테이블에 고객 등급 칼럼을 추가 후 등급 관리를 하려고 한다.
 * 		(최우수 고객(1500이상), 우수 고객(1000이상), 일반 고객(1이상), 유령 고객(0))
 * 
 * */

-- 회원 테이블에 고객등급 칼럼 추가
alter table usertbl add grade varchar(10);

drop procedure if exists gradeProc;

create procedure gradeProc ()
begin
	/* 변수 선언 */
	declare id varchar(10); -- 회원ID
	declare sumOfAmount int; -- 총 구매 금액
	declare userGrade varchar(10);

	/* 커서 제어 변수 선언 */
	declare endOfRow boolean default false;

	/* 커서 선언 */
	declare userCursor cursor for
		select u.userid, sum(b.price * amount)
		  from usertbl u 
		  	left outer join buytbl b 
		  	on u.userid = b.userid
		  group by u.userid;
		 
	/* 커서 핸들링 제어 설정 */
	declare continue handler
			for not found set endOfRow = true;
		
	/* 커서 OPEN */
	open userCursor;

	/* 반복문 선언 */
	grade_loop: loop
		
		/* 커서 fetch */
		fetch userCursor into id, sumOfAmount;
	
		if endOfRow then
			leave grade_loop;
		end if;
		
		case
			when(sumOfAmount >= 1500) then set userGrade = '최우수고객';
			when(sumOfAmount >= 1000) then set userGrade = '우수고객';
			when(sumOfAmount >= 1) then set userGrade = '일반고객';
			else set userGrade = '유령고객';
		end case;
		
		/* 고객 등급 평가 결과를 반영 */
		update usertbl 
		   set grade = userGrade
		 where userID = id;
	
	end loop grade_loop;
	
end;

call gradeProc();

select * from usertbl u ;
desc usertbl
 
/* =========================== 스토어드 function =========================== */ 
/*
 * 두 정수를 매개변수로 받아서 더한 결과값을 반환
 * */ 

set global log_bin_trust_function_creators = 1; -- 전역 환경변수를 1또는 on으로 설정해야 function 사용가능


drop function if exists userFunc1;

create function userFunc1(val1 int, val2 int)
	returns int
begin
	return val1 + val2;
end;

select userFunc1(100,200);
 
/* 태어난 년도를 매개변수로 받아서, 현재 나이를 계산 및 반환 하는 함수 */

drop function if exists getAgeFunc;

create function getAgeFunc(varYear int)
	returns int
begin
	declare age int;
	set age = year(curdate()) - varYear;
	return age;
end;

select getAgeFunc(1997);

select userID, name, getAgeFunc(u.birthYear) as '현재나이'
from usertbl u;
 

/* ================================ Trigger ============================== 
 * 
 * 개요
 * 	테이블에 insert, update, delete 등의 작업(event)이 발생할 때
 * 	자동으로 작동되는 객체이다.
 * 
 * 	테이블에 부착되는 이벤트 프로그램 코드라고 생각하면 된다.
 * 
 * 대표적 용도
 * 	- 백업용
 * 		삭제할 경우 원본 데이터를 보관해야 하는 경우.
 * 	- 모니터링용
 * 		급여 테이블이 수정이 발생한 경우 전후 데이터 
 * 	- 비즈니스 프로세스 처리 단계용
 * 		구입 -> 재고 계산 -> 배송 을 하나의 비즈니스 프로세스로 동작시키기 위함.
 * 
 * 형식
 * 	- trigger time : 이벤트 발생 전 또는 발생 후
 * 	- event : insert, update, delete
 * 	- data 지시자 : old( event 발생 전 ), new ( event 발생 후 )
 * 
 * */

drop table if exists backup_userTbl

/* Trigger 실습용 */
CREATE TABLE backup_userTbl
( userID  varchar(8) NOT null,
  name    varchar(10) NOT NULL, 
  birthYear   int NOT NULL,  
  addr	  varchar(2) NOT NULL, 
  mobile1	varchar(3), 
  mobile2   varchar(8), 
  height    int,  
  mDate    date,
  modType  varchar(2), -- 변경된 타입. '수정' 또는 '삭제'
  modDate  date, -- 변경된 날짜
  modUser  varchar(256) -- 변경한 사용자
);

/* 비즈니스 프로세스 단계 처리용 */
CREATE TABLE orderTbl -- 구매 테이블
	(orderNo INT AUTO_INCREMENT PRIMARY KEY, -- 구매 일련번호
          userID VARCHAR(5), -- 구매한 회원아이디
	 prodName VARCHAR(5), -- 구매한 물건
	 orderamount INT );  -- 구매한 개수

CREATE TABLE prodTbl -- 물품 테이블
	( prodName VARCHAR(5), -- 물건 이름
	  account INT ); -- 남은 물건수량
      
CREATE TABLE deliverTbl -- 배송 테이블
	( deliverNo  INT AUTO_INCREMENT PRIMARY KEY, -- 배송 일련번호
	  prodName VARCHAR(5), -- 배송할 물건		  
	  account INT UNIQUE); -- 배송할 물건개수

/* 고객 정보 신규 등록시 경고 메시지 출력 : insert evnet */
	  
drop trigger if exists userTbl_InsertTrg_err_msg;

create trigger userTbl_InsertTrg_err_msg
	after insert -- insert 가 발생된 후 
	on userTbl -- trigger 가 부착될 대상
	for each row -- 모든 row를 대상
begin
	-- 경고 메세지 출력
	signal sqlstate '45000'
		set message_text = '신규 데이터가 입력됨';
end;


show triggers from shoppingmall;

insert into usertbl values('AAB','AAB',2004,'AA','010','11111111',170,'2024-06-19','일반고객');

select * from usertbl u where userID = 'AAB';


/* 고객 정보 신규 등록시 태어난 연도 검증용 트리거 : insert event */

drop trigger if exists backUserTbl_InserTrg;

create trigger backUserTbl_InserTrg
	before insert 
	on userTbl
	for each row
begin
	if new.birthYear < 1900 
		then set new.birthYear = 0;
	elseif new.birthYear > year(curdate()) 
		then set new.birthYear = year(curdate());
	end if;
end;

insert into usertbl values('AAB','AAB',1800,'AA','010','11111111',170,'2024-06-19','일반고객');

select * from usertbl u where userId = 'AAB';

insert into usertbl values('ZZZ','ZZZ',2000,'AA','010','11111111',170,'2024-06-19','일반고객');

select * from usertbl u where userId = 'ZZZ';


/* 고객 정보 수정시 백업 및 모니터링용 트리거 : update event */

drop trigger if exists backUserTbl_UpTrg;

create trigger backUserTbl_UpTrg
	after update
	on userTbl
	for each row 
begin 
	-- 변경 전 고객 데이터를 보관
	insert into backup_userTbl values(old.userID, old.name, old.birthYear,old.addr,
									old.mobile1,old.mobile2,old.height,old.mdate,
									'수정', curdate(), current_user);
end;

show triggers from shoppingmall;

select * from usertbl u where userID = 'BBK';
select * from backup_userTbl u where userID = 'BBK';

update usertbl u set addr = '부산' where userID = 'BBK';

/* 고객 정보 수정시 백업 및 모니터링용 트리거 : update event */

drop trigger if exists backUserTbl_DelTrg;

create trigger backUserTbl_DelTrg
	after delete
	on userTbl
	for each row
begin
	-- 변경 전 고객 데이터를 보관
		insert into backup_userTbl values(old.userID, old.name, old.birthYear,old.addr,
									old.mobile1,old.mobile2,old.height,old.mdate,
									'삭제', curdate(), current_user);
end;

show triggers from shoppingmall;

select * from usertbl u where userID = 'BBK';

delete from usertbl where userID = 'AAB';

select * from backup_usertbl  where userId = 'AAB';


/*
 * 비즈니스 프로세스 단계 처리용 trigger
 * 
 * 주문(orderTbl) -> 재고 계산(prodTbl) -> 배송(deliverTbl)
 * 	insert		->		update		->		insert
 * 
 * */


drop trigger if exists orderTbl_Trg;

create trigger orderTbl_Trg
	before insert
	on orderTbl
	for each row
begin
    DECLARE current_stock INT;
    
    SELECT account INTO current_stock FROM prodTbl WHERE prodName = NEW.prodName;
    IF current_stock >= NEW.orderamount 
    THEN
        UPDATE prodTbl SET account = account - NEW.orderamount WHERE prodName = NEW.prodName;
        INSERT INTO deliverTbl (prodName, account) VALUES (NEW.prodName, NEW.orderamount);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '재고가 부족합니다.';
    END IF;
END


desc prodtbl;
desc ordertbl;

/* 강의 */

/* orderTbl 의 event에 따라 동작하는 trigger 
 * 
 * 재고 계산(prodTbl)을 수행, update event 발생
 * */

drop trigger if exists orderTrg;

create trigger orderTrg
-- envet 지정
	after insert
-- event가 발생되는 table
	on ordertbl
-- 처리되는 row 대상	
	for each row
begin
	-- 상기의 3가지 조건에 부합되는 event일 경우
	-- 실제 수행해야 할 비즈니스 로직을 작성.
	-- 주문 제품에 대한 수량만큼 재고 수량 차감 업데이트 처리. => DML로 비즈니스 로직 구현
	
	-- new.orderamount : orderTbl.orderamount 에 insert 된 데이터
	-- 				     orderTbl.orderamount 기존에 없던 데이터가 신규로 삽입 되었으니,
	--					 그래서, 지시자를 new를 사용
	
	-- account - new.orderamount : 기존 재고 수량 - 신규 주문 수량
	update prodtbl set account = account - new.orderamount
		where prodName = new.prodName;
end;



/* prodTbl 의 event에 따라 동작하는 trigger 
 * 
 * 배송(deliverTbl)을 수행
 * */

drop trigger if exists prodTrg;

create trigger prodTrg
	-- prodTbl 에서 발생하는 update 에 대한 모든 row가 감지되면 
	-- begin 아래의 비즈니스 로직을 수행
	after update
	on prodtbl
	for each row
begin
	-- 배송 시작을 위한 배송 테이블에 정보를 입력.
	-- 제풀 배송을 위한 제품 수량을 확인
	-- 따라서, 발생되었던 event 정보에서 수량정보를 확인.
	-- prodTbl.account에 대한 값이 변경 전과 변경 후의 데이터가 공존.
	declare orderAmount int;
	
	-- prodTbl.account 의 변경 전 데이터와 변경 후 데이터를 사용해서 계산.
	set orderAmount = old.account - new.account;
	
	insert into delivertbl(prodName, account)
	values(new.prodName, orderAmount);
end;

/* 브릿지 스톤 : 일본 타이어 회사, 개발분위기 매우좋음, */


truncate ordertbl;
truncate prodtbl;
truncate delivertbl;

drop trigger if exists orderTbl_Trg2;

create trigger orderTbl_Trg2

-- 재고 테이블에 테스트용 데이터 등록
insert into prodTbl values('사과', 100);
insert into prodTbl values('배', 100);
insert into prodTbl values('귤', 100);

insert into orderTbl values (null, 'cus1', '배', 55);

select * from prodTbl;

select * from orderTbl;

select * from delivertbl;








