/*=====================================================================================*/
   /************************ Online Job Portal Database **************************/
  
 /*Execute in the order of the steps*/
 /*========================================================================================*/
/* STEP-1 ) Creating database*/

	CREATE DATABASE TEAM_6
	GO
/*====================================================================================*/

/*Use TEAM_6 Database*/

	USE TEAM_6;
	
	/******************** END OF STEP-1 ************************/
/*============================CREATE SCHEMAS=======================================================*/
  /* STEP-2 Creating Schemas */

	CREATE SCHEMA Person AUTHORIZATION dbo;
	GO
	CREATE SCHEMA Company AUTHORIZATION dbo;
	GO
	CREATE SCHEMA Seeker AUTHORIZATION dbo;
	GO
	CREATE SCHEMA Job AUTHORIZATION dbo;
    GO

	/******************** END OF STEP-2 ************************/
/*====================================================================================*/
 /********* STEP-3) COLUMN DATA ENCRYPTION *****************/

/*Encrypt Table colums-- Password colum in Person.UserAccount table*/

/*Create Password protected Master key*/
	CREATE MASTER KEY 
	ENCRYPTION BY PASSWORD = 'TEAM_6_Password';

/*Create certificate to protect symetric key*/
	CREATE CERTIFICATE TeamSixCertificate
	WITH SUBJECT = 'Team 6 Certificate',
	EXPIRY_DATE = '2026-10-31';

/*Create symetric key to encrypt data*/
	CREATE SYMMETRIC KEY TeamSixSymmetricKey
	WITH ALGORITHM = AES_128
	ENCRYPTION BY CERTIFICATE TeamSixCertificate;

/* Open symmetric key */
	OPEN SYMMETRIC KEY TeamSixSymmetricKey
	DECRYPTION BY CERTIFICATE TeamSixCertificate;

	/******************** END OF STEP-3 ************************/
/*===============================================================================================*/

-- ******** STEP-4)  CREATE TABLES   ************
   -- ### Person #####

/*Creating Person realted tables*/

	CREATE TABLE Person.UserType
	(
		UserTypeID int PRIMARY KEY NOT NULL,
		UserTypeName varchar(255) NOT NULL
	);


	CREATE TABLE Person.UserAccount
	(
		UserAccountID int PRIMARY KEY NOT NULL,
		UserTypeID int NOT NULL,
		EmailID varchar(320) NOT NULL,
		Password VARBINARY(250) NOT NULL,
		PhoneNumber varchar(15),
		CONSTRAINT FK_UserTypeID FOREIGN KEY (UserTypeID)
		REFERENCES  Person.UserType(UserTypeID)
	)

	CREATE TABLE Person.UserLog
	(
		UserAccountID int PRIMARY KEY  NOT NULL,
		LastLoginDate Date,
		LastJobApplyDate Date,
		CONSTRAINT FK_UserAccountID FOREIGN KEY (UserAccountID)
		REFERENCES  Person.UserAccount(UserAccountID)
	)
	
   -- ### Company #####

/*Creating Company related tables*/

    CREATE TABLE Company.CompanyBusinessStream (
      CompanyBusinessStreamID INT NOT NULL PRIMARY KEY,
	  CompanyBusinessStreamName varchar(200)
    )

    CREATE TABLE Company.Company (
	  CompanyID INT NOT NULL PRIMARY KEY,
	  CompanyName varchar(200) NOT NULL,
	  CompanyBusinessStreamID INT FOREIGN KEY REFERENCES Company.CompanyBusinessStream(CompanyBusinessStreamID) NOT NULL,
	  CompanyWebsiteURL varchar(200),
	)

    CREATE TABLE Company.CompanyUserReview(
      CompanyUserReviewID int NOT NULL PRIMARY KEY,
	  UserAccountID INT  NOT NULL,
	  CompanyID INT NOT NULL,
	  Comments varchar(200),
	  Rating DECIMAL(3,2),
	  CONSTRAINT FK_CompanyUserReview_UserAccountID FOREIGN KEY (UserAccountID) REFERENCES Person.UserAccount(UserAccountID),
      CONSTRAINT FK_Company_CompanyID FOREIGN KEY (CompanyID) REFERENCES Company.Company(CompanyID)
    )

	 -- ### Job #####

