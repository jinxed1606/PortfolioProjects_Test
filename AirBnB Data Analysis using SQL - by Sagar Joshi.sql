/*
AirBnB Data Analysis Project by Avery Smith
*/
---------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM [AirBnB Project - AverySmith].dbo.newlistings 

SELECT *
FROM [AirBnB Project - AverySmith].dbo.newcalendar

SELECT *
FROM [AirBnB Project - AverySmith].dbo.reviews

---------------------------------------------------------------------------------------------------------------------------------
-- Converting price string to numeric price for calculations
---------------------------------------------------------------------------------------------------------------------------------

--SELECT price, CAST(REPLACE(price, '$', '') AS numeric) AS newprice
--FROM [AirBnB Project - AverySmith].dbo.listings 

SELECT *, price, CAST(REPLACE(REPLACE(PARSENAME(price, 2), '$', ''), ',', '') AS int) AS newprice
FROM [AirBnB Project - AverySmith].dbo.listings

---------------------------------------------------------------------------------------------------------------------------------
-- Top 20 most successful listings on their revenue
---------------------------------------------------------------------------------------------------------------------------------

--SELECT id, listing_url, name, (30 - availability_30) AS booked_30,
--	CAST(REPLACE(PARSENAME(price, 2), '$', '') AS int) AS price_clean,
--	CAST(REPLACE(PARSENAME(price, 2), '$', '') AS int)*(30 - availability_30)/beds AS revenue
--FROM [AirBnB Project - AverySmith].dbo.listings


SELECT TOP 20 id, listing_url, name, (30 - availability_30) AS booked_30,
	CAST(REPLACE(REPLACE(PARSENAME(price, 2), '$', ''), ',', '') AS int) AS price_clean,
	ROUND(CAST(REPLACE(REPLACE(PARSENAME(price, 2), '$', ''), ',', '') AS int)*(30 - availability_30)/beds, 2) AS revenue
FROM [AirBnB Project - AverySmith].dbo.listings
ORDER BY revenue DESC 


SELECT TOP 20 id, listing_url, name, (30 - availability_30) AS booked_30,
	price, 
	ROUND(price*(30 - availability_30)/beds, 2) AS revenue
FROM [AirBnB Project - AverySmith].dbo.newlistings
ORDER BY revenue DESC 

---------------------------------------------------------------------------------------------------------------------------------
-- Top 20 listings with number of dirty reviews in comments
---------------------------------------------------------------------------------------------------------------------------------

--SELECT host_id, host_url, host_name, COUNT(*) AS num_dirty_reviews 
--FROM [AirBnB Project - AverySmith].dbo.reviews AS reviews
--INNER JOIN [AirBnB Project - AverySmith].dbo.newlistings AS list
--	ON list.id = reviews.listing_id
--WHERE reviews.comments LIKE '%dirty%'
--GROUP BY host_id, host_url, host_name
--ORDER BY num_dirty_reviews DESC


SELECT TOP 20 list.host_id, list.host_url, list.host_name, COUNT(*) AS num_dirty_reviews 
FROM [AirBnB Project - AverySmith].dbo.listings AS list
INNER JOIN [AirBnB Project - AverySmith].dbo.reviews AS reviews
	ON list.id = reviews.listing_id
WHERE reviews.comments LIKE '%dirty%'
GROUP BY host_id, host_url, host_name
ORDER BY num_dirty_reviews DESC

---------------------------------------------------------------------------------------------------------------------------------
