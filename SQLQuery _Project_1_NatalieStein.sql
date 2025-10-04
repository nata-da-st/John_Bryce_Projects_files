USE master

GO

if exists (select * from sysdatabases where name='HealthCareSystemDemo')
		drop database HealthCareSystemDemo
GO

CREATE DATABASE HealthCareServiceDemo

GO

USE HealthCareServiceDemo

GO

--NEW 6 RELATED TABLES

--טבלת מרכזים רפואי
ים
CREATE TABLE MedicalCenters
	(MCenterID INT IDENTITY,
	MCenterName VARCHAR (25) NOT NULL,
	City VARCHAR (25) NOT NULL,
	District VARCHAR (20),
	CONSTRAINT mc_mcen_pk PRIMARY KEY (MCenterID)
	 )

GO


----טבלת עובדים

CREATE TABLE Employees
	(EmployeeID	 INT IDENTITY,
	LastName	VARCHAR(25)	NOT NULL,
	 FistName	VARCHAR(25)	NOT NULL,
	 Birthdate	DATE	NOT NULL,
	 HireDate	DATETIME DEFAULT GETDATE(),
	 ProfessionType	VARCHAR(25)	NOT NULL,
	 MCenterID 	 INT ,
	 Salary	MONEY	DEFAULT (0),
	 CONSTRAINT emp_empID_pk PRIMARY KEY (EmployeeID),
	 CONSTRAINT emp_mcen_fk FOREIGN KEY ( MCenterID  ) REFERENCES  MedicalCenters (MCenterID),
	 CONSTRAINT emp_sal_ck CHECK (Salary >=0)
	 )

	 GO

--טבלת מטופלים
	
CREATE TABLE Patients
	(PatientID INT NOT NULL,
	LastName	VARCHAR(25)	NOT NULL,
	FistName	VARCHAR(25)	NOT NULL,
	Birthdate	DATE,
	City	VARCHAR(25)	NOT NULL,
	HomePhone	VARCHAR(15),
	CellPhone	VARCHAR(15),
	Email	VARCHAR(30)	NOT NULL,
	CONSTRAINT pat_pID_pk PRIMARY KEY (PatientID),
	CONSTRAINT pat_email_ck CHECK (email LIKE '%@%.%'),
	CONSTRAINT pat_email_uk UNIQUE (email)
	)


GO

--טבלת קטגוריות (קשורה לציוד)


CREATE TABLE Categories
	(CategoryID	 INT 	IDENTITY,
	CategoryName	VARCHAR(25),
	SupplierID	 INT 	NOT NULL,
	CONSTRAINT cat_catID_pk	PRIMARY KEY (CategoryID)
	)

GO

--טבלת ציוד רפואי

CREATE TABLE MedicalEquipments
	(MedicalEquipmentID	 INT 	IDENTITY,
	CategoryID	 INT 	NOT NULL,
	ToolName	VARCHAR(25),
	UnitePrice	MONEY,
	UnitinStock	 INT ,
	 MCenterID 	 INT 	NOT NULL,
	CONSTRAINT meq_meqID_pk	PRIMARY KEY (MedicalEquipmentID),
	CONSTRAINT meq_catID_fk	FOREIGN KEY (CategoryID   ) REFERENCES  Categories ( CategoryID ),
	CONSTRAINT meq_mcenID_fk	FOREIGN KEY  (MCenterID ) REFERENCES  MedicalCenters (  MCenterID  )						
	) 


GO
--טבלת ביקורים  

CREATE TABLE Visits
	(VisitID  INT 	IDENTITY,
	PatientID	 INT 	NOT NULL, 
	Visitdate	DATETIME	NOT NULL,
	EmployeeID	 INT 	NOT NULL,
	 MCenterID 	 INT 	NOT NULL,
	 CONSTRAINT  vis_visID_pk	PRIMARY KEY (VisitID),
	 CONSTRAINT vis_patID_fk	FOREIGN KEY ( PatientID  ) REFERENCES  Patients (PatientID),
	 CONSTRAINT vis_empID_fk	FOREIGN KEY ( EmployeeID  ) REFERENCES  Employees (EmployeeID),
	 CONSTRAINT vis_mcenID_fk	FOREIGN KEY ( MCenterID   ) REFERENCES  MedicalCenters ( MCenterID ),						
	 CONSTRAINT vis_vdate_ck CHECK (Visitdate >='2000-01-01')
	 )

