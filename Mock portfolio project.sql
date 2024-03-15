
-- some notes about the data

-- the data comes from a kaggle post who's poster extracted the data
-- from UNESCO,UNICEF and United Nations Statistics Division database
-- the data is dated to 2021

-- kaggle post LINK: https://www.kaggle.com/datasets/nelgiriyewithana/world-educational-data/data

-- while the source didn't specify the units used
-- its safe to assume that the units used are percentages,
-- the completion percentages and youth literacy are inversed (100 - value) and
-- birthrate is value / 1000 people
-- Proficency and enrollment are unknown however its irrelevent to this project since it doesn't
-- distinguish between males and females


select * from world_education_data.global_education
-- where CountriesAndRegions = "Kyrgyzstan"

--@block
-- dropping unneeded collumns and renaming a collumn with a proper naming convention

ALTER TABLE world_education_data.global_education
DROP Gross_Tertiary_Education_Enrollment,
DROP Gross_Primary_Education_Enrollment,
DROP Lower_Secondary_End_Prodicency_Reading,
DROP Lower_Secondary_End_Prodicency_Math
DROP Lower_Secondary_End_Proficiency_Math,
DROP Lower_Secondary_End_Proficiency_Reading

-- used Select MAX(LENGHT(Collumn)) to find out the lenght of the longest string

ALTER TABLE world_education_data.global_education
CHANGE COLUMN `Countries and areas` `CountriesAndRegions` VARCHAR(47);

-- dropping North Korea, inaccurate data

Delete from World_Education_data.global_education
where CountriesAndRegions = "North Korea"

--@block

-- the next 7 queries all have 2 cases statements which are there to make sure the fields have data,
-- and if it doesn't replaces them with NULL

-- the data source has 0s in no data fields instead of NULL

-- they are indiviually blocked to check and double check the data
-- those are later rewritten at the end and made into a view


SELECT
CountriesAndRegions,
Case 
when OOSR_Pre0Primary_Age_Male = 0 and OOSR_Pre0Primary_Age_Female = 0 then NULL
else OOSR_Pre0Primary_Age_Male END as OOSR_Pre0Primary_Age_Male,
CASE
when OOSR_Pre0Primary_Age_Male = 0 and OOSR_Pre0Primary_Age_Female = 0 then NULL
else OOSR_Pre0Primary_Age_Female End as OOSR_Pre0Primary_Age_Female
FROM
    world_education_data.global_education 
--@block

SELECT
CountriesAndRegions,
Case 
when OOSR_Primary_Age_Male = 0 and OOSR_Primary_Age_Female = 0 then NULL
else OOSR_Primary_Age_Male END as OOSR_Primary_Age_Male,
CASE
when OOSR_Primary_Age_Male = 0 and OOSR_Primary_Age_Female = 0 then NULL
else OOSR_Primary_Age_Female End as OOSR_Primary_Age_Female
FROM
    world_education_data.global_education 

--@block

SELECT
CountriesAndRegions,
Case 
when OOSR_Lower_Secondary_Age_Male = 0 and OOSR_Lower_Secondary_Age_Female = 0 then NULL
else OOSR_Lower_Secondary_Age_Male END as OOSR_Lower_Secondary_Age_Male,
CASE
when OOSR_Lower_Secondary_Age_Male = 0 and OOSR_Lower_Secondary_Age_Male = 0 then NULL
else OOSR_Lower_Secondary_Age_Female End as OOSR_Lower_Secondary_Age_Female
FROM
    world_education_data.global_education 

--@block


SELECT
CountriesAndRegions,
Case 
when OOSR_Upper_Secondary_Age_Male = 0 and OOSR_Upper_Secondary_Age_Female = 0 then NULL
else OOSR_Upper_Secondary_Age_Male END as OOSR_Upper_Secondary_Age_Male,
CASE
when OOSR_Upper_Secondary_Age_Male = 0 and OOSR_Upper_Secondary_Age_Male = 0 then NULL
else OOSR_Upper_Secondary_Age_Female End as OOSR_Upper_Secondary_Age_Female
FROM
    world_education_data.global_education 