/*Creating Job realted tables*/

	CREATE TABLE Job.JobLocation (
	  JobLocationID INT NOT NULL PRIMARY KEY,
	  StreetAddress varchar(255),
	  City varchar(255),
	  State varchar(255),
	  Zip varchar(255),
	);

	CREATE TABLE Job.JobType (
	  JobTypeID INT NOT NULL PRIMARY KEY,
	  JobTypeName varchar(255)
	);

	CREATE TABLE Job.JobPosting (
	  JobPostingID INT NOT NULL PRIMARY KEY,
	  CompanyID INT NOT NULL,
	  JobTypeID INT NOT NULL,
	  PostedDate DATE NOT NULL,
	  JobLocationID INT NOT NULL,
	  JobDescription varchar(512),
	  CONSTRAINT FK_CompanyID FOREIGN KEY (CompanyID) REFERENCES Company.Company(CompanyID),
	  CONSTRAINT FK_JobTypeID FOREIGN KEY (JobTypeID) REFERENCES Job.JobType(JobTypeID),
	  CONSTRAINT FK_JobLocationID FOREIGN KEY (JobLocationID) REFERENCES Job.JobLocation(JobLocationID)
	);

	CREATE TABLE Job.JobApplication (
	  UserAccountID INT NOT NULL,
	  JobPostingID INT NOT NULL,
	  ApplyDate DATE NOT NULL,
	  CONSTRAINT PK_JobApplication PRIMARY KEY CLUSTERED(UserAccountID, JobPostingID),
	  CONSTRAINT FK_UserAccountID FOREIGN KEY (UserAccountID) REFERENCES Person.UserAccount(UserAccountID),
	  CONSTRAINT FK_JobPostingID FOREIGN KEY (JobPostingID) REFERENCES Job.JobPosting(JobPostingID)
	);

	CREATE TABLE Seeker.Skill(
	  SkillID INT NOT NULL PRIMARY KEY,
	  SkillName varchar(255)	
	);

	CREATE TABLE Job.JobPostingSkill (
	  SkillID INT NOT NULL,
	  JobPostingID INT NOT NULL,
	  CONSTRAINT PK_JobPostingSkill PRIMARY KEY CLUSTERED (SkillID, JobPostingID),
	  CONSTRAINT FK_SkillID FOREIGN KEY (SkillID) REFERENCES Seeker.Skill(SkillID),
	  CONSTRAINT FK_JobSkill_JobPostingID FOREIGN KEY (JobPostingID) REFERENCES Job.JobPosting(JobPostingID),
	);

    
   -- ### Seeker #####
	
	/*Creating Seeker related tables*/

	CREATE TABLE Seeker.SeekerProfile (
	  UserAccountID INT NOT NULL PRIMARY KEY,
	  FirstName varchar(255) NOT NULL,
	  LastName varchar(255) NOT NULL,
	  Gender varchar(10),
	  DateofBirth Date
	  CONSTRAINT FK_SeekerProfile_UserAccountID FOREIGN KEY(UserAccountID)
		  REFERENCES Person.UserAccount(UserAccountID)
	)
	
	CREATE TABLE Seeker.SeekerEducation (
	  UserAccountID INT NOT NULL,
	  Degree varchar(255) NOT NULL,
	  Major varchar(255) NOT NULL,
	  UnivName varchar(255),
	  StartDate Date,
	  CompletedDate Date,
	  Gpa DECIMAL(2,1)
	  CONSTRAINT PK_SeekerEducation PRIMARY KEY CLUSTERED(UserAccountID, Degree, Major),
	  CONSTRAINT FK_SeekerEducation_UserAccountID FOREIGN KEY(UserAccountID)
		  REFERENCES Person.UserAccount(UserAccountID)
	)

	CREATE TABLE Seeker.SeekerExperience (
	  UserAccountID INT NOT NULL,
	  StartDate Date NOT NULL,
	  EndDate Date ,
	  CompanyName varchar(350) NOT NULL,
	  JobTitle varchar(255),
	  JobResponsibility varchar(500),
	  JobLocationID INT,
	  CONSTRAINT PK_SeekerExperience PRIMARY KEY CLUSTERED(UserAccountID, StartDate),
	  CONSTRAINT FK_SeekerExperience_UserAccountID FOREIGN KEY(UserAccountID)
		  REFERENCES Person.UserAccount(UserAccountID),
	  CONSTRAINT FK_SeekerExperience_JobLocationID FOREIGN KEY(JobLocationID)
		  REFERENCES Job.JobLocation(JobLocationID)
	)

	CREATE TABLE Seeker.SeekerSkill (
	  UserAccountID INT NOT NULL, 
	  SkillID INT NOT NULL,
	  SkillLevel varchar(255) 
	  CONSTRAINT PK_SeekerSkill PRIMARY KEY CLUSTERED (UserAccountID,SkillID),
	  CONSTRAINT FK_SeekerSkill_UserAccountID FOREIGN KEY(UserAccountID)
		  REFERENCES Person.UserAccount(UserAccountID),
	  CONSTRAINT FK_SeekerSkill_SkillID FOREIGN KEY(SkillID)
		  REFERENCES Seeker.Skill(SkillID)
	)
	  /*********************** END OF STEP-4 ************************/
