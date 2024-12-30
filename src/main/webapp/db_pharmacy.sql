drop table testTable;

create table testTable(
	SerialNumber varchar(50),
	medicineName varchar(10),
	Buyingprice varchar(10),
	price varchar(10),
	inventory varchar(10),
	kind varchar(20),
	companyName varchar(20),
	standard varchar(10),
	receiptDate varchar(10),
	DeliveryDate varchar(10),
	countNumber varchar(50),
	Bookmark varchar(2),
	returnInv varchar(1)
);

1.237.83.244

GRANT ALL PRIVILEGES ON *.* TO 'pharmacyKim'@'1.237.83.244' IDENTIFIED BY 'yourPassword';
FLUSH PRIVILEGES;


CREATE USER 'pharmacyKim'@'1.237.83.244' IDENTIFIED BY 'pharmacy@1234';
GRANT ALL PRIVILEGES ON *.* TO 'pharmacyKim'@'1.237.83.244';
FLUSH PRIVILEGES;




alter table testTable modify column inventory double;

alter table SalesRecord add column SerialNumber varchar(50);
alter table SalesRecord add column DeliveryDate varchar(10);

insert into testTable
	values(8802240002828 , "밴드골드 플러스", 500, 2000, 10, "기타" , "GC녹십자" , "10매" , "2023-03-31", "2026-04-19", 1, "0", "0");
insert into testTable
	values(6059560000023 , "제놀 빅", 500, 2000, 10, "파스류" , "주식회사 밴드골드" ,"5매", "2023-03-31", "2025-04-22", 2, "0", "1");
insert into testTable
	values(4902806100259  , "타이레놀", 500, 2000,  10, "일반의약품" , "테스트" , "30정", "2023-03-31", "2026-05-11", 3, "1", "1");
	
	
insert into testTable
	values(""  , "한약1", 100, 500,  10, "한약류" , "테스트" , "5g", "2023-03-31", "2026-05-11", 10, "0", "0");
insert into testTable
	values(""  , "한약2", 100, 500,  10, "한약류" , "테스트" , "5g", "2023-03-31", "2026-05-12", 9, "0", "0");
insert into testTable
	values(""  , "한약3", 100, 500,  10, "한약류" , "테스트" , "5g", "2023-03-31", "2026-05-13", 8, "0", "0");
insert into testTable
	values(""  , "한약4", 100, 500,  10, "한약류" , "테스트" , "5g", "2023-03-31", "2026-05-11", 7, "0", "0");
insert into testTable
	values(""  , "한약5", 100, 500,  10, "한약류" , "테스트" , "5g", "2023-03-31", "2026-05-12", 6, "0", "0");
insert into testTable
	values(""  , "한약6", 100, 500,  10, "한약류" , "테스트" , "5g", "2023-03-31", "2026-05-13", 5, "0", "0");
	
	
	
drop table SalesRecord;


create table SalesRecord(
    saleDate DATETIME,
    medicineName varchar(10),
	Buyingprice varchar(10),
	price varchar(10),
	inventory varchar(10)
);

create table clientRecord(
	clientName varchar(50),
	clientNumber varchar(20),
    saleDate DATETIME
);

alter table SalesRecord add memoClient varchar(10000);

delete from SalesRecord;
delete from clientRecord;
delete from priceRecord;

drop table clientRecord;

drop table priceRecord;

create table priceRecord(
	saleDate DATETIME,
	maxmedicinePrice varchar(10),
	generalPrice varchar(10)
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    userId VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (userId, password, email, name) 
VALUES ('a', '1', 'test2Email@example.com', '김주임');


alter table SalesRecord modify column saleDate TIMESTAMP(3);
alter table clientRecord modify column saleDate TIMESTAMP(3);
alter table priceRecord modify column saleDate TIMESTAMP(3);

create table vitalSet(
	medicineName varchar(40),
	price varchar(10),
	Buyingprice varchar(10),
	resource1 varchar(10),
	resource2 varchar(10),
	resource3 varchar(10),
	resource4 varchar(10),
	resource5 varchar(10)
);

select * from SalesRecord;
select * from priceRecord;


create table chartDater(
	inventory varchar(10),
	Buyingprice varchar(10),
	medicineName varchar(10),
	saleDate TIMESTAMP
);

insert into chartDater
	values()
	
	
create table herbalDB(
	medicineName varchar(10),
	setName varchar(10),
	price varchar(10),
	standard varchar(10)
);
	
	
commit;	

select * from testTable;
delete from testTable;
commit;
select * from testTable;


select medicineName, price, inventory, receiptDate, DeliveryDate from testTable;

select * from testTable;



create table fluctuationRecord(
	saleDate DATETIME,
	medicineName varchar(10),
	price varchar(10)
);




INSERT INTO SalesRecord (saleDate, medicineName, Buyingprice, price, inventory) VALUES 
('2023-06-01 10:00:00', 'MedA', '100', '1500', '10'),
('2023-06-02 11:00:00', 'MedB', '100', '2500', '20'),
('2023-06-03 12:00:00', 'MedC', '100', '3500', '15'),
('2023-06-04 12:00:00', 'MedC', '100', '2500', '10'),
('2023-06-04 13:00:00', 'MedC', '100', '3000', '15');