--@block

SELECT
CountriesAndRegions,
Case 
when Completion_Rate_Primary_Male = 0 and Completion_Rate_Primary_Female = 0 then NULL
else Completion_Rate_Primary_Male END as Completion_Rate_Primary_Male,
CASE
when Completion_Rate_Primary_Male = 0 and Completion_Rate_Primary_Female = 0 then NULL
else Completion_Rate_Primary_Female End as Completion_Rate_Primary_Female
FROM
    world_education_data.global_education 


--@block

SELECT
CountriesAndRegions,
Case 
when Completion_Rate_Lower_Secondary_Male = 0 and Completion_Rate_Lower_Secondary_Female = 0 then NULL
else Completion_Rate_Lower_Secondary_Male END as Completion_Rate_Lower_Secondary_Male,
CASE
when Completion_Rate_Lower_Secondary_Male = 0 and Completion_Rate_Lower_Secondary_Female = 0 then NULL
else Completion_Rate_Lower_Secondary_Female End as Completion_Rate_Lower_Secondary_Female
FROM
    world_education_data.global_education 

--@block

SELECT
CountriesAndRegions,
Case 
when Completion_Rate_Upper_Secondary_Male = 0 and Completion_Rate_Upper_Secondary_Female = 0 then NULL
else Completion_Rate_Upper_Secondary_Male END as Completion_Rate_Upper_Secondary_Male,
CASE
when Completion_Rate_Upper_Secondary_Male = 0 and Completion_Rate_Upper_Secondary_Female = 0 then NULL
else Completion_Rate_Upper_Secondary_Female End as Completion_Rate_Upper_Secondary_Female
FROM
    world_education_data.global_education 

--@block
-- birth rate is birth/1000
Select
CountriesAndRegions,
case when Birth_Rate = 0 then NULL
ELSE Birth_Rate End as Birth_Rate
from global_education

--@block
-- countries with 0% unemployment rate have have no data

select
CountriesAndRegions,
case WHEN Unemployment_Rate = 0 THEN NULL
ELSE Unemployment_Rate END as Unemployment_Rate
from global_education


--@block
-- calculate the non-completion rate ratio between males and females
-- a value of 0 means the completion rate is 100% for both males and females
-- a value of 1 means means the non-completion rate is equal between males and females
-- a value of less than 1 means that the non-completion rate for males is higher than females

-- there are countries that contain 0 0 0 0 in its fields (which means no data),
-- those will be delt with in PowerQuery, dealing with them using SQL would require 4 case statements

SELECT 
CountriesAndRegions,
COALESCE((100 - Completion_Rate_Primary_Male) / NULLIF((100 - Completion_Rate_Primary_Female), 0), (100 - Completion_Rate_Primary_Male)) AS Primary_NonCompletion_rate_discrepancy,
COALESCE((100 - Completion_Rate_Lower_Secondary_Male) / NULLIF((100 - Completion_Rate_Lower_Secondary_Female), 0),(100 - Completion_Rate_Lower_Secondary_Male)) AS LowerSecondary_NonCompletion_rate_discrepancy,
COALESCE((100 - Completion_Rate_Upper_Secondary_Male) / NULLIF((100 - Completion_Rate_Upper_Secondary_Female), 0),(100 - Completion_Rate_Upper_Secondary_Male)) AS UpperSecondary_NonCompletion_rate_discrepancy
From global_education

-- where CountriesAndRegions = "Austria"

--@block
-- calculate the out of school ration between males and females
-- a value of 0 means the oosr rate for that country is 0% for both males and females
-- a value of 1 means there is an equal number of oosr male and female students
-- a value less than 1 means there are more oosr female students than male

-- there are countries that contain 0 0 0 0 in its fields (which means no data),
-- those will be delt with in PowerQuery, dealing with them using SQL would require 4 case statements