/*=====================================================================================*/
					/********* STEP-5) COMPUTED COLUMNS  *************/

	CREATE FUNCTION CountJobsApplied (@UserAccount int)
	RETURNS int
	AS
	BEGIN
	DECLARE @count int
	SELECT @count = COUNT(j.JobPostingID) 
	FROM Job.JobApplication j 
	WHERE j.UserAccountID = @UserAccount
	GROUP BY UserAccountID 
	SET @count = ISNULL(@count,0)
	RETURN @count
	END
    GO

-- Adding 'JobsAppliedCount' as a computed column to seeker profile table based on the above function

ALTER TABLE Seeker.SeekerProfile ADD JobsAppliedCount AS dbo.CountJobsApplied(UserAccountID)
				
-- Adding 'IsCurrent' as a computed column to Seeker Experience 

	ALTER TABLE Seeker.SeekerExperience 
	ADD IsCurrent AS
	CASE
		WHEN (EndDate IS NULL) THEN 'TRUE' 
		ELSE 'FALSE'
	END
	
	
-- Adding 'Age' as a computed column to Seeker Profile 
	
	ALTER TABLE Seeker.SeekerProfile ADD Age AS DATEDIFF(hour,DateOfBirth,GETDATE())/8766;
	
	   /*********************** END OF STEP-5 ***************************/
/*=========================================================================================*/
				 /********* STEP-6) FUNCTION  *************/

/*Function to check phone number format- this constraint is added on UserAccount Table on Phone number column*/
    
	CREATE FUNCTION [dbo].[udf_CheckPhoneNumberFormat]
	(@strAlphaNumeric VARCHAR(14))
	RETURNS smallint
	AS
	BEGIN
		DECLARE @intAlpha INT
		DECLARE @tempNum  VARCHAR(14)
		DECLARE @result smallint
	SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
	SET @tempNum = @strAlphaNumeric
	SET @result = 0
	BEGIN
	WHILE @intAlpha > 0
		BEGIN
			SET @tempNum = STUFF(@tempNum, @intAlpha, 1, '' )
			SET @intAlpha = PATINDEX('%[^0-9]%', @tempNum ) 
		END
	SET @tempNum =  '(' + STUFF(STUFF(@tempNum,7,0,'-'),4,0,') ')
	IF @tempNum = @strAlphaNumeric
	 BEGIN
		  SET @result = 1
		END
	END
	RETURN @result
	END
	GO
	  
	  /****************** END OF STEP-6 *********************/
/*==============================================================================================*/

 /********* STEP-7) TABLE LEVEL CONSTRAINTS  *************/

/*Add phone number check on phone number column*/
	ALTER TABLE Person.UserAccount ADD CONSTRAINT RejectBadPhoneNumberFormat CHECK (dbo.udf_CheckPhoneNumberFormat(PhoneNumber) = 1);
	GO
/*Adding unique value constraint on EmailID*/
	ALTER TABLE Person.UserAccount ADD CONSTRAINT unique_emailId UNIQUE (EmailID);
	GO

	/*************** END OF STEP-7 ********************/
/*==============================================================================================*/

			 /********* STEP-8)  TRIGGER  *************/
/*Trigger to update lastJobAppliedDate in userlog table after row is inserted in JobApplication table */

	CREATE TRIGGER utrLASTJOBAPPLIEDDATE
	ON Job.JobApplication
	AFTER INSERT
	AS 
	BEGIN
		DECLARE @userAccountID INT;
		SET @userAccountID = (SELECT UserAccountID FROM Inserted);
		UPDATE  Person.UserLog SET LastJobApplyDate = GETDATE()
		WHERE UserAccountID = @userAccountID
	END
	GO

		 /*********  TRIGGER  *************/
 /* Trigger to add User entry in UserLog after User creation*/
	CREATE TRIGGER utrAddUserEntryInUserLogAfterUserCreation
	ON Person.UserAccount
	AFTER INSERT
	AS 
	BEGIN
		DECLARE @userAccountID INT;
		SET @userAccountID = (SELECT UserAccountID FROM Inserted);
		INSERT INTO  Person.UserLog VALUES (@userAccountID, GETDATE(),  GETDATE())
	END
	GO

	/******************** END OF STEP-8 *********************************/
