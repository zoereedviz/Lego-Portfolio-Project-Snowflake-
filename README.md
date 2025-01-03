# LEGO Project Using Snowflake

![daniel-k-cheung-B7N0IjiIJYo-unsplash](https://github.com/user-attachments/assets/e168dd7f-d817-47b7-8a34-f479e13e64bf)

## Project Overview

- Create a schema in a Snowflake database, create tables and insert data into them. Set up relationships and visualise the model with an ER diagram.
- Analyse the dataset created to derive insights about various LEGO sets.

## Commands and Constraints Used in this Project

### CREATE
Creating schema and tables.

```
CREATE SCHEMA ZOE_LEGO_SCHEMA;
CREATE TABLE colors (
  id smallint,
  name varchar(50),
  rgb varchar(6),
  is_trans varchar(1)
);
```
These queries create a new schema called ZOE_LEGO_SCHEMA and creates the table colors with four fields.


### INSERT INTO
Inserting data into tables from another table in Snowflake.

```
INSERT INTO colors
SELECT * FROM DATABASE_NAME.STAGING.LEGO_COLORS;
```
This query populates the table colors with all the data from the table LEGO_COLORS.


### ALTER, FOREIGN KEY, PRIMARY KEY and REFERENCES
Using contraints to set primary and foreign keys to create relationships between tables.

```
ALTER TABLE colors ADD PRIMARY KEY (id);
ALTER TABLE inventory_parts ADD FOREIGN KEY (color_id) REFERENCES colors(id);
```

These queries set the field id as the primary key in colors, and relates colors to inventory_parts via the foreign key color_id.

## ER Diagram
ER Diagram from DBeaver to visualise the model built in the project so far.

![ZOE_LEGO_SCHEMA ER Diagram](https://github.com/user-attachments/assets/f31be9a6-ff8f-4a30-b737-d3d29526fbaa)

An ER Diagram can be created by setting up a database connection in DBeaver to the Snowflake Database the project is in and locating the relevant schema. An ER Diagram is built automatically.