Select
CountriesAndRegions,
COALESCE(OOSR_Pre0Primary_Age_Male / NULLIF(OOSR_Pre0Primary_Age_Female, 0),OOSR_Pre0Primary_Age_Male) AS OOSR_Pre0Primary_discrepancy,
COALESCE(OOSR_Primary_Age_Male / NULLIF(OOSR_Primary_Age_Female, 0),OOSR_Primary_Age_Male) AS OOSR_Primary_discrepancy,
COALESCE(OOSR_Lower_Secondary_Age_Male / NULLIF(OOSR_Lower_Secondary_Age_Female, 0),OOSR_Lower_Secondary_Age_Male) AS OOSR_Lower_Secondary_discrepancy,
COALESCE(OOSR_Upper_Secondary_Age_Male / NULLIF(OOSR_Upper_Secondary_Age_Female, 0),OOSR_Upper_Secondary_Age_Male) AS OOSR_Upper_Secondary_discrepancy
from global_education

--@block
-- i've decided not to include this considering most countries do not have data
-- (they have a 0 literacy rate for both males and females)

-- collumns were not dropped incase i need them later

-- select 
-- CountriesAndRegions,
-- Case when Youth_15_24_Literacy_Rate_Male = 0 THEN NULL
-- ELSE (100 - Youth_15_24_Literacy_Rate_Male) / (100 - Youth_15_24_Literacy_Rate_Female)
-- END as LiteracyRateRatio
-- From global_education


--@block

Create View OutOfSchoolRates As(
Select
CountriesAndRegions,
Case 
when OOSR_Pre0Primary_Age_Male = 0 and OOSR_Pre0Primary_Age_Female = 0 then NULL
else OOSR_Pre0Primary_Age_Male END as OOSR_Pre0Primary_Age_Male,
CASE
when OOSR_Pre0Primary_Age_Male = 0 and OOSR_Pre0Primary_Age_Female = 0 then NULL
else OOSR_Pre0Primary_Age_Female End as OOSR_Pre0Primary_Age_Female,
Case 
when OOSR_Primary_Age_Male = 0 and OOSR_Primary_Age_Female = 0 then NULL
else OOSR_Primary_Age_Male END as OOSR_Primary_Age_Male,
CASE
when OOSR_Primary_Age_Male = 0 and OOSR_Primary_Age_Female = 0 then NULL
else OOSR_Primary_Age_Female End as OOSR_Primary_Age_Female,
Case 
when OOSR_Lower_Secondary_Age_Male = 0 and OOSR_Lower_Secondary_Age_Female = 0 then NULL
else OOSR_Lower_Secondary_Age_Male END as OOSR_Lower_Secondary_Age_Male,
CASE
when OOSR_Lower_Secondary_Age_Male = 0 and OOSR_Lower_Secondary_Age_Male = 0 then NULL
else OOSR_Lower_Secondary_Age_Female End as OOSR_Lower_Secondary_Age_Female,
Case 
when OOSR_Upper_Secondary_Age_Male = 0 and OOSR_Upper_Secondary_Age_Female = 0 then NULL
else OOSR_Upper_Secondary_Age_Male END as OOSR_Upper_Secondary_Age_Male,
CASE
when OOSR_Upper_Secondary_Age_Male = 0 and OOSR_Upper_Secondary_Age_Male = 0 then NULL
else OOSR_Upper_Secondary_Age_Female End as OOSR_Upper_Secondary_Age_Female
From world_education_data.global_education
)

--@block

Create View OutOfSchoolRatesRatios As (
Select
CountriesAndRegions,
COALESCE(OOSR_Pre0Primary_Age_Male / NULLIF(OOSR_Pre0Primary_Age_Female, 0),OOSR_Pre0Primary_Age_Male) AS OOSR_Pre0Primary_discrepancy,
COALESCE(OOSR_Primary_Age_Male / NULLIF(OOSR_Primary_Age_Female, 0),OOSR_Primary_Age_Male) AS OOSR_Primary_discrepancy,
COALESCE(OOSR_Lower_Secondary_Age_Male / NULLIF(OOSR_Lower_Secondary_Age_Female, 0),OOSR_Lower_Secondary_Age_Male) AS OOSR_Lower_Secondary_discrepancy,
COALESCE(OOSR_Upper_Secondary_Age_Male / NULLIF(OOSR_Upper_Secondary_Age_Female, 0),OOSR_Upper_Secondary_Age_Male) AS OOSR_Upper_Secondary_discrepancy
from global_education
)


