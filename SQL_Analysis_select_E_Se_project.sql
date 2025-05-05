--1. Set with the largest number of parts each year and average number of parts

--the request below shows the sets with the largest number of parts for each year and average number of parts in sets in this year
--In 1950 there were several sets which consisted of only one part, so the request for selection of sets with the largest number of parts for each year shows 
--several rows for 1950, in later years there was only one set 

SELECT tab.set_year,
		tab.num_parts,
		tab.set_name,
		tab.avr_num_parts
FROM (
		SELECT set_year,
				set_name,
				num_parts,
				max (num_parts) OVER (PARTITION BY set_year) AS max_parts,
				round (avg (num_parts) OVER (PARTITION BY set_year ), 2) AS avr_num_parts
		FROM lego_sets) tab
WHERE tab.num_parts = tab.max_parts;

--1a one SET FOR EACH YEAR
--For illustration purposes we need only one set for 1950

SELECT tab.set_year AS "Year",
		tab.set_name AS "Largest Set",
		tab.num_parts AS "Number of Parts in Largest Set",
		tab.avr_num_parts AS "Average Number of Parts"
FROM (
		SELECT set_year,
				set_name,
				num_parts,
				ROW_NUMBER () OVER (PARTITION BY set_year ORDER BY num_parts DESC) AS row_num,
				round (avg (num_parts) OVER (PARTITION BY set_year ), 2) AS avr_num_parts
		FROM lego_sets) tab
WHERE tab.row_num = 1;

--2. top 3 colors IN EACH YEAR by number of parts of this color
SELECT TO_CHAR (tab2.set_year, '9999') AS "Year",
		tab2.color_name AS "Color"
FROM (
		(SELECT *,
				ROW_NUMBER () OVER (PARTITION BY tab.set_year ORDER BY tab.sum_color_parts DESC)
		FROM 
				(SELECT ls.set_year,
						ip.color_id,
						c.color_name,
						sum(sum(ip.quantity)) OVER (PARTITION BY ls.set_year, ip.color_id) AS sum_color_parts
				FROM inventory_parts ip 
				INNER JOIN inventories i 
				ON i.inventory_id =ip.inventory_id 
				INNER JOIN lego_sets ls
				ON ls.set_num = i.set_num 
				INNER JOIN colors c
				ON c.color_id =ip.color_id
				GROUP BY ls.set_year,
						ip.color_id,
						c.color_name) tab))tab2
WHERE row_number<=3;

--2a to check whether the calculation is correct I suggest to select 
--all information related to 1950 and blue color(color id = 1)
--the result of this below request will show that blue brick is used once in 10 different version of sets
--(please refer to the project description for more details)
--so blue color is used 10 times in all sets issued in 1950, which supports my calculation above
SELECT *
FROM inventory_parts ip 
INNER JOIN inventories i 
ON i.inventory_id =ip.inventory_id 
INNER JOIN lego_sets ls
ON ls.set_num = i.set_num 
INNER JOIN colors c
ON c.color_id =ip.color_id
WHERE  ls.set_year =1950 AND ip.color_id=1;

--2b for demonstration purposes let's have 1 color for each year

SELECT TO_CHAR (tab2.set_year, '9999') AS "Year",
		tab2.color_name AS "Color"
FROM (
		(SELECT *,
				ROW_NUMBER () OVER (PARTITION BY tab.set_year ORDER BY tab.sum_color_parts DESC)
		FROM 
				(SELECT ls.set_year,
						ip.color_id,
						c.color_name,
						sum(sum(ip.quantity)) OVER (PARTITION BY ls.set_year, ip.color_id) AS sum_color_parts
				FROM inventory_parts ip 
				INNER JOIN inventories i 
				ON i.inventory_id =ip.inventory_id 
				INNER JOIN lego_sets ls
				ON ls.set_num = i.set_num 
				INNER JOIN colors c
				ON c.color_id =ip.color_id
				GROUP BY ls.set_year,
						ip.color_id,
						c.color_name) tab))tab2
WHERE row_number<=1;

--3 top 3 colors IN EACH theme

SELECT tab2.theme_name AS "Theme",
		tab2.color_name AS "Color"
FROM (
		(SELECT *,
				ROW_NUMBER () OVER (PARTITION BY tab.theme_id ORDER BY tab.sum_color_parts DESC)
		FROM 
				(SELECT ls.theme_id,
						t.theme_name,
						ip.color_id,
						c.color_name,
						sum(sum(ip.quantity)) OVER (PARTITION BY ls.theme_id, ip.color_id) AS sum_color_parts
				FROM inventory_parts ip 
				INNER JOIN inventories i 
				ON i.inventory_id =ip.inventory_id 
				INNER JOIN lego_sets ls
				ON ls.set_num = i.set_num 
				INNER JOIN colors c
				ON c.color_id =ip.color_id
				INNER JOIN themes t
				ON t.theme_id =ls.theme_id 
				GROUP BY ls.theme_id,
						t.theme_name,
						ip.color_id,
						c.color_name) tab))tab2
WHERE row_number<=3;

--3a for demonstration purposes
SELECT *
FROM (
		(SELECT *,
				ROW_NUMBER () OVER (PARTITION BY tab.theme_id ORDER BY tab.sum_color_parts DESC)
		FROM 
				(SELECT ls.theme_id,
						t.theme_name,
						ip.color_id,
						c.color_name,
						sum(sum(ip.quantity)) OVER (PARTITION BY ls.theme_id, ip.color_id) AS sum_color_parts
				FROM inventory_parts ip 
				INNER JOIN inventories i 
				ON i.inventory_id =ip.inventory_id 
				INNER JOIN lego_sets ls
				ON ls.set_num = i.set_num 
				INNER JOIN colors c
				ON c.color_id =ip.color_id
				INNER JOIN themes t
				ON t.theme_id =ls.theme_id 
				GROUP BY ls.theme_id,
						t.theme_name,
						ip.color_id,
						c.color_name) tab))tab2
WHERE row_number<=1;

-- 4. number OF SETS IN top10 themes by number of sets AND years WHEN SETS were issued
-- the result show that for example technic theme consists of technic itself. also service packs (theme 443) has technic theme in it (453)

SELECT DISTINCT t.theme_id AS "Theme ID", 
				t.theme_name AS "Theme",
		count(count (ls.set_num)) OVER (PARTITION BY t.theme_id) AS "Number of Sets",
		min (ls.set_year) OVER (PARTITION BY t.theme_id)  || '-' || 
		max (ls.set_year) OVER (PARTITION BY t.theme_id) AS "Years"
FROM lego_sets ls
INNER JOIN themes t
ON t.theme_id =ls.theme_id 
GROUP BY t.theme_id, t.theme_name, ls.set_year 
ORDER BY 3 DESC
LIMIT 10;