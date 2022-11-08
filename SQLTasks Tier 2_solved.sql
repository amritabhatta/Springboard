/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
 SELECT name FROM  Facilities WHERE membercost!=0

/* Q2: How many facilities do not charge a fee to members? */
SELECT  COUNT (DISTINCT name) FROM  Facilities WHERE membercost=0 
4
/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT  * FROM  Facilities WHERE membercost !=0 AND membercost <0.2*monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *  FROM  Facilities WHERE facid= 1 OR facid= 5

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,

CASE

WHEN monthlymaintenance >100 THEN 'expensive'

ELSE 'Cheap'

END as 'Facilitytype'

FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT surname, firstname FROM Members ORDER BY joindate DESC LIMIT 1;

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT Bookings.memid, Bookings.facid, Members.firstname, Members.surname, Facilities.name
FROM Bookings
LEFT JOIN Members
ON Bookings.memid = Members.memid
LEFT JOIN Facilities
ON Bookings.facid=Facilities.facid

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
Step 1:
CREATE TABLE Bookings_new AS
SELECT *, strftime('%Y/%m/%d', starttime) AS startdates FROM Bookings

Step 2:
SELECT Bookings_new.bookid, Bookings_new.facid, Bookings_new.memid, Members.firstname, Members.surname, Facilities.name, Facilities.membercost, Facilities.guestcost
FROM Bookings_new 
LEFT JOIN Members
ON Bookings_new.memid= Members.memid
LEFT JOIN Facilities
ON Bookings_new.facid= Facilities.facid
WHERE Bookings_new.startdates= '2012/09/14'
AND Facilities.guestcost>30 OR Facilities.membercost>30
ORDER BY Facilities.guestcost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
Step 1:
CREATE TABLE Bookings_new AS
SELECT *, strftime('%Y/%m/%d', starttime) AS startdates FROM Bookings



/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

STEP 1:
CREATE TABLE nonguest_counts_revenue AS 
SELECT COUNT(memid) AS guests_count, facid
FROM Bookings
WHERE memid !=0
GROUP BY facid;


STEP 2:
CREATE TABLE joined_counts AS
SELECT 
 *
  FROM guest_counts_revenue
   JOIN nonguest_counts_revenue_updated
    USING (facid);

STEP 3:
CREATE TABLE facilities_updated AS 
SELECT 
 *
  FROM joined_counts
   JOIN Facilities
    USING (facid);

STEP 4:
CREATE TABLE total_revenue_calculated AS
SELECT facid, name, monthlymaintenance, ((guests_count*guestcost ) + (nonguests_count*membercost)- monthlymaintenance) AS total_revenue
FROM facilities_updated;

STEP 5:
SELECT * FROM total_revenue_calculated WHERE total_revenue <1000
ORDER BY total_revenue


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */SELECT recommended.recommendedby, recommended.firstname, recommended.surname, Members.firstname AS recomended_firstname, Members.surname AS recommended_surname
STEP 1: 
CREATE TABLE recommended AS SELECT memid, recommendedby, surname, firstname WHERE recommendedby != ''

STEP 2:
SELECT recommended.recommendedby, recommended.firstname, recommended.surname, Members.firstname AS recomended_firstname, Members.surname AS recommended_surname
FROM recommended 
LEFT JOIN Members
ON recommended.recommendedby= Members.memid
ORDER BY recomended_firstname ASC;

/* Q12: Find the facilities with their usage by member, but not guests */
STEP 1:
CREATE TABLE usage_new AS 
SELECT facid, memid, SUM(slots) AS total_usage FROM Bookings WHERE memid !=0 
GROUP BY memid,facid


STEP2:
SELECT usage_new.facid, usage_new.memid, usage_new.total_usage, Facilities.name
FROM usage_new 
LEFT JOIN Facilities
ON usage_new.facid= Facilities.facid

/* Q13: Find the facilities usage by month, but not guests */

step 1:
CREATE TABLE new AS  SELECT facid, slots, strftime('%m', starttime) AS monthly FROM Bookings WHERE memid!=0
GROUP BY facid, monthly, slots
ORDER BY facid

Step2:
CREATE TABLE total_usage_monthly_facilities AS 
SELECT facid, monthly, SUM (slots) AS total_usage FROM new 
GROUP BY facid, monthly;

Step3:
SELECT total_usage_monthly_facilities.facid, total_usage_monthly_facilities.monthly, total_usage_monthly_facilities.total_usage, Facilities.name
FROM total_usage_monthly_facilities 
LEFT JOIN Facilities
ON total_usage_monthly_facilities.facid= Facilities.facid






SELECT facid, memid, SUM(slots) AS total_usage FROM Bookings WHERE memid !=0 
GROUP BY facid, slots
ORDER BY facid