/*===============================================================================================*/

          -- ********  INSERT SCRIPTS  ***********
   -- ### STEP-9) Person #####

	INSERT INTO Person.UserType
	VALUES (1, 'Recruiter'),
			(2, 'Job Seeker');
    
	INSERT INTO Person.UserAccount
	VALUES (1, 1, 'abc@gmail.com', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'abc@1234')), '(123) 123-9876');
	INSERT INTO Person.UserAccount
	VALUES (2, 2, 'pqr@gmail.com', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'pqr@1234')), '(123) 245-7685');
	INSERT INTO Person.UserAccount
	VALUES (3, 2, 'xyz@gmail.com', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'xyz@1234')), '(123) 678-9012');
	INSERT INTO Person.UserAccount
	VALUES (4, 1, 'mno@gmail.com', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'mno@1234')), '(123) 876-3846');
	INSERT INTO Person.UserAccount
	VALUES (5, 1, 'bnm@gmail.com', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'bmn@1234')), '(123) 287-1267');
	INSERT INTO Person.UserAccount
	VALUES (6, 2, 'lilly@gmail', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'lilly@1234')), '(123) 123-9876');
	INSERT INTO Person.UserAccount
	VALUES (7, 1, 'john@gmail.com', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'john@1234')), '(123) 369-9876');
	INSERT INTO Person.UserAccount
	VALUES (8, 1, 'jil@gmail.com', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'jil@1234')), '(123) 211-9876');
	INSERT INTO Person.UserAccount
	VALUES (9, 1, 'cary@gmail.com', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'cary@1234')), '(123) 221-9876');
	INSERT INTO Person.UserAccount
	VALUES (10, 2, 'tim@baker.com', EncryptByKey(Key_GUID(N'TeamSixSymmetricKey'), convert(varbinary, 'tim@1234')), '(123) 231-5454');

	/*********************** END OF STEP-9 ***************************/

		-- ### STEP-10) Company #####

	INSERT INTO  Company.CompanyBusinessStream VALUES (1001,'IT'),
	(1002,'Construction'),
	(1003,'Marketing'),
	(1004,'Media'),
	(1005,'Manufacturing'),
	(1006,'Business'),
	(1007,'Banking'),
	(1008,'Automotive'),
	(1009,'Sales'),
	(1010,'Entertainment')


	INSERT INTO Company.Company VALUES(123,'Microsoft',1006,'www.microsoft.com'),
	(234,'Facebook',1003,'www.facebook.com'),
	(345,'Twitter',1001,'www.twitter.com'),
	(456,'Lane',1002,'www.lane.com'),
	(567,'Filmy',1004,'www.filmy.com'),
	(678,'Tiktok',1004,'www.tiktok.com'),
	(700,'Ocean Spray',1006,'www.oceanspray.com'),
	(701,'Ahold',1007,'www.ahold.com'),
	(702,'Tesla',1008,'www.tesla.com'),
	(703,'Intel',1009,'www.intel.com')



	INSERT INTO Company.CompanyUserReview VALUES(10011,1,234,'Very Responsive and I higly reccommend one to apply to this company',5.0),
	(10022,2,345,'Pay scale is good',4.67),
	(10033,1,456,'Recruiters are really helpful',4.9),
	(10044,3,567,'I do not reccommend this',1.0),
	(10055,4,678,'good',4.0),
	(10066,5,234,'',4.8),
	(10077,2,702,'Reccommended',4.0),
	(10088,1,703,'good company',4.9),
	(10099,8,701,'Not bad',3.5),
	(10010,9,678,'',4.0)

		/*********************** END OF STEP-10 ***************************/
		
		-- ### STEP-11) Job #####
   
   INSERT INTO Job.JobType(JobTypeID, JobTypeName)
	VALUES
	(1, 'Software Development Engineer'),
	(2, 'Software Development Manager'),
	(3, 'Data Engineer'),
	(4, 'Business Analyst'),
	(5, 'Recruiter'),
	(6, 'Product Manager'),
	(7, 'Data Scientist'),
	(8, 'Software Developer'),
	(9, 'Security Engineer'),
	(10, 'Technical Program Manager'),
	(11, 'Hardware Engineer'),
	(12, 'Web Developer');

	INSERT INTO Job.JobLocation(JobLocationID, StreetAddress, City, State ,Zip)
	VALUES
	(1, '440 Terry Ave N', 'Seattle', 'WA', '98109'),
	(2, '2200 Mission College Blvd', 'Santa Clara', 'CA', '95054'),
	(3, '1600 Amphitheatre Parkway', 'Mountain View,', 'CA', '94043'),
	(4, '100 Hamilton Avey', 'Palo Alto', 'CA', '94301'),
	(5, '8779 Hillcrest Rd', 'Kansas City', 'MO', '64138'),
	(6, '1095 Avenue of the Americas', 'New York', 'NY', '10036'),
	(7, '3500 Deer Creek Road', 'Palo Alto', 'CA', '94304'),
	(8, 'North Harwood Street', 'Dallas', 'TX', '43123'),
	(9, '100 Hamilton Avey', 'Armonk', 'NY', null),
	(10, '100 Winchester Circle', 'Los Gatos', 'CA', '95032');

	INSERT INTO Job.JobPosting(JobPostingID, CompanyID, JobTypeID, PostedDate, JobLocationID, JobDescription)
	VALUES
	(1, 123, 1, '2020-01-20', 1, 'Design, develop, implement, test, and document embedded or distributed software applications'),
	(2, 123, 2, '2020-02-21', 2, 'Manage a talented team of engineers to create innovative technology that changes the face of organizational management'),
	(3, 123, 3, '2020-02-22', 3, 'Contribute to the architecture, design and implementation of next generation BI solutions – including streaming data applications'),
	(4, 234, 4, '2020-01-23', 4, 'Think strategically and analytically about business, product, and technical challenges, with the ability to work cross-organizationally'),
	(5, 234, 5, '2020-03-15', 5, 'Partner with teams to build effective sourcing and assessment, with an ability to manage customer/partner expectations'),
	(6, 234, 6, '2020-02-22', 6, 'Define features and processes, drive projects end-to-end, collaborate with numerous cross-functional teams to implement solutions'),
	(7, 345, 7, '2020-03-23', 7, 'Ability to apply Machine learning and find pattern in datasets to augment the existing recommendation engine'),
	(8, 345, 8, '2020-04-16', 8, 'develop scalable applications with rich user experiences'),
	(9, 345, 9, '2020-05-17', 9, 'Prevent ransom and ensure best cloud practises are followed'),
	(10, 456, 10, '2020-05-18', 10, 'Own and execute complex program expansion projects and drive key operational process improvement activities')


	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (1, 1, '2020-01-20');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (1, 3, '2020-02-22');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (1, 8, '2020-04-16');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (2, 2, '2020-02-21');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (2, 6, '2020-02-22');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (2, 10, '2020-05-19');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (6, 6, '2020-02-22');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (5, 3, '2020-02-22');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (4, 2, '2020-02-28');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (7, 9, '2020-05-17');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (2, 1, '2020-01-20');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (4, 1, '2020-01-20');
	INSERT INTO Job.JobApplication(UserAccountID, JobPostingID, ApplyDate)
	VALUES (5, 1, '2020-01-20');

				
	INSERT INTO Seeker.Skill VALUES (1,'C')
	INSERT INTO Seeker.Skill VALUES (2,'Java')
	INSERT INTO Seeker.Skill VALUES (3,'Python')
	INSERT INTO Seeker.Skill VALUES (4,'C#')
	INSERT INTO Seeker.Skill VALUES (5,'AWS')
	INSERT INTO Seeker.Skill VALUES (6,'SQL')
	INSERT INTO Seeker.Skill VALUES (7,'Nodejs')
	INSERT INTO Seeker.Skill VALUES (8,'HTML/CSS')
	INSERT INTO Seeker.Skill VALUES (9,'R')
	INSERT INTO Seeker.Skill VALUES (10,'AI/Machinelearning')
	INSERT INTO Seeker.Skill VALUES (11,'PHP')
	INSERT INTO Seeker.Skill VALUES (12,'Microsoft Azure')

	INSERT INTO Job.JobPostingSkill(SkillID, JobPostingID)
	VALUES
		(1, 1),
		(2, 1),
		(2, 3),
		(2, 8),
		(5, 1),
		(5, 7),
		(6, 1),
		(6, 6),
		(8, 1),
		(11, 8)


	/*********************** END OF STEP-11 ***************************/
			-- ### STEP-12) Seeker #####

	-- Seeker Profile
	INSERT INTO Seeker.SeekerProfile VALUES (1,'Kevin','Peterson','Male','1993-08-09')
	INSERT INTO Seeker.SeekerProfile VALUES (2,'Chris','Campbell','Male','1988-08-09')
	INSERT INTO Seeker.SeekerProfile VALUES (3,'Karen','Robbins','Female','1985-08-09')
	INSERT INTO Seeker.SeekerProfile VALUES (4,'Katie','Ricker','Female','1986-08-09')
	INSERT INTO Seeker.SeekerProfile VALUES (5,'Sandeep','Satyala','Male','1995-08-09')
	INSERT INTO Seeker.SeekerProfile VALUES (6,'Surya','Chinta','Female','1992-08-09')
	INSERT INTO Seeker.SeekerProfile VALUES (7,'Rahul','Ramchandra','Male','1988-08-09')
	INSERT INTO Seeker.SeekerProfile VALUES (8,'Storm','Mauritius','Male','1996-08-09')
	INSERT INTO Seeker.SeekerProfile VALUES (9,'Tom','Baker','Male','1984-08-09')
	INSERT INTO Seeker.SeekerProfile VALUES (10,'Timothy','Green','Male','1985-08-09')


	-- Seeker Skill
	INSERT INTO Seeker.SeekerSkill VALUES(1,1,'Beginner')
	INSERT INTO Seeker.SeekerSkill VALUES(1,2,'Intermediate')
	INSERT INTO Seeker.SeekerSkill VALUES(2,3,'Advanced')
	INSERT INTO Seeker.SeekerSkill VALUES(2,4,'Beginner')
	INSERT INTO Seeker.SeekerSkill VALUES(3,5,'Intermediate')
	INSERT INTO Seeker.SeekerSkill VALUES(3,6,'Advanced')
	INSERT INTO Seeker.SeekerSkill VALUES(4,7,'Beginner')
	INSERT INTO Seeker.SeekerSkill VALUES(4,8,'Intermediate')
	INSERT INTO Seeker.SeekerSkill VALUES(5,9,'Advanced')
	INSERT INTO Seeker.SeekerSkill VALUES(5,10,'Beginner')


	-- Seeker_Education
	INSERT INTO Seeker.SeekerEducation VALUES(1,'Bachelors','Computer Science','Brown State University','2015-09-10','2019-06-10',3.8)
	INSERT INTO Seeker.SeekerEducation VALUES(2,'Masters','Data Analytics','Purdue University','2012-09-10','2014-06-10',3.4)
	INSERT INTO Seeker.SeekerEducation VALUES(3,'Bachelors','Electrical Engineering','Carnegie Mellon University','2013-09-10','2017-06-10',3.2)
	INSERT INTO Seeker.SeekerEducation (UserAccountID,Degree,Major,UnivName,StartDate,Gpa) VALUES(4,'Ph.D','Statistics','Stanford University','2018-09-10',3.7)
	INSERT INTO Seeker.SeekerEducation (UserAccountID,Degree,Major,UnivName,StartDate,Gpa) VALUES(5,'Masters','Information Systems','Northeastern University','2019-09-10',3.6)
	INSERT INTO Seeker.SeekerEducation VALUES(6,'Masters','Information Technology','Purdue University','2014-09-10','2016-06-10',3.8)
	INSERT INTO Seeker.SeekerEducation VALUES(7,'Masters','Business Administration','Harvard University','2013-09-10','2015-06-10',3.8)
	INSERT INTO Seeker.SeekerEducation (UserAccountID,Degree,Major,UnivName,StartDate,Gpa)
	VALUES(8,'Masters','Computer Science','Texas A&M University','2019-09-10',3.8)
	INSERT INTO Seeker.SeekerEducation VALUES(9,'Ph.D','Wirless Communications','Cornell University','2014-09-10','2017-06-10',3.4)
	INSERT INTO Seeker.SeekerEducation VALUES(10,'Masters','Electronics Engineering','Carnegie Mellon University','2010-09-10','2012-06-10',3.8)

	-- Seeker_Experience
	INSERT INTO Seeker.SeekerExperience (UserAccountID,StartDate,CompanyName,JobTitle,JobResponsibility,JobLocationID)
	VALUES(1,'2019-07-10','Capgemini','Software Engineer','Build software solutions using Java',1)
	INSERT INTO Seeker.SeekerExperience 
	VALUES(2,'2015-07-10','2019-08-02','Pegasystems','Technical Solutions Engineer','Create support tickets and debug customer issues',2)
	INSERT INTO Seeker.SeekerExperience (UserAccountID,StartDate,CompanyName,JobTitle,JobResponsibility,JobLocationID)
	VALUES(2,'2019-09-10','Service Now','Technical Lead','Manage and lead development team ',2)
	INSERT INTO Seeker.SeekerExperience 
	VALUES(3,'2018-07-10','2019-08-02','Bose','Automation Engineer','design, program, simulate and test automated machinery and processes',3)
	INSERT INTO Seeker.SeekerExperience 
	VALUES(4,'2016-07-10','2018-08-02','Wayfair','Sales Consultant','Coordinate with customers in a sales environment to drive product sales',4)
	INSERT INTO Seeker.SeekerExperience (UserAccountID,StartDate,CompanyName,JobTitle,JobResponsibility,JobLocationID)
	VALUES(5,'2020-06-10','CDC Technologies','Software Engineer','Build and deploy software technologies',5)
	INSERT INTO Seeker.SeekerExperience 
	VALUES(6,'2018-07-10','2020-06-20','NetApp','Data Engineer','Managing data to simplify storage environment',6)
	INSERT INTO Seeker.SeekerExperience 
	VALUES(7,'2017-07-10','2019-08-02','Snowflake','Software Consultant','Functional analysis of major projects supporting several corporate initiatives',7)
	INSERT INTO Seeker.SeekerExperience 
	VALUES(7,'2019-08-10','2020-06-02','Amazon','Software Development Intern','Design and build the next generation of big data security analysis',8)
	INSERT INTO Seeker.SeekerExperience 
	VALUES(9,'2018-07-10','2019-08-02','Service Now','Senior ServiceNow Architect','Lead the overall design and development of multiple ServiceNow applications',9)
	INSERT INTO Seeker.SeekerExperience 
	VALUES(10,'2013-07-10','2018-08-02','IBM','Sr. Managing Consultant','Work face-to-face with clients to address their business, operations, and technology challenges ',10)

		/*********************** END OF STEP-12 ***************************/

