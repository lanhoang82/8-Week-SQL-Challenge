# Case Study 8 - Fresh Segments - [In Progress]

![Week 8 Cover](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/9ff4c515-01f3-4d57-8d86-0f4c42c6d4f9)


# Table of Content
- Introduction
- Entity Relationship Diagram
- Business Questions and Solutions via SQL Codes

## Introduction
Danny created Fresh Segments, a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.

Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.

In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.

Danny has asked for our assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests.

## Entity Relationship Diagram

For this case study there is a total of 2 datasets which we will need to use to solve the questions.

![Fresh Segments Entity Relationship Diagram](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/8aaf24d8-aee7-4bd1-b0cf-e579da2170c4)

#### Interest Metrics
This table contains information about aggregated interest metrics for a specific major client of Fresh Segments which makes up a large proportion of their customer base.

Each record in this table represents the performance of a specific interest_id based on the client’s customer base interest measured through clicks and interactions with specifically targeted advertising content.

#### Interest Map
This mapping table links the interest_id with their relevant interest information. We will need to join this table onto the previous interest_details table to obtain the interest_name as well as any details about the summary information.

## Business Questions and Solutions via SQL Codes

The following questions can be considered key business questions that are required to be answered for the Fresh Segments team.

Most questions can be answered using a single query however some questions are more open-ended and require additional thought and not just a coded solution!

### A. Data Exploration and Cleansing


1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

```
ALTER TABLE fresh_segments.interest_metrics
ALTER COLUMN month_year TYPE DATE USING to_date(month_year, 'MM-YYYY');
```
###### Answer:
![8 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/375ee27a-443f-4c99-b15a-3e505b22a9ac)

2. What is the count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

```
SELECT month_year, COUNT(*)
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year ASC NULLS FIRST;
```
###### Answer:
![8 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/90eee00e-dc6d-420d-833a-f2b39820bf2b)

3. What do you think we should do with these null values in the fresh_segments.interest_metrics


###### Answer:

Handling null values in the fresh_segments.interest_metrics table depends on the nature of our analysis and the specific requirements of our insights. If we have no way to recover the missing data, and the analysis requires insights to be over time, it might be a good idea to exclude the missing rows. Otherwise, if at all possible, find the way to impute/replace the missing values with the closest approximates. 

4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? 

```
ALTER TABLE fresh_segments.interest_metrics
ALTER COLUMN interest_id TYPE INT USING interest_id::integer; 
--need to alter the data type of interest_id to match data type of id in the interest_map table

SELECT COUNT(DISTINCT interest_id)
FROM fresh_segments.interest_metrics
LEFT JOIN fresh_segments.interest_map
ON fresh_segments.interest_metrics.interest_id = fresh_segments.interest_map.id
WHERE fresh_segments.interest_map.id IS NULL;
```
###### Answer:
![8 4 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/503a018b-4772-48fa-908a-e25a3ab674b2)

What about the other way around?
```
SELECT COUNT(DISTINCT fresh_segments.interest_map.id)
FROM fresh_segments.interest_metrics
RIGHT JOIN fresh_segments.interest_map
ON fresh_segments.interest_metrics.interest_id = fresh_segments.interest_map.id
WHERE fresh_segments.interest_metrics.interest_id IS NULL;
```
![8 4 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/52decdea-7f69-4e19-bf0c-f19506c2ea98)

5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table

```
SELECT COUNT(fresh_segments.interest_map.id)
FROM fresh_segments.interest_map;

SELECT id, COUNT(*) AS record_count
FROM fresh_segments.interest_map
GROUP BY id
ORDER BY record_count DESC;
```
###### Answer:
![8 5](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/7f01209b-aec1-4eaf-865c-de6dbfa3ec31)

6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

If our goal is to analyze the records in the interest_metrics table, to ensure that we include all the necessary records in the interest_metrics table, we should use LEFT INNER JOIN to join the tables, as the interest_map table is just a reference table to pull in additional reference information for the records in the interest_metrics table.

```
SELECT _month, _year, month_year, integer_id, composition, index_value, ranking, percentile_ranking,
		interest_name, interest_summary, created_at, last_modified 
		--postgreSQL dialect doesn't have the SELECT * EXCEPT ability, so it's best to list all relevant columns 
FROM fresh_segments.interest_metrics
LEFT JOIN fresh_segments.interest_map
ON fresh_segments.interest_metrics.interest_id = fresh_segments.interest_map.id
WHERE interest_id = 21246;
```
###### Answer:
![8 6](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/2b22ee64-a094-457c-86b8-43b12d8b38c8)

7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

```
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
```
###### Answer:
![8 7](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/381fc34e-6f12-413e-9524-d6f7dd6b47eb)

There are 188 records in my joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table. I don't think these values are valid, at least in the sense the metric for a measure was created before the interest was defined. But if the client wants backtrack and retrospective measure the interest, that would also be possible but this should be done with caution.


### B. Segment Analysis

1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year

