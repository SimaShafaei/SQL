/*
								CECS 536, Fall 2020 Take Home 2
										Sima Shafaei
SCORE: 97. Excellent job!
*/
 /********************************************************************************************************************************
 (75 points) Use the World database and the tables city, country and countrylanguage for this part of the exam.
*********************************************************************************************************************************/
 /*1. (+ Answer) Find out the minimum, maximum, range (maximum minus minimum) and mean (average) of attribute population in table country. 
 Try to do it in a single query! */
select min(Population) as minPopulation, 
       max(Population) as maxPopulation, 
       sum(Population)/count(Population) as mean, /* why not use avg()? */
       max(Population)-min(Population) as rangePopulation
from country;
/*
answer:
maxPopulation  minPopulation   mean             rangePopulation
1277558000	   0	           25434098.1172	1277558000
*/
/*==============================================================================================================================*/
/*2. (+ Answer) Find out whether there are any missing values (and if so, how many) in attributes IndepYear and 
LifeExpectancy in country*/
select sum(CASE WHEN IndepYear is NULL THEN 1 ELSE 0 END) as IndepYearMissingNum, 
       sum(CASE WHEN LifeExpectancy is NULL THEN 1 ELSE 0 END) as LifeExpectancyMissingNum 
from country;

/*answer:
IndepYearMissingNum   LifeExpectancyMissingNum
47                    17                        */ 
/*==============================================================================================================================*/
/*3. (+ Answer) List the top (largest) 5 cities by population*/
select Name,Population
from city
order by Population desc
limit 5; 
/*answer:
Name            Population
Mumbai(Bombay)	10500000
Seoul	        9981619
SÃ£o Paulo	    9968485
Shanghai	    9696300
Jakarta	        9604900*/
/*==============================================================================================================================*/
/*4. (+ Answer) Find out how many countries are monarchies and how many are republics.
To evaluate the dataset I first run the following SQL statement:
select GovernmentForm from country where GovernmentForm LIKE '%Monarchy%' 
group by GovernmentForm; 
and get this list as result: 
Constitutional Monarchy
Constitutional Monarchy, Federation
Monarchy (Emirate)
Monarchy (Sultanate)
Monarchy
Constitutional Monarchy (Emirate)
Parlementary Monarchy


 All of them can be define as monarchy countries. the following command run for republic too:
select GovernmentForm from country where GovernmentForm LIKE '%Republic%' 
group by GovernmentForm; 
and this list obtained:

Republic
Federal Republic
People'sRepublic
Socialistic Republic
Islamic Republic

Which all of them can be considered as republic type countries. therefore we can use the following statement to count monarchy and republic countries:
*/

select sum(CASE WHEN GovernmentForm LIKE '%Monarchy%' THEN 1 ELSE 0 END) as MonarchyNum, 
sum(CASE WHEN GovernmentForm LIKE '%Republic%' THEN 1 ELSE 0 END) as RepublicNum 
from country;
/*answer:
MonarchyNum    RepublicNum
43	           143
*/
/*==============================================================================================================================*/
/*5. Find out, for each language, the number of countries where that language is spoken.*/
select Language, count(*)
from countrylanguage
group by Language;
/*==============================================================================================================================*/
/*6. Find the countries where there is more than one official language.*/
select Name,LangNum
from country,
     (select CountryCode,count(*) as LangNum
			from countrylanguage
			where IsOfficial="T"
			group by CountryCode) as T1
where CountryCode=Code and LangNum>1;
/*==============================================================================================================================*/
/*7. (+ Answer) Find out the total population of all Spanish-speaking countries (defined as countries where Spanish is spoken)*/
select sum(Population)
from (select Population 
      from country,countrylanguage 
      where Language="Spanish" and Code=CountryCode) as SpanishSpoken;
/*answer:
sum(Population)
750296800
*/
/*==============================================================================================================================*/
/*8. (+ Answer) Find the average GNP for countries that gained independence after 1970 and for all countries. How do they compare? */
select avg(GNP), avg(`GNPAfter70`)
from country,
     (select GNP as GNPAfter70 from country where IndepYear>1970) as T1;
/*anwer:
avg(GNP)         avg(`GNPAfter70`)
122823.882427	 12446.253704
/* this query works by sheer luck. You are using two tables (country, T1) without a join,
which means Cartesian product is taken -all pairs of rows possible are created. Each country
appears multiple times in the result. Fortunately for you, the average of a set and a multiset
-a set with repeated values- is the same!! */
/* The result shows that countries that gained independent after 1970 have significantly less GNP than other countries.
 */
 /*==============================================================================================================================*/
 /*9. Find, on each country, how many people speaks the official language(s). Note: table countrylanguage gives you a percentage; 
 you are asked about the number of people. */
 select Name,round((sum(Percentage))*Population/100) as officialSpoken
from country,countrylanguage
where Code=CountryCode and IsOfficial="T" 
group by CountryCode;
/* this query gives an error. You need to have the attributes in SELECT in GROUP BY too -3 */
/* fortunately for you, each country (countryCode) has only one Name */

/********************************************************************************************************************************
(25 points) Execute the following instructions, in the order given. Show the SQL command used to execute the instruction.
*********************************************************************************************************************************/
Drop Schema Experiment;

/*1. Create a schema called Experiment.*/
Create Schema Experiment;
/*==============================================================================================================================*/
/*2. Inside this schema, create a table called Test. This table should have four columns, Id (of type INTEGER) Name (of type CHAR(10))
and Height and Weight of type DOUBLE.*/
use Experiment;
Create Table Test(
Id INT PRIMARY KEY,
Name CHAR(10) UNIQUE,
Height DOUBLE,
Weight DOUBLE
); 

/*==============================================================================================================================*/
/*3. Insert into this table the following rows: (1, ‘‘Jones’’, 5.8, 178), (2, ‘‘Smith’’, 5.7, 188), (3, ‘‘Lewis’’, 5.9, 204), 
(4, ‘‘Ford’’, 6.1, 210)*/
Insert into Test 
values (1, "Jones", 5.8, 178), 
       (2, "Smith", 5.7, 188), 
       (3, "Lewis", 5.9, 204), 
       (4, "Ford", 6.1, 210);
/*==============================================================================================================================*/
/*4. Change Smith’s weight to 186.*/
update test set weight=186
where id=2;
/*or*/
update test set weight=186
where Name="Smith";
/*==============================================================================================================================*/
/*5. Change Lewis’ height to 5.10*/
update test set height=5.10
where Name="Lewis";
/*or*/

update test set height=5.10
where id=3;

/*==============================================================================================================================*/
/*6. Delete the information about Jones+.*/
delete from test
where Name="Jones";

/*==============================================================================================================================*/
/*7. (+ Answer) List all the table’s contents.*/
SELECT * FROM experiment.test; 
/*answer
Id  Name    Height   Weight
2	Smith	5.7	     186
3	Lewis	5.1	     204
4	Ford	6.1	     210
*/
