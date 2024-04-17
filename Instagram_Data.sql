SELECT *
FROM instagram_data

--To duplicate the table
SELECT *
INTO instagram_datas
FROM instagram_data

--To delete a column
ALTER TABLE instagram_data
DROP COLUMN location

--To create a new permanent column using two existing columns
ALTER TABLE instagram_datas
ADD Engagements as (comments + likes) PERSISTED;

--To create a new permanent column using two existing columns
ALTER TABLE instagram_data
ADD Engagements as (comments + likes) PERSISTED;

--to change the format of the date and time column to be readable
ALTER TABLE instagram_data
ADD Date_and_Time AS (CONVERT(VARCHAR(24), DATEADD(SECOND, created_at, '01-01-1970'), 120));

--To delete a column
ALTER TABLE instagram_data
DROP COLUMN created_at

--Analysis

--1. Top users by likes and comments
SELECT owner_username, MAX(likes) AS Most_Likes
FROM instagram_data
GROUP BY owner_username
ORDER BY Most_Likes DESC
--The user with the most likes is selenagomez.

--2. Maximum engagement by time of the day
SELECT*, 
		CASE
		WHEN Hours BETWEEN 0 AND 6 THEN 'Early Morning'
		WHEN Hours BETWEEN 6 AND 12 THEN 'Morning'
		WHEN Hours BETWEEN 12 AND 16 THEN 'Afternoon'
		WHEN Hours BETWEEN 16 AND 22 THEN 'Evening'
		WHEN Hours BETWEEN 22 AND 23 THEN 'Late Evening'
		ELSE 'Night' END AS Time_of_Day
FROM 
(SELECT DATEPART(Hour, Date_and_Time) AS Hours, MAX(Engagements) AS Max_Engagements
FROM instagram_data
GROUP BY Date_and_Time 
) AS SUB
--We get the most engagement  at 23:00

--3. calculate average number of engagements on IG per year
SELECT DATEPART(Year, Date_and_Time) AS Years, owner_username, AVG(Engagements) AS Average_Engagements
FROM instagram_data
GROUP BY Date_and_Time, owner_username
ORDER BY Average_Engagements DESC


--4. Find out if the length of the caption affects likes
SELECT*, 
		CASE
		WHEN Caption_Length BETWEEN 0 AND 200 THEN 'Short Caption'
		WHEN Caption_Length BETWEEN 200 AND 500 THEN 'Long Caption'
		WHEN Caption_Length > 500 THEN 'Very Long Caption'
		ELSE 'Extremely Long Caption' END AS Result
FROM 
(
SELECT LEN(caption) AS Caption_Length, likes
FROM instagram_data) AS Style
ORDER BY likes DESC
--The caption length has no effect on the number of likes and comments.

--5. Identify users with high follower-to-following ratios
SELECT CONCAT(1, ':', (followers/following)) AS Follower_to_Following_Ratio, owner_username
FROM instagram_data
WHERE followers > 0 AND following > 0 
ORDER BY Follower_to_Following_Ratio DESC
--The user with the highest follower to following ratio is madwhips_import by 1:99855

SELECT *
FROM instagram_data

--6. Most engagement by image URL domain
SELECT imageURL, MAX(Engagements) AS Max_Engagements
FROM instagram_data
GROUP BY imageURL
ORDER BY Max_Engagements DESC


--7. Relate user engagement to follower count
SELECT owner_username, Followers_Rate, SUM(Engagements) AS Sum_of_Engagements
FROM
(SELECT*, 
		CASE
		WHEN followers BETWEEN 0 AND 1000 THEN 'low rate of followers'
		WHEN followers BETWEEN 1000 AND 2000 THEN 'Medium rate of followers'
		WHEN followers > 2000 THEN 'High rate of followers'
		ELSE 'Very High Rate of Followers' END AS Followers_Rate
FROM instagram_data) AS Foll
GROUP BY owner_username, Followers_Rate
ORDER BY Sum_of_Engagements DESC
--The higher the followers, the more the engagement rate.

--8. Identify the posts that had a video check if it affects its engagement rate.
SELECT owner_username, is_video, multiple_images, Engagements
FROM instagram_data
WHERE is_video = 1
ORDER BY Engagements
--Posting a video does not affect the engagement rate as the engagement rate varies