```
WITH interest_greater_6_cte AS (
	SELECT interest_id, COUNT(DISTINCT month_year) "month_year_count"
	FROM fresh_segments.interest_metrics
	GROUP BY interest_id
	HAVING COUNT(DISTINCT month_year) >= 6
	
),
max_comp_per_interest AS(
    SELECT interest_id,
        MAX(composition) AS max_composition
    FROM fresh_segments.interest_metrics
    WHERE interest_id IN (SELECT interest_id FROM interest_greater_6_cte)
    GROUP BY interest_id
),
ranked_interest AS (
	SELECT mcpr.interest_id, max_composition, month_year,
		ROW_NUMBER() OVER (ORDER BY max_composition DESC) AS top_comp,
		ROW_NUMBER() OVER (ORDER BY max_composition ASC) AS bottom_comp
	    FROM max_comp_per_interest mcpr
		LEFT JOIN fresh_segments.interest_metrics im
		ON im.interest_id = mcpr.interest_id 
		AND im.composition = mcpr.max_composition
)
SELECT interest_id, interest_name, max_composition, month_year, 
	CASE 
	WHEN top_comp <= 10 THEN 'top 10' 
	WHEN bottom_comp <= 10 THEN 'bottom 10' 
	END top_or_bottom
FROM ranked_interest
LEFT JOIN fresh_segments.interest_map
ON ranked_interest.interest_id = fresh_segments.interest_map.id
WHERE top_comp <= 10 OR bottom_comp <= 10
ORDER BY max_composition DESC;
```

###### Answer:
![8c 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/36d6ea97-7b67-4df8-84eb-19055f75122b)


2. Which 5 interests had the lowest average ranking value?

```
SELECT interest_id, interest_name, ROUND(AVG(ranking), 2)  "avg_rank"
FROM fresh_segments.interest_metrics im
LEFT JOIN fresh_segments.interest_map ima
ON im.interest_id = ima.id
GROUP BY interest_id, interest_name
ORDER BY avg_rank ASC
LIMIT 5;
```

###### Answer:
![8c 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/1b109fb4-e115-4eb3-a02c-332c0dd7c68d)


3. Which 5 interests had the largest standard deviation in their percentile_ranking value? 

```
SELECT interest_id, interest_name, ROUND(stddev_pop(percentile_ranking)::numeric, 2)  "std_pct_rank"
FROM fresh_segments.interest_metrics im
LEFT JOIN fresh_segments.interest_map ima
ON im.interest_id = ima.id
WHERE interest_id IS NOT NULL
GROUP BY interest_id, interest_name
ORDER BY std_pct_rank DESC
LIMIT 5;
```
###### Answer:
![8c 3](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/186b83ba-0255-4c33-aa31-94204628c009)


4. For the 5 interests found in the previous question - what were the minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?

```
WITH max_std_pct_cte AS (
	SELECT interest_id, interest_name, ROUND(stddev_pop(percentile_ranking)::numeric, 2)  "std_pct_rank"
	FROM fresh_segments.interest_metrics im
	LEFT JOIN fresh_segments.interest_map ima
	ON im.interest_id = ima.id
	WHERE interest_id IS NOT NULL
	GROUP BY interest_id, interest_name
	ORDER BY std_pct_rank DESC
	LIMIT 5
),
ranked_pct_cte AS (
	SELECT im.interest_id, month_year, percentile_ranking,
		ROW_NUMBER() OVER (PARTITION BY im.interest_id ORDER BY percentile_ranking DESC) "pct_order"
	FROM fresh_segments.interest_metrics im
	RIGHT JOIN max_std_pct_cte mspc
	ON im.interest_id = mspc.interest_id
	ORDER BY interest_id ASC
),
min_max_pct_cte AS (
	SELECT interest_id, month_year, percentile_ranking,
	CASE
	WHEN pct_order = 1 THEN 'Max Percentile Rank'
	WHEN pct_order = MAX(pct_order) OVER (PARTITION BY interest_id) THEN 'Min Percentile Rank'
	ELSE NULL
	END min_max_pct
FROM ranked_pct_cte
)
SELECT mmpc.interest_id, interest_name, mmpc.month_year, mmpc.percentile_ranking, min_max_pct
FROM min_max_pct_cte mmpc
LEFT JOIN fresh_segments.interest_map ima
ON mmpc.interest_id = ima.id
WHERE min_max_pct = 'Max Percentile Rank' OR
		min_max_pct = 'Min Percentile Rank';
```
###### Answer:
![8c 4](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/da9e08ef-8a69-41a2-864d-d6c1e0f25228)

What we are seeing with these interests is the order of their index_value records decreases over various periods between 2018 and 2019. Particularly, the average percentage of the client's customer list interacted with the interest got lower over time for all Fresh Segments clients' customers. In short, people seem to get less interested in these topics and interact less with them over time.

5. How would you describe our customers in this segment based on their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

```
```
###### Answer:


### C. Index Analysis