/*====================================================================================*/
-- ******* STEP-13) VIEWS *************

	-- Find all Software development Engineer applications for company 123
	CREATE VIEW vwSDEApplication
	AS
	SELECT sp.FirstName, sp.LastName, ua.EmailID, c.CompanyName, ua.PhoneNumber  FROM Job.JobApplication ja
		INNER JOIN Job.JobPosting jp ON ja.JobPostingID = jp.JobPostingID
		INNER JOIN Company.Company c ON jp.CompanyID = c.CompanyID
		INNER JOIN Seeker.SeekerProfile sp ON sp.UserAccountID = ja.UserAccountID
		INNER JOIN Person.UserAccount ua ON ua.UserAccountID = ja.UserAccountID
		WHERE jp.JobTypeID = 1 and jp.CompanyID = 123
	GO

	-- Total job postings by each company
	CREATE VIEW vwTotalJobPostingsByCompanyView
	AS
	SELECT c.CompanyName, COUNT(jp.JobPostingID) AS TotalJobPosting 
	FROM Company.Company c
		 INNER JOIN Job.JobPosting jp ON c.CompanyID = jp.CompanyID
	GROUP BY c.CompanyID, c.CompanyName 
	GO


	/*View to find the rating and comments given by the user*/

	CREATE VIEW userRating AS
	SELECT UA.UserAccountID,CompanyName,UR.Comments,UR.Rating from Person.UserAccount UA JOIN Company.CompanyUserReview UR on 
	UR.UserAccountID=UA.UserAccountID JOIN Company.Company CC on CC.CompanyID=UR.CompanyID
	GO

		/*********************** END OF STEP-13 ***************************/