GO

--INSERT VALUES TABLE MedicalCenters, MCenterID is Identity

INSERT INTO  MedicalCenters
VALUES ('Dania',	'Haifa',	'Tzafon'),
		('Nazareth',	'Nazareth'	,'Tzafon'),
		('Afeka'	,'Kiryat Bialik'	,'Tzafon'),
		('Tel hai'	,'Kiryat Shmona'	,'Tzafon'),
		( 'Green Nahariya',	'Nahariya','Tzafon'),
		( 'Hasharon',	'Herzliya',	'Hasharon'),
		('Zerubabel',	'Herzliya',	'Hasharon' ),
		( 'Viva Hadera'	,'Hadera','Hasharon'),
		('Harish',	'Harish','Hasharon' ),
		( 'Green Kfar Sava'	,' Kfar Sava' ,Null),
		( 'South Netanya'	,	'Netanya'	,	'Hasharon'),
		( 'Hashla'	,	'Tel Aviv'	,	'Merkaz'),
		( 'Hashslom'	,	'Tel Aviv'	,	'Merkaz'),
		('Hadar'	,	'Tel Aviv'	,	'Merkaz' ),
		('Marom'	,	'Ramat Gan'	,	'Merkaz' ),
		('Ben Gurion'	,	'Givatayim'	,	'Merkaz'),
		( 'Ramon'	,	'Or Yehuda'	, NULL),
		('Ben Gurion'	,	'Ofakim'	,	'Darom' ),
		( 'Rimon'	,	'Beer Sheva'	,	'Darom'),
		( 'Ashdod d'	,	'Ashdod'	,	'Darom'),
		('Agamim'	,	'Ashkelon'	,	'Darom' ),
		( 'Kdoshei Kahir'	,	'Bat Yam'	,	'Jerusalem Hashfela'),
		( 'Hoofien'	,	'Holon'	,	'Jerusalem Hashfela'),
		('Moreshet'	,	'Modiin'	,	'Jerusalem Hashfela' )


GO

--INSERT VALUES TABLE Employees, EmployeeID IDENTITY


INSERT INTO  Employees
VALUES ('Cohen',	'Yossi',	'1993-06-22',	'2025-05-11 04:29:40',	'Doctor',	1,	30000),
		('Sasson',	'Gabi',	'1987-03-17',	'2024-11-07 19:05:29',	'Nurse',	10,	18000),
		('Gabay',	'Orna',	'1993-06-22',	'2015-03-09 17:49:39',	'Laborant',	12,	7000),
		('Shemesh',	'Aviva  ',	'1987-03-17',	'2017-05-06 08:45:19',	'Nurse',	9,	17600),
		('Michaeli',	'Rivka ',	'2000-03-12',	'2020-08-31 14:30:13',	'Physiotheraist',	1,	15300),
		(' Levi',	'Ilanit',	'1979-01-16',	'2016-04-15 11:14:29',	'Dietitian',	6,	12500),
		('Ginat',	'Limor ',	'1996-07-09',	'2022-01-22 19:18:02',	'Doctor',	5,	32000),
		('Antebi',	'Shaul',	'2000-10-26',	'2015-10-07 19:03:08',	'Nurse',	22,	16700),
		('Menachem',	'Yitzhak ',	'1973-01-26',	'2025-01-28 04:33:39',	'Nurse',	2,	18200),
		('Cohen',	'Roni ',	'1959-09-25',	'2017-02-07 13:56:02',	'Physiotheraist',	8,	14600),
		(' Levi',	'Roni',	'1968-02-06',	'2023-06-15 17:14:40',	'Dietitian',	7,	13900),
		('Golan',	'Sharon ',	'1968-12-16',	'2021-07-28 15:04:50',	'Doctor',	3,	27300),
		(' Shmuel',	'Shirin',	'1959-05-01',	'2023-04-12 06:46:22',	'Dietitian',	5,	12000),
		('Kesef',	'Hila ',	'1979-11-05',	'2022-07-09 01:04:48',	'Nurse',	11,	16800),
		('Semionovitz',	'Moshe ',	'1970-06-28',	'2023-06-27 08:25:30',	'Nurse',	4,	16500),
		('Markovitz',	'Liron ',	'1960-06-15',	'2018-01-16 12:36:18',	'Physiotheraist',	15,	12700),
		('Sapir',	'Alex',	'1968-02-28',	'2017-10-28 09:00:56',	'Dietitian',	16,	11800),
		('Stein',	'Boris',	'1980-07-04',	'2024-03-13 16:33:11',	'Doctor',	16,	29600),
		('Stein',	'Michal',	'1961-02-14',	'2015-10-05 08:25:58',	'Laborant',	23,	6500),
		('Rozen',	'Ilanit',	'1996-10-01',	'2018-02-21 08:37:01',	'Nurse',	6,	17700)


