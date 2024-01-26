--A. Data Exploration and Cleansing

/* 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date 
data type with the start of the month */

ALTER TABLE fresh_segments.interest_metrics
ALTER COLUMN month_year TYPE DATE USING to_date(month_year, 'MM-YYYY');

SELECT * 
FROM fresh_segments.interest_metrics
LIMIT 5;

/* 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted 
in chronological order (earliest to latest) with the null values appearing first? */

SELECT month_year, COUNT(*)
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year ASC NULLS FIRST;

/* 3. What do you think we should do with these null values in the fresh_segments.interest_metrics */

/* 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the 
fresh_segments.interest_map table? What about the other way around? */

ALTER TABLE fresh_segments.interest_metrics
ALTER COLUMN interest_id TYPE INT USING interest_id::integer; 
--need to alter the data type of interest_id to match data type of id in the interest_map table

SELECT COUNT(DISTINCT interest_id)
FROM fresh_segments.interest_metrics
LEFT JOIN fresh_segments.interest_map
ON fresh_segments.interest_metrics.interest_id = fresh_segments.interest_map.id
WHERE fresh_segments.interest_map.id IS NULL;

SELECT COUNT(DISTINCT fresh_segments.interest_map.id)
FROM fresh_segments.interest_metrics
RIGHT JOIN fresh_segments.interest_map
ON fresh_segments.interest_metrics.interest_id = fresh_segments.interest_map.id
WHERE fresh_segments.interest_metrics.interest_id IS NULL;

-- sanity check
SELECT COUNT(DISTINCT interest_id) "interest_id_count"
FROM fresh_segments.interest_metrics;

SELECT COUNT(DISTINCT id) "id_count"
FROM fresh_segments.fresh_segments.interest_map;
 
/* 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table */
SELECT COUNT(fresh_segments.interest_map.id)
FROM fresh_segments.interest_map;

SELECT id, COUNT(*) AS record_count
FROM fresh_segments.interest_map
GROUP BY id
ORDER BY record_count DESC;

/* 6. What sort of table join should we perform for our analysis and why? Check your logic by checking 
the rows where interest_id = 21246 in your joined output and include all columns from 
fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column. */

--If our goal is to analyze the records in the interest_metrics table, to ensure that we include all 
--the necessary records in the interest_metrics table, we should use LEFT INNER JOIN to join the tables, 
-- as the interest_map table is just a reference table to pull in additional reference information for 
-- the records in the interest_metrics table.

SELECT _month, _year, month_year, integer_id, composition, index_value, ranking, percentile_ranking,
		interest_name, interest_summary, created_at, last_modified 
		--postgreSQL dialect doesn't have the SELECT * EXCEPT ability, so it's best to list all relevant columns 
FROM fresh_segments.interest_metrics
LEFT JOIN fresh_segments.interest_map
ON fresh_segments.interest_metrics.interest_id = fresh_segments.interest_map.id
WHERE interest_id = 21246;

/* 7. Are there any records in your joined table where the month_year value is before the created_at 
value from the fresh_segments.interest_map table? Do you think these values are valid and why? */
WITH new_interest_map_cte AS (
SELECT id, interest_name, interest_summary,
	DATE(created_at) "created_at_date",
	created_at::time "created_at_time"
FROM fresh_segments.interest_map
)
SELECT _month, _year, month_year, created_at_date
		--postgreSQL dialect doesn't have the SELECT * EXCEPT ability, so it's best to list all relevant columns 
FROM fresh_segments.interest_metrics
LEFT JOIN new_interest_map_cte
ON fresh_segments.interest_metrics.interest_id = new_interest_map_cte.id
WHERE month_year < created_at_date;


-- B. Interest Analysis

/* 1. Which interests have been present in all month_year dates in our dataset? */

/* 2. Using this same total_months measure - calculate the cumulative percentage of all records starting
at 14 months - which total_months value passes the 90% cumulative percentage value? */

/* 3. If we were to remove all interest_id values which are lower than the total_months value we found 
in the previous question - how many total data points would we be removing? */

/* 4. Does this decision make sense to remove these data points from a business perspective? Use an 
example where there are all 14 months present to a removed interest example for your arguments - think 
about what it means to have less months present from a segment perspective. */

/* 5. After removing these interests - how many unique interests are there for each month? */

-- C.Segment Analysis

/* 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which 
are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
Only use the maximum composition value for each interest but you must keep the corresponding month_year */

/* 2. Which 5 interests had the lowest average ranking value? */

/* 3. Which 5 interests had the largest standard deviation in their percentile_ranking value? */

/* 4. For the 5 interests found in the previous question - what was minimum and maximum 
percentile_ranking values for each interest and its corresponding year_month value? Can you describe 
what is happening for these 5 interests? */

/* 5. How would you describe our customers in this segment based off their composition and ranking 
values? What sort of products or services should we show to these customers and what should we avoid? */

-- D.Index Analysis

/*The index_value is a measure which can be used to reverse calculate the average composition for 
Fresh Segments’ clients.
Average composition can be calculated by dividing the composition column by the index_value column 
rounded to 2 decimal places. */

/* 1. What is the top 10 interests by the average composition for each month? */

/* 2. For all of these top 10 interests - which interest appears the most often? */

/* 3. What is the average of the average composition for the top 10 interests for each month? */

/* 4. What is the 3 month rolling average of the max average composition value from September 2018 to 
August 2019 and include the previous top ranking interests in the same output shown below. */

/* 5. Provide a possible reason why the max average composition might change from month to month? Could 
it signal something is not quite right with the overall business model for Fresh Segments? */