/*====================================================================================*/

/*===============SELECT STATEMENTS=====================================================*/

	/*We see all encrypted passwords*/
	Select * from Person.UserAccount;

	/*Use DecryptByKey to decrypt the encrypted data. We receive the output in binary format*/
	Select EmailID, DecryptByKey(Password) as Password from Person.UserAccount;

	 /* Use DecryptByKey to decrypt the encrypted data.
	 DecryptByKey returns VARBINARY with a maximum size of 8,000 bytes
	Also use CONVERT to convert the decrypted data to VARCHAR so that we can see the plain passwords */
	Select EmailID, convert(varchar, DecryptByKey(Password)) as Password from Person.UserAccount;

	/* Validate the format of phone number */
	select [dbo].[udf_CheckPhoneNumberFormat] ('(123) 287-1267');
	select [dbo].[udf_CheckPhoneNumberFormat] ('1232871267');

	/*To find Company that has highest rating*/

	SELECT TOP 1 WITH TIES UR.Rating,CC.CompanyID,CC.CompanyName, 
	RN = DENSE_RANK() OVER(partition BY CC.CompanyID ORDER BY UR.Rating DESC) 
	FROM Company.Company CC INNER JOIN Company.CompanyUserReview UR on UR.CompanyID=CC.CompanyID 
	ORDER BY UR.Rating DESC,CC.CompanyID;

	
	SELECT * FROM vwSDEApplication
	SELECT * FROM vwTotalJobPostingsByCompanyView
	SELECT * FROM userRating;


	SELECT * from Person.UserType
	SELECT * from Person.UserAccount
	SELECT * from Person.UserLog
	SELECT * from Job.JobApplication
	SELECT * from [Job].[JobLocation]
	SELECT * from [Job].[JobPosting]
	SELECT * from [Job].[JobPostingSkill]
	SELECT * from [Job].[JobType]
	SELECT * FROM Company.Company
	SELECT * FROM Company.CompanyBusinessStream
	SELECT * FROM Company.CompanyUserReview
	SELECT * FROM Seeker.SeekerProfile
	SELECT * FROM Seeker.SeekerSkill
	SELECT * FROM Seeker.SeekerEducation
	SELECT * FROM Seeker.SeekerExperience
	SELECT * FROM Seeker.Skill