GO


--UPDATE TABLE Employees with DEFAULTS [HireDate GETDATE(), Salary '0']


INSERT INTO Employees (LastName, FistName, Birthdate, ProfessionType,  MCenterID  )
VALUES ('Laskavy',	'Lily',	'1955-06-17','Laborant', 8),
		('Barsky',	'Yoram',	'1996-07-12', 'Nurse',	10)

GO


--INSERT VALUES TABLE Patients 

INSERT INTO Patients
VALUES ('749382615',	'Omer',	'    Cohen',	 ' 1984-10-14 ', 	'Hertzlia',	'03-5689945',	'050-6658967',	'Omer_C@gmail.com'),
		('208736492',	'Noa',	'        Levi',	 ' 1998-10-11 ', 	'Tel Aviv',	'02-6543210',	'050-1234567',	'Noa_l@gmail.com'),
		('591037284',	'Yoav',	'    Mizrahi',	 ' 1979-07-21 ', 	'Holon',	'03-7654321',	'052-2345678',	'Yoav_M@gmail.com'),
		('384920175',	'Roni',	'    Peretz',	 ' 1967-12-15 ', 	'Kityat Gat',	'04-8765432',	'053-3456789',	'Roni_P@gmail.com'),
		('102948375',	'Itay',	'    Avrahami',	 ' 1971-12-30 ', 	'Bat Yam',	'08-3456789',	'054-4567890',	'Itay_A@gmail.com'),
		('739201846',	'Shira',	'    Dayan',	 ' 1977-08-30 ', 	'Tel Aviv',	'09-1234567',	'055-5678901',	'Shira_D@gmail.com'),
		('680193724',	'Daniel',	'    Biton',	 ' 1971-07-29 ', 	'Haifa',	'072-2500000',	'058-6789012',	'Daniel_B@gmail.com'),
		('920384716',	'Maya',	'    Ben Hamo',	 ' 2010-06-27 ', 	'Holon',	'073-3300000',	'056-7890123',	'Maya_B@gmail.com'),
		('407193628',	'Alon',	'    Sharabi',	 ' 1966-05-03 ', 	'Yerusalem',	'074-4400000',	'057-8901234',	'Alon_S@gmail.com'),
		('193820647',	'Tamar',	'    Saban',	 ' 1983-07-20 ', 	'Modiin',	'076-5500000',	'059-9012345',	'Tamar_S@gmail.com'),
		('837465120',	'Gal',	'        Barak',	 ' 2002-07-08 ', 	'Rishon LeZion',	'077-6600000',	'051-0123456',	'Gal_B@gmail.com'),
		('615928374',	'Adi',	'        Azulai',	 ' 2009-02-14 ', 	'Haifa',	'02-1111222',	'050-1111222',	'Adi_A@gmail.com'),
		('340917582',	'Yael',	'    Tzfati',	 ' 1975-11-13 ', 	'Raanana',	'03-2221333',	'052-2221333',	'Yael_T@hotmail.com'),
		('275948103',	'Liam',	'    Ben David',	 ' 1991-03-17 ', 	'Harish',	'04-3331444',	'053-3331444',	'Liam_B@hotmail.com'),
		('823745901',	'Michal',	'    Ohana',	 ' 1979-09-07 ', 	'Tel Aviv',	'08-4441555',	'054-4441555',	'Michal_O@hotmail.com'),
		('564738290',	'Idan',	'    Malka',	 ' 1975-10-18 ', 	'Yerusalem',	'09-5551666',	'055-5551666',	'Idan_M@hotmail.com'),
		('738201946',	'Ella',	'    Gabay',	 ' 1983-01-04 ', 	'Ramat HaSharon',	'072-6661777',	'056-6661777',	'Ella_G@hotmail.com'),
		('492817365',	'Noam',	'    Ozen',	 ' 1997-02-27 ', 	'Shlomi',	'073-7771888',	'057-7771888',	'Noam_O@gmail.com'),
		('803749215',	'Shahar',	'    Suissa',	 ' 1962-10-18 ', 	'Kiryat Shmona',	'074-8881999',	'058-8881999',	'Shahar_S@gmail.com'),
		('694182730',	'Nina',	'    Elbaz',	 ' 1962-10-05 ', 	'Eilat',	'076-9991000',	'059-9991000',	'Nina_E@gmail.com'),
		('172930845',	'Eilon',	'    Hadad',	 ' 2008-09-12 ', 	'Tel Aviv',	'077-1010101',	'051-1010101',	'Eilon_H@gmail.com'),
		('359827104',	'Hadar',	'    Maman',	 ' 1970-12-18 ', 	'Beer Sheva',	'02-2020202',	'050-2020202',	'Hadar_M@gmail.com'),
		('781264309',	'Yonatan',	'    Nahum',	 ' 1972-07-16 ', 	'Haifa',	'03-3030303',	'052-3030303',	'Yonatan_N@gmail.com'),
		('948120367',	'Romi',	'    Solomon',	 ' 1974-04-22 ', 	'Yerusalem',	'04-4040404',	'053-4040404',	'Romi_S@gmail.com'),
		('610283947',	'Amit',	'    Abutbul',	 ' 2009-12-06 ', 	'Givat Shmuel',	'08-5050505',	'054-5050505',	'Amit_A@gmail.com')


