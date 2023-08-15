# Case Study 6 - Clique Bait

![6](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/eb17e82b-c8fa-4623-821b-2c82dd9097af)


# Table of Content
- Introduction
- Entity Relationship Diagram
- Business Questions and Solutions via SQL Codes

## Introduction
Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - I am required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Entity Relationship Diagram

![Relationship Diagram](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/159be58e-a379-4869-8263-3210cfd7ca6d)

Some further details about the dataset:
- Users: Customers who visit the Clique Bait website are tagged via their `cookie_id`.
- Events: Customer visits are logged in this `events` table at a `cookie_id` level and the `event_type` and `page_id` values can be used to join onto relevant satellite tables to obtain further information about each event. The sequence_number is used to order the events within each visit.
- Event Identifier: The `event_identifier` table shows the types of events which are captured by Clique Bait’s digital data systems.
- Campaign Identifier: This table shows information for the 3 campaigns that Clique Bait has run on their website so far in 2020.
- Page Hierarchy: This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

## Business Questions and Solutions via SQL Codes

### A. Digital Analysis

Using the available datasets - answer the following questions using a single query for each one:

1. How many users are there?
2. How many cookies does each user have on average?
3. What is the unique number of visits by all users per month?
4. What is the number of events for each event type?
5. What is the percentage of visits which have a purchase event?
6. What is the percentage of visits which view the checkout page but do not have a purchase event?
7. What are the top 3 pages by number of views?
8. What is the number of views and cart adds for each product category?
9. What are the top 3 products by purchase?

### B. Product Funnel Analysis

### C. Campaigns Analysis