--@block 

Create View CompletionRates As( 
Select
CountriesAndRegions,
Case 
when Completion_Rate_Primary_Male = 0 and Completion_Rate_Primary_Female = 0 then NULL
else Completion_Rate_Primary_Male END as Completion_Rate_Primary_Male,
CASE
when Completion_Rate_Primary_Male = 0 and Completion_Rate_Primary_Female = 0 then NULL
else Completion_Rate_Primary_Female End as Completion_Rate_Primary_Female,
Case 
when Completion_Rate_Lower_Secondary_Male = 0 and Completion_Rate_Lower_Secondary_Female = 0 then NULL
else Completion_Rate_Lower_Secondary_Male END as Completion_Rate_Lower_Secondary_Male,
CASE
when Completion_Rate_Lower_Secondary_Male = 0 and Completion_Rate_Lower_Secondary_Female = 0 then NULL
else Completion_Rate_Lower_Secondary_Female End as Completion_Rate_Lower_Secondary_Female,
Case 
when Completion_Rate_Upper_Secondary_Male = 0 and Completion_Rate_Upper_Secondary_Female = 0 then NULL
else Completion_Rate_Upper_Secondary_Male END as Completion_Rate_Upper_Secondary_Male,
CASE
when Completion_Rate_Upper_Secondary_Male = 0 and Completion_Rate_Upper_Secondary_Female = 0 then NULL
else Completion_Rate_Upper_Secondary_Female End as Completion_Rate_Upper_Secondary_Female
FROM world_education_data.global_education
)

--@block

Create View CompletionRatesRatios As(
SELECT 
CountriesAndRegions,
COALESCE((100 - Completion_Rate_Primary_Male) / NULLIF((100 - Completion_Rate_Primary_Female), 0), (100 - Completion_Rate_Primary_Male)) AS Primary_NonCompletion_rate_discrepancy,
COALESCE((100 - Completion_Rate_Lower_Secondary_Male) / NULLIF((100 - Completion_Rate_Lower_Secondary_Female), 0),(100 - Completion_Rate_Lower_Secondary_Male)) AS LowerSecondary_NonCompletion_rate_discrepancy,
COALESCE((100 - Completion_Rate_Upper_Secondary_Male) / NULLIF((100 - Completion_Rate_Upper_Secondary_Female), 0),(100 - Completion_Rate_Upper_Secondary_Male)) AS UpperSecondary_NonCompletion_rate_discrepancy
From global_education
)

--@block

Create View UnemploymentAndBirthrate AS (
    Select
    CountriesAndRegions,
case WHEN Unemployment_Rate = 0 THEN NULL
ELSE Unemployment_Rate END as Unemployment_Rate,
case when Birth_Rate = 0 then NULL
ELSE Birth_Rate End as Birth_Rate
from global_education
)

--@block
-- the duplicate CountriesAndRegions collumns will be removed in power query

Create view All_Data As(
Select * from
 CompletionRates
 join CompletionRatesRatios on CompletionRatesRatios.CountriesAndRegions = CompletionRates.CountriesAndRegions
 join OutOfSchoolRates on OutOfSchoolRates.CountriesAndRegions = CompletionRates.CountriesAndRegions
 join OutOfSchoolRatesRatios on OutOfSchoolRatesRatios.CountriesAndRegions = CompletionRates.CountriesAndRegions
 join UnemploymentAndBirthrate on UnemploymentAndBirthrate.CountriesAndRegions = CompletionRates.CountriesAndRegions
)
