GO


--INSERT VALUES TABLE Visits, VisitID is Identity

INSERT INTO Visits
VALUES ('749382615',	'2021-07-19 04:56:57',	'6',	'6'),
		('208736492',	'2019-11-22 05:02:36',	'9',	'2'),
		('591037284',	'2022-12-09 03:29:10',	'12',	'3'),
		('384920175',	'2019-03-10 10:32:35',	'8',	'22'),
		('102948375',	'2022-08-28 16:54:30',	'15',	'4'),
		('739201846',	'2020-12-21 00:40:11',	'14',	'11'),
		('680193724',	'2023-03-04 07:31:32',	'8',	'22'),
		('837465120',	'2019-01-07 10:30:12',	'10',	'8'),
		('781264309',	'2022-12-18 00:06:15',	'7',	'5'),
		('102948375',	'2019-11-20 09:43:26',	'8',	'22'),
		('920384716',	'2020-07-06 05:47:01',	'14',	'11'),
		('407193628',	'2020-07-19 01:10:24',	'15',	'4'),
		('193820647',	'2021-01-29 14:38:59',	'18',	'16'),
		('837465120',	'2020-05-05 14:54:47',	'8',	'22'),
		('615928374',	'2022-03-31 17:45:03',	'20',	'6'),
		('340917582',	'2024-02-03 05:14:10',	'2',	'10'),
		('275948103',	'2022-03-14 02:53:36',	'14',	'11'),
		('359827104',	'2025-01-07 12:42:22',	'18',	'16'),
		('837465120',	'2020-03-08 13:18:17',	'22',	'10'),
		('694182730',	'2023-03-29 07:37:42',	'3',	'12'),
		('172930845',	'2020-04-20 11:23:50',	'1',	'1'),
		('359827104',	'2020-04-13 16:56:27',	'14',	'11'),
		('837465120',	'2022-12-29 02:57:33',	'20',	'6'),
		('948120367',	'2020-02-21 04:25:07',	'4',	'9'),
		('610283947',	'2019-11-27 04:29:29',	'19',	'23'),
		('803749215',	'2021-12-19 17:22:16',	'20',	'6'),
		('694182730',	'2020-07-03 23:34:59',	'16',	'15'),
		('837465120',	'2020-06-15 01:06:03',	'17',	'16')


GO