--############################## DELETE SCRIPTS ##################################
	DELETE FROM [Job].[JobPostingSkill]
	DELETE FROM [Seeker].[SeekerSkill]
	DELETE FROM [Seeker].[Skill]
	DELETE FROM [Seeker].[SeekerExperience]
	DELETE FROM [Job].[JobApplication]
	DELETE FROM [Job].[JobPosting]
	DELETE FROM [Job].[JobLocation]
	DELETE FROM [Job].[JobType]
    DELETE FROM [Seeker].[SeekerEducation]
	DELETE FROM [Seeker].[SeekerProfile]
	DELETE FROM Company.CompanyUserReview
	DELETE FROM Company.Company
	DELETE FROM Company.CompanyBusinessStream
	DELETE FROM Person.UserLog
	DELETE FROM Person.UserAccount
	DELETE FROM Person.UserType

	DROP VIEW vwSDEApplication
	DROP VIEW vwTotalJobPostingsByCompanyView
	DROP VIEW userRating

	DROP TABLE [Job].[JobPostingSkill]
	DROP TABLE [Seeker].[SeekerSkill]
	DROP TABLE [Seeker].[Skill]
	DROP TABLE [Job].[JobApplication]
	DROP TABLE [Job].[JobPosting]
	DROP TABLE [Seeker].[SeekerExperience]
	DROP TABLE [Job].[JobLocation]
	DROP TABLE [Job].[JobType]
    DROP TABLE [Seeker].[SeekerEducation]
	DROP TABLE [Seeker].[SeekerProfile]
	DROP TABLE Company.CompanyUserReview
	DROP TABLE Company.Company
	DROP TABLE Company.CompanyBusinessStream
	DROP TABLE Person.UserLog
	DROP TABLE Person.UserAccount
	DROP TABLE Person.UserType

	ALTER TABLE Seeker.SeekerProfile
	DROP COLUMN Age
	ALTER TABLE Seeker.SeekerProfile
	DROP COLUMN JobsAppliedCount
	ALTER TABLE Seeker.SeekerExperience
	DROP COLUMN IsCurrent
	ALTER TABLE Person.UserAccount
	DROP CONSTRAINT RejectBadPhoneNumberFormat
	ALTER TABLE Person.UserAccount
	DROP CONSTRAINT unique_emailId

	DROP FUNCTION [dbo].[udf_CheckPhoneNumberFormat]
	DROP FUNCTION CountJobsApplied

	













