use lahmansbaseballdb;

#test query by joining people and batting tables
select b.*
from people p
inner join batting b 
	on p.playerid = b.playerID
where p.namelast = 'Jeter' and p.namefirst = 'Derek'
order by yearID ASC;

#what does the people table look like?
select *
from people;

#Who are the tallest baseball players?
select CONCAT(p.namefirst, " ", p.namelast) as PlayerName, 
	   weight, height/12 as height_ft
from people p
order by height_ft desc
limit 10;

#Who are the shortest baseball players?
select CONCAT(p.namefirst, " ", p.namelast) as PlayerName, 
	   weight, height/12 as height_ft
from people p
where height/12 is not null
order by height_ft 
limit 10;

#Write a SQL query to find the batters who led the major leagues in 
#Three True Outcome Percentage (BB + SO + HR)/(AB + BB + SF + SH + HBP) in 2000, 
#for players with at least 500 At Bats. Select playerID and TTO Percentage, 
#naming this column TTOPercentage. Be sure to include the appropriate ORDER BY clause.
select playerID, (BB + SO + HR)/(AB + BB + SF + SH + HBP) AS TTOPercentage
from batting
where yearID = 2000 AND AB >= 500
order BY (BB + SO + HR)/(AB + BB + SF + SH + HBP) DESC;

#Write a query to find the teams that led the major leagues in SO since 2000. 
#Group by teamID and yearID and order by most strikeouts.
select yearID, teamID, W, L, SO
from teams
where yearID > 2000
order by SO desc;

#Write a query to find players who are born in New York since 1980
select distinct p.birthYear, p.birthCity, 
			    CONCAT(p.namefirst, " ", p.namelast) as PlayerName
from people p
join batting b
	on p.playerID = b.playerID
where birthCity = 'New York' AND birthYear >= 1980;

#Since David Ortiz has become the only HOF inductee in 2022, pull up his career stats 
select CONCAT(p.namefirst, " ", p.namelast) as PlayerName, 
	   SUM(G) as TotalGames, 
       SUM(AB) as TotalAB,
       SUM(R) as TotalRuns,
       SUM(H) as TotalHits,
       SUM(2B) as TotalDoubles,
       SUM(3B) as TotalTriples,
       SUM(HR) as TotalHRs,
       SUM(RBI) as TotalRBIs,
       SUM(BB) as TotalWalks,
       SUM(SO) as TotalSOs,
       (SUM(H) + SUM(BB) + SUM(HBP))/(SUM(AB) + SUM(BB) + SUM(HBP) + SUM(SF)) as CareerOBP,
       (SUM(H+2B+2*3B+3*HR))/ SUM(AB) as CareerSlugging,
       (SUM(H) + SUM(BB) + SUM(HBP))/(SUM(AB) + SUM(BB) + SUM(HBP) + SUM(SF)) + (SUM(H+2B+2*3B+3*HR))/ SUM(AB) as CareerOPS
from people p
join batting b 
	on p.playerid = b.playerID
where p.namelast = 'Ortiz' and p.namefirst = 'David';

#What are Ortiz's career awards?
select CONCAT(p.namefirst, " ", p.namelast) as PlayerName, 
	   a.yearID, a.awardID
from people p
join batting b 
	on p.playerid = b.playerID
join awardsplayers a
	on a.playerid = b.playerID and a.yearID = b.yearID
where p.namelast = 'Ortiz' and p.namefirst = 'David'
order by a.yearID;

#pull up Ortiz's MVP votes throughout his career
select * , ROUND((pointsWon) / (pointsMax),3) as PercentOfVote
from awardsshareplayers
where awardID = 'MVP' and playerID = 'ortizda01'
order by yearID DESC, votesFirst;


#are there any other similar type players with comparable stats to Ortiz that are/arent in the HOF?
#since Ortiz was a notorious slugger, the query will be limited to key hitting statistics
#Ortiz's Career Stats: 
#TotalHits = 2472
#TotalHRs = 541
#TotalRBIs = 1768
#CareerOBP = 0.3795
#CareerSlugging = 0.5515
#CareerOPS = 0.9310
select b.playerID, CONCAT(p.namefirst, " ", p.namelast) as PlayerName,
	  SUM(H) as TotalHits,
      SUM(HR) as TotalHRs,
      SUM(RBI) as TotalRBIs,
	  (SUM(H) + SUM(BB) + SUM(HBP))/(SUM(AB) + SUM(BB) + SUM(HBP) + SUM(SF)) as CareerOBP,
	  (SUM(H+2B+2*3B+3*HR))/ SUM(b.AB) as CareerSlugging,
	  (SUM(H) + SUM(BB) + SUM(HBP))/(SUM(AB) + SUM(BB) + SUM(HBP) + SUM(SF)) + (SUM(H+2B+2*3B+3*HR))/ SUM(AB) as CareerOPS
from batting b
join people p
	on b.playerID = p.playerID
right join halloffame h
	on h.playerID = b.playerID 
where inducted = 'Y' 		#alter to 'Y' or 'N' to determine players in or not in HOF
group by playerID
having TotalHits >= 2472 
	and TotalHRs >= 541 
    and TotalRBIs >= 1768 
    and CareerOBP >=0.3795
    and CareerSlugging >= 0.5515
    and CareerOPS >= 0.9310;

#select * from halloffame;
       