--INSERT VALUES TABLE Categories, CategoryID is Identity

INSERT INTO Categories
VALUES ('Imaging',	'4729'),
		('X-ray',	'1056'),
		('Medications_nurses ',	'8391'),
		('Injection_equipment',	'2674'),
		('Surgical_equipment',	'5903'),
		('Office_supplies',	'3187'),
		('Disinfection_supplies',	'7462'),
		('Resuscitation_cart',	'2048'),
		('Furniture',	'6591'),
		('Electrical_appliances',	'3810'),
		('Staff_uniforms',	'9234'),
		('Staff_food',	'1475'),
		('Toilet_supplies','7306'),
		('Computers',	'8601'),
		('Telephony',	'4927'),
		('Fax machines',	'3160'),
		('Scanners',	'5782'),
		('Cleaning materials',	'6840'),
		('Refrigerators',	'2993'),
		('Tv_screens',	'1458')


GO

--UPDATE TABLE MedicalEquipments with MedicalEquipmentsID IDENTITY


INSERT INTO MedicalEquipments
VALUES ('3',	'5 ml syringe  ',	'0.2',	'1000',	'1'),
		('3',	'3 ml syringe  ',	'0.2',	'1000',	'2'),
		('3',	'1 ml syringe  ',	'0.5',	'1000',	'3'),
		('3',	'Needle 25  ',	'0.01',	'15000',	'4'),
		('3',	'Needle 23  ',	'0.01',	'15000',	'5'),
		('3',	'Needle 21  ',	'0.02',	'15000',	'6'),
		('7',	'Swabs  ',	'1',	'20000',	'7'),
		('7',	'Alcohol  ',	'5',	'50',	'8'),
		('8',	'Adrenaline ampoules  ',	'2',	'50',	'9'),
		('8',	'Atropine ampoules  ',	'2.5',	'50',	'10'),
		('8',	'Ambu bag  ',	'75',	'10',	'11'),
		('8',	'Defibrillator  ',	'3000',	'5',	'12'),
		('18',	'Bleach  ',	'15',	'25',	'13'),
		('6',	'Pen  ',	'5',	'100',	'14'),
		('6',	'Pencil  ',	'1.2',	'100',	'15'),
		('20',	'50-inch screen  ',	'450',	'10',	'16'),
		('20',	'70-inch screen  ',	'650',	'10',	'17'),
		('9',	'Regular chair  ',	'70',	'35',	'18'),
		('9',	'Wheelchair  ',	'200',	'10',	'19'),
		('9',	'Desk  ',	'400',	'5',	'20'),
		('9',	'Treatment bed  ',	'440',	'10',	'21')

GO

--UPDATE TABLE MedicalEquipments with DEFAULTS [ ToolName,UnitPrice, UnitinStock]


INSERT INTO MedicalEquipments (CategoryID, MCenterID)
VALUES ('9','21')

GO


--SAMPLES OF SELECTS ON THIS DATABASE

--יש להציג את המטופלים שביקרו במהלך שנת 2020 במרכז רפואי
--'South Netanya'

SELECT p.PatientID
	,p.FistName + ' '+ p.LastName AS "Full_Patient_Name"
	,YEAR (vs.Visitdate) AS "VISIT_YEAR"
	FROM   Patients p JOIN Visits vs 
ON p.PatientID = vs.PatientID
JOIN MedicalCenters mc
ON vs.MCenterID = mc.MCenterID
WHERE YEAR (vs.Visitdate) ='2020'
AND mc.MCenterName ='South Netanya'


--יש לדרג את המטופלים לפי הגיל מהמבוגר ביותר לצעיר בכל אחד מהמרכזים הרפואים 



SELECT	p.PatientID
	,p.FistName + ' '+ p.LastName AS "Full_Patient_Name"
	,DATEDIFF (yy,p.Birthdate, GETDATE()) AS AGE
	,ROW_NUMBER () OVER (PARTITION BY mc.MCenterName ORDER BY DATEDIFF (yy,p.Birthdate, GETDATE()) DESC) AS RNK 
FROM   Patients p JOIN Visits vs 
ON p.PatientID = vs.PatientID
JOIN MedicalCenters mc
ON vs.MCenterID = mc.MCenterID






