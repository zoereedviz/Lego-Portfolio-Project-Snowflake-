# LEGO Project Using Snowflake

![daniel-k-cheung-B7N0IjiIJYo-unsplash](https://github.com/user-attachments/assets/e168dd7f-d817-47b7-8a34-f479e13e64bf)

## Overview

- Create a new schema in a Snowflake database, create tables and insert data into them. Set up relationships and visualise the model with an ER diagram.
- Analyse the dataset created to derive insights about LEGO.

## Commands and Constraints Used in this Project

### CREATE
Creating schema and tables.



## INSERT INTO
Inserting data into tables from another table in Snowflake.



## ALTER, FOREIGN KEY, PRIMARY KEY and REFERENCES
Using contraints to set primary and foreign keys to create relationships between tables.

'''
ALTER TABLE colors ADD PRIMARY KEY (id);
ALTER TABLE inventory_parts ADD FOREIGN KEY (color_id) REFERENCES colors(id);
'''

These queries set the x as the primary key in x, and relates it to x in x table.

