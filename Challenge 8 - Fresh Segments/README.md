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

```

```
###### Answer:

7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

```

```
###### Answer:

### B. Interest Analysis

### C. Segment Analysis

### D. Index Analysis

