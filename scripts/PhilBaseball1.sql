/* This is the beginning of a 
wonderful baseball journey
best of luck on this endeavor
keep all queries on 1 script */
-- Test 1
select *
from people

-- Q1. What range of years for baseball games played does the provided database cover?
select min(span_first),
max(span_last)
from homegames;
-- This works, but look into getting just the years here with a cast()
-- Goes from 1871-05-04 to 2016-10-02

/* Q2. Find the name and height of the shortest player in the database. 
How many games did he play in? What is the name of the team for which he played? */
select p.playerid,
p.namefirst,
p.namelast,
p.height,
a.teamid,
a.yearid
from people as p
/* inner join managershalf as mh
on p.playerid = mh.playerid
inner join teams as t
on mh.teamid = t.teamid */
inner join appearances as a
on p.playerid = a.playerid
order by height asc;
-- Eddie Gaedel, who was "43" tall? Played for SLA in 1951
-- Any way to also tie in the teams table so we can get the team name??

/* Q3. Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names as well as the 
total salary they earned in the major leagues. Sort this list in descending 
order by the total salary earned. Which Vanderbilt player earned the most 
money in the majors? */

select cp.playerid,
p.namefirst,
p.namelast,
sum(s2.salary)
from collegeplaying as cp
inner join schools as s1
on cp.schoolid = s1.schoolid
inner join people as p
on cp.playerid = p.playerid
inner join salaries as s2
on p.playerid = s2.playerid
where s1.schoolname ilike '%vander%'
group by cp.playerid, p.namefirst, p.namelast
order by sum(s2.salary) desc
-- David Price earned $245,553,888 playing baseball??? That seems insane but good for him

/* Q4. Using the fielding table, group players into three groups based 
on their position: label players with position OF as "Outfield", those 
with position "SS", "1B", "2B", and "3B" as "Infield", and those with 
position "P" or "C" as "Battery". Determine the number of putouts made 
by each of these three groups in 2016. */

select count(playerid) as Total_players,
sum(po) as Total_putouts,
sum(po)/count(playerid) as Putouts_per_player,
-- We are looking at the Pos column, which says player position
	case when pos = 'OF' then 'Outfield'
		when pos = 'SS' or pos = '1B' or pos = '2B' or pos = '3B' then 'Infield'
		when pos = 'P' or pos = 'C' then 'Battery' 
		else 'Other' end as position
		-- Nice, no others when this query is run!
from fielding
where yearid = 2016
group by position
order by total_putouts desc
-- I hope I got this one right! 58934 Infield PO's, 41424 Battery PO's, 29560 Outfield PO's
-- Outfield players almost as efficient as infield players for achieving PO's, whatever those are.
-- window function where you partition by????

/* Q5. Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. Do the same for home runs 
per game. Do you see any trends? */

select round(avg(hr),1) as Average_Homeruns,
round(avg(so),1) as Average_Strikeouts,
concat(left(cast(yearid as varchar(4)),3), '0s') as decade
from teams
where yearid >= 1920
group by decade
order by avg(so) desc;

-- Bonds, Sosa, and McGuire really shaped the homerun era, huh? 2000's was the time to do steroids for sure
-- 2010's was the time they figured out using different pitchers all the time is pretty effective

/* Q6. Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts which 
are successful. (A stolen base attempt results either in a stolen base or 
being caught stealing.) Consider only players who attempted at least 20 stolen bases. */

select p.namefirst,
p.namelast,
sum(b.sb + b.cs) as Stealing_attempts,
round((sum(b.sb) / (sum(b.sb) + sum(b.cs)) * 100),1) AS stealing_success
-- This doesn't really work still
from people as p
inner join batting as b
on b.playerid = p.playerid
where yearid = 2016
and b.sb is not null
and b.cs is not null
group by p.playerid, p.namefirst, p.namelast
having sum(sb + cs) >=20
order by stealing_success desc
-- Jonthan Villar has the most attempts! But the formula shows Jose Altuve as the best percentage?
-- This code stull looks bad and it's wrong i think.


/* Q7. From 1970 – 2016, what is the largest number of wins for a team 
that did not win the world series? What is the smallest number of wins 
for a team that did win the world series? Doing this will probably result 
in an unusually small number of wins for a world series champion – 
determine why this is the case. Then redo your query, excluding the problem 
year. How often from 1970 – 2016 was it the case that a team with the most 
wins also won the world series? What percentage of the time? */

select name,
yearid,
max(w)as most_wins
from teams
where yearid between 1970 and 2016
and WSWin = 'N'
group by name, yearid
order by most_wins desc
-- Most wins for a team that did not win the world series: 116 Wins by Seattle Mariners in 2001
select name,
yearid,
min(w)as least_wins
from teams
where yearid between 1970 and 2016
and WSWin = 'Y'
group by name, yearid
order by least_wins asc
-- Least wins for a team that did win the world series: 63 wins by the LA Dodgers in 1981 
-- But that's too low, lets redo that
select sum(g) as total_games,
yearid
from teams
where yearid between 1970 and 2016
group by yearid 
order by sum(g) asc
-- Looks like 1981 was a low year for games i suppose, let's try that other query again.
select name,
yearid,
min(w)as least_wins
from teams
where yearid between 1970 and 2016
and yearid <> 1981
and WSWin = 'Y'
group by name, yearid
order by least_wins asc
-- Least wins for a team that did win the world series: 83 wins by the St. Louis Cardinals in 2006

