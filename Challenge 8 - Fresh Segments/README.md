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

#### Interest Metrics
This table contains information about aggregated interest metrics for a specific major client of Fresh Segments which makes up a large proportion of their customer base.

Each record in this table represents the performance of a specific interest_id based on the client’s customer base interest measured through clicks and interactions with specific targeted advertising content.

#### Interest Map
This mapping table links the interest_id with their relevant interest information. We will need to join this table onto the previous interest_details table to obtain the interest_name as well as any details about the summary information.

## Business Questions and Solutions via SQL Codes

The following questions can be considered key business questions that are required to be answered for the Fresh Segments team.

Most questions can be answered using a single query however some questions are more open ended and require additional thought and not just a coded solution!

### A. Data Exploration and Cleansing


1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

```

```
###### Answer:

2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

```

```
###### Answer:

3. What do you think we should do with these null values in the fresh_segments.interest_metrics

```

```
###### Answer:

4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

```

```
###### Answer:

5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table

```

```
###### Answer:

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

