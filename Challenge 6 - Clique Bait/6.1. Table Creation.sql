CREATE SCHEMA clique_bait;
SET search_path = clique_bait;

DROP TABLE IF EXISTS clique_bait.event_identifier;
CREATE TABLE clique_bait.event_identifier (
  "event_type" INTEGER,
  "event_name" VARCHAR(13)
);

DROP TABLE IF EXISTS clique_bait.campaign_identifier;
CREATE TABLE clique_bait.campaign_identifier (
  "campaign_id" INTEGER,
  "products" VARCHAR(3),
  "campaign_name" VARCHAR(33),
  "start_date" TIMESTAMP,
  "end_date" TIMESTAMP
);

DROP TABLE IF EXISTS clique_bait.page_hierarchy;
CREATE TABLE clique_bait.page_hierarchy (
  "page_id" INTEGER,
  "page_name" VARCHAR(14),
  "product_category" VARCHAR(9),
  "product_id" VARCHAR(5)
);

DROP TABLE IF EXISTS clique_bait.users;
CREATE TABLE clique_bait.users (
  "user_id" INTEGER,
  "cookie_id" VARCHAR(6),
  "start_date" TIMESTAMP
);

DROP TABLE IF EXISTS clique_bait.events;
CREATE TABLE clique_bait.events (
  "visit_id" VARCHAR(6),
  "cookie_id" VARCHAR(6),
  "page_id" INTEGER,
  "event_type" INTEGER,
  "sequence_number" INTEGER,
  "event_time" TIMESTAMP
);


INSERT INTO clique_bait.event_identifier
	("event_type", "event_name")
VALUES
	('1', 'Page View'),
	('2', 'Add to Cart'),
	('3', 'Purchase'),
	('4', 'Ad Impression'),
	('5', 'Ad Click');
	
INSERT INTO clique_bait.users
	("user_id", "cookie_id", "start_date")
VALUES 
	('397',	'3759ff',	'2020-03-30 00:00:00'),
	('215',	'863329',	'2020-01-26 00:00:00'),
	('191',	'eefca9',	'2020-03-15 00:00:00'),
	('89',	'764796',	'2020-01-07 00:00:00'),
	('127',	'17ccc5',	'2020-01-22 00:00:00'),
	('81',	'b0b666',	'2020-03-01 00:00:00'),
	('260',	'a4f236',	'2020-01-08 00:00:00'),
	('203',	'd1182f',	'2020-04-18 00:00:00'),
	('23',	'12dbc8',	'2020-01-18 00:00:00'),
	('375',	'f61d69',	'2020-01-03 00:00:00');
	
INSERT INTO clique_bait.events
 	("visit_id",	"cookie_id",	"page_id",	"event_type", "sequence_number",	"event_time")
VALUES
	('719fd3',	'3d83d3',	'5',	'1',	'4',	'2020-03-02 00:29:09.975502'),
	('fb1eb1',	'c5ff25',	'5',	'2',	'8',	'2020-01-22 07:59:16.761931'),
	('23fe81',	'1e8c2d',	'10',	'1',	'9',	'2020-03-21 13:14:11.745667'),
	('ad91aa',	'648115',	'6',	'1',	'3',	'2020-04-27 16:28:09.824606'),
	('5576d7',	'ac418c',	'6',	'1',	'4',	'2020-01-18 04:55:10.149236'),
	('48308b',	'c686c1',	'8',	'1',	'5',	'2020-01-29 06:10:38.702163'),
	('46b17d',	'78f9b3',	'7',	'1',	'12',	'2020-02-16 09:45:31.926407'),
	('9fd196',	'ccf057',	'4',	'1',	'5',	'2020-02-14 08:29:12.922164'),
	('edf853',	'f85454',	'1',	'1',	'1',	'2020-02-22 12:59:07.652207'),
	('3c6716',	'02e74f',	'3',	'2',	'5',	'2020-01-31 17:56:20.777383');
	
INSERT INTO clique_bait.campaign_identifier
	("campaign_id",	"products",	"campaign_name", "start_date", "end_date")
VALUES
	('1',	'1',	'BOGOF - Fishing For Compliments',	'2020-01-01 00:00:00',	'2020-01-14 00:00:00'),
	('1',	'2',	'BOGOF - Fishing For Compliments',	'2020-01-01 00:00:00',	'2020-01-14 00:00:00'),
	('1',	'3',	'BOGOF - Fishing For Compliments',	'2020-01-01 00:00:00',	'2020-01-14 00:00:00'),
	('2',	'4',	'25% Off - Living The Lux Life',	'2020-01-15 00:00:00',	'2020-01-28 00:00:00'),
	('2',	'5',	'25% Off - Living The Lux Life',	'2020-01-15 00:00:00',	'2020-01-28 00:00:00'),
	('3',	'6',	'Half Off - Treat Your Shellf(ish)',	'2020-02-01 00:00:00',	'2020-03-31 00:00:00'),
	('3',	'7',	'Half Off - Treat Your Shellf(ish)',	'2020-02-01 00:00:00',	'2020-03-31 00:00:00'),
	('3',	'8',	'Half Off - Treat Your Shellf(ish)',	'2020-02-01 00:00:00',	'2020-03-31 00:00:00');
	
INSERT INTO clique_bait.page_hierarchy
	("page_id",	"page_name",	"product_category",	"product_id")
VALUES
	('1',	'Home Page',	'null',	'null'),
	('2',	'All Products',	'null',	'null'),
	('3',	'Salmon',	'Fish',	'1'),
	('4',	'Kingfish',	'Fish',	'2'),
	('5',	'Tuna',	'Fish',	'3'),
	('6',	'Russian Caviar',	'Luxury',	'4'),
	('7',	'Black Truffle',	'Luxury',	'5'),
	('8',	'Abalone',	'Shellfish',	'6'),
	('9',	'Lobster',	'Shellfish',	'7'),
	('10',	'Crab',	'Shellfish',	'8'),
	('11',	'Oyster',	'Shellfish',	'9'),
	('12',	'Checkout',	'null',	'null'),
	('13',	'Confirmation',	'null',	'null');