with winner as (
select max(w) as winnerwins,
yearid
from teams
where wswin = 'Y'
group by yearid),
loser as (
select max(w) as loserwins,
yearid
from teams
where wswin = 'N'
group by yearid)
select
round(avg(case when winnerwins >= loserwins then 1
		else 0 end)*100,1) as winpct
from winner
inner join loser
on winner.yearid = loser.yearid
-- The team with the most wins wins 43.6% of the time
-- Omg wow if this actually is true i think i did it with a CTE!!!! Wow!!! I'll need to keep looking though
-- Ok looks like abigail got this one with like ~20% using 
-- https://stackoverflow.com/questions/7745609/sql-select-only-rows-with-max-value-on-a-column


/* Q8. Using the attendance figures from the homegames table, find the teams 
and parks which had the top 5 average attendance per game in 2016 (where average 
attendance is defined as total attendance divided by number of games). 
Only consider parks where there were at least 10 games played. Report the park name, 
team name, and average attendance. Repeat for the lowest 5 average attendance. */

select team,
subquery.park,
average_attendance
from 
	(select team,
			park,
			round(avg(attendance/games),0) as average_attendance
	 		from homegames
			where year=2016
			group by team, park) as subquery
inner join parks as p
on subquery.park = p.park
order by average_attendance desc
limit 5;
/*
SELECT 
	hg.year,
	hg.team,
	hg.park,
	hg.games,
	hg.attendance,
	hg.attendance/hg.games AS avg_attendance
FROM homegames AS hg
WHERE hg.year = 2016
	AND hg.games > 10
GROUP BY 
	hg.year,
	hg.team,
	hg.park,
	hg.games,
	hg.attendance
ORDER BY 
	avg_attendance DESC;
*/
-- Above is katie's code. Look at it to fix yours
-- The LA Dodgers had the highest 2016 average attendance with 45719 per game. Then SLN, TOR, SFN, and CHN.
-- This needs to be redone so you can account for 10 games in each park. Go back and think how Excel would do it.
with parks as (
select park
from homegames
having count(park)>=10)
select parks.park,
avg(attendance) as avg_att
from homegames as h
inner join parks
on parks.park = h.park
group by parks.park

/* Q9. Which managers have won the TSN Manager of the Year award in both the National 
League (NL) and the American League (AL)? Give their full name and the teams that they 
were managing when they won the award. */

with NL as (
select *
from awardsmanagers
where lgid = 'NL'),
AL as (
select *
from awardsmanagers
where lgid = 'AL')
select NL.playerid,
p.namefirst,
p.namelast,
NL.lgid,
AL.lgid,
NL.yearid,
m.teamid
from NL
inner join AL
on NL.playerid = AL.playerid
left join people as p
on NL.playerid = p.playerid
left join managers as m
on p.playerid = m.playerid and NL.yearid = m.yearid
where NL.awardid ilike '%TSN Manager%'
and AL.awardid ilike '%TSN Manager%'

-- Only one I can find with the above code is Davey Johnson & Jim Leyland, but i have to look through the code to find it.
-- Need to revise the above code and give the teams they managed, as well as only pull the ones who have one of each!!!

/* Q10. Find all players who hit their career highest number of home runs in 2016. 
Consider only players who have played in the league for at least 10 years, and who 
hit at least one home run in 2016. Report the players' first and last names and the 
number of home runs they hit in 2016. */

with homers as(
select p.playerid,
max(b.hr) over(partition by p.playerid) as maxhomers
from people as p
left join batting as b
on p.playerid = b.playerid)
select homers.maxhomers,
max(b.hr) as maxhomerstwentysixteen
from batting as b
inner join homers
on b.playerid = homers.playerid
where yearid = 2016
group by b.playerid


-- yeah ok i get it this shouldnt work omg nevermind it does work it just takes forever????
-- When i do this it only outputs one player, trumbma01. Let's keep this in mind and remake the code!
-- Ok I commented off the first yearid thing and it takes way way way longer omg

/* Q11. Is there any correlation between number of wins and team salary? Use data 
from 2000 and later to answer this question. As you do this analysis, keep in mind 
that salaries across the whole league tend to increase together, so you may want to 
look on a year-by-year basis. */

/* Q12. In this question, you will explore the connection between number of wins and attendance.

a. Does there appear to be any correlation between attendance at home games and number of wins?

b. Do teams that win the world series see a boost in attendance the following year? 
What about teams that made the playoffs? Making the playoffs means either being a 
division winner or a wild card winner. */

/* Q13. It is thought that since left-handed pitchers are more rare, causing 
batters to face them less often, that they are more effective. Investigate 
this claim and present evidence to either support or dispute this claim. 
First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 
Are left-handed pitchers more likely to win the Cy Young Award? Are they more 
likely to make it into the hall of fame? */

