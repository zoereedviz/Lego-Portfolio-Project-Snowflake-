-- PART 1: SCHEMA SETUP

-- Create a schema called ZOE_LEGO_SCHEMA:
CREATE SCHEMA ZOE_LEGO_SCHEMA;

-- Create the tables and define the columns each contains:
CREATE OR REPLACE TABLE colors (
    id smallint,
    name varchar(50),
    rgb varchar(6),
    is_trans varchar(1)
    );

CREATE OR REPLACE TABLE inventories (
    id smallint,
    version smallint,
    set_num varchar(20)
    );

CREATE OR REPLACE TABLE inventory_parts (
    inventory_id smallint,
    part_num varchar(15),
    color_id smallint,
    quantity smallint,
    is_spare varchar(1) 
    );

CREATE OR REPLACE TABLE inventory_sets (
    inventory_id smallint,
    set_num varchar(20),
    quantity smallint
    );

CREATE OR REPLACE TABLE part_categories (
    id smallint,
    name varchar(50)
    );

CREATE OR REPLACE TABLE parts (
    part_num varchar(15),
    name varchar(225),
    part_cat_id smallint
    );

CREATE OR REPLACE TABLE sets (
    set_num varchar(20),
    name varchar(100),
    year smallint,
    theme_id smallint,
    num_parts smallint
    );

CREATE OR REPLACE TABLE themes (
    id smallint,
    name varchar(50),
    parent_id smallint
    );

-- Insert data from STAGING schema to the tables in ZOE_LEGO_SCHEMA:

INSERT INTO colors
SELECT * FROM TIL_PORTFOLIO_PROJECTS.STAGING.LEGO_COLORS;

INSERT INTO inventories
SELECT * FROM TIL_PORTFOLIO_PROJECTS.STAGING.LEGO_INVENTORIES;

INSERT INTO inventory_parts
SELECT * FROM TIL_PORTFOLIO_PROJECTS.STAGING.LEGO_INVENTORY_PARTS;

INSERT INTO inventory_sets
SELECT * FROM TIL_PORTFOLIO_PROJECTS.STAGING.LEGO_INVENTORY_SETS;

INSERT INTO part_categories
SELECT * FROM TIL_PORTFOLIO_PROJECTS.STAGING.LEGO_PART_CATEGORIES;

INSERT INTO parts
SELECT * FROM TIL_PORTFOLIO_PROJECTS.STAGING.LEGO_PARTS;

INSERT INTO sets
SELECT * FROM TIL_PORTFOLIO_PROJECTS.STAGING.LEGO_SETS;

INSERT INTO themes
SELECT * FROM TIL_PORTFOLIO_PROJECTS.STAGING.LEGO_THEMES;

-- Set Primary Keys and Foreign Keys to create relationships between the tables:

-- Relationship from colors to inventory_parts
ALTER TABLE colors ADD PRIMARY KEY (id);
ALTER TABLE inventory_parts ADD FOREIGN KEY (color_id) REFERENCES colors(id);

-- Relationship from part_categories to parts
ALTER TABLE part_categories ADD PRIMARY KEY (id);
ALTER TABLE parts ADD FOREIGN KEY (part_cat_id) REFERENCES part_categories(id);

-- Relationship from themes to sets
ALTER TABLE themes ADD PRIMARY KEY (id);
ALTER TABLE sets ADD FOREIGN KEY (theme_id) REFERENCES themes(id);

-- Relationship from inventories to inventory_sets and inventory_parts
ALTER TABLE inventories ADD PRIMARY KEY (id);
ALTER TABLE inventory_sets ADD FOREIGN KEY (inventory_id) REFERENCES inventories(id);
ALTER TABLE inventory_parts ADD FOREIGN KEY (inventory_id) REFERENCES inventories(id);

-- Relationship from parts to inventory_parts
ALTER TABLE parts ADD PRIMARY KEY (part_num);
ALTER TABLE inventory_parts ADD FOREIGN KEY (part_num) REFERENCES parts(part_num);

-- Relationship from sets to inventory_sets and inventories
ALTER TABLE sets ADD PRIMARY KEY (set_num);
ALTER TABLE inventory_sets ADD FOREIGN KEY (set_num) REFERENCES sets(set_num);
ALTER TABLE inventories ADD FOREIGN KEY (set_num) REFERENCES sets(set_num);

-- PART 2: ANALYSIS OF LEGO SETS
-- Firstly, unique parts (parts that appear in only one LEGO set) will be identified.
-- Secondly, a number of calculations will be done for each set. These include the number of unique parts in a set, the total number of different parts in a set and the ratio of unique parts to total parts as a measure of 'uniqueness' for each set. The set year and theme name will also be retrieved for each set.

-- Join themes table to obtain the theme name for each set. Select required fields for the analysis and create a view.
CREATE OR REPLACE VIEW lego_sets_analysis AS (
    -- Join sets table and calculate the number of unique parts, total number of different parts and a uniqueness ratio for each set. 
    WITH set_info_cte AS (
        -- Join parts, inventory_parts, inventories and sets to relate part_num and set_num. Aggregate to create a flag for unique parts.
        WITH unique_part_flag_cte AS (
            SELECT
                p.part_num AS part_num,
                COUNT (DISTINCT s.set_num) AS sets_used_in,
                CASE 
                    WHEN COUNT (DISTINCT s.set_num)=1 THEN 1
                    ELSE 0
                    END AS unique_part_flag
            FROM parts AS p
            INNER JOIN inventory_parts AS ip ON p.part_num = ip.part_num
            INNER JOIN inventories AS i ON ip.inventory_id = i.id
            INNER JOIN sets AS s ON s.set_num = i.set_num
            GROUP BY p.part_num)
        SELECT
            s.set_num,
            s.theme_id,
            s.year,
            SUM(unique_part_flag_cte.unique_part_flag) AS unique_parts_in_set,
            COUNT(unique_part_flag_cte.unique_part_flag) AS total_parts_in_set,
            ROUND(SUM(unique_part_flag_cte.unique_part_flag)/COUNT(unique_part_flag_cte.unique_part_flag), 2) AS uniqueness_ratio,
        FROM unique_part_flag_cte
        INNER JOIN inventory_parts AS ip ON unique_part_flag_cte.part_num = ip.part_num
        INNER JOIN inventories AS i ON ip.inventory_id = i.id
        INNER JOIN sets AS s ON s.set_num = i.set_num
        GROUP BY s.set_num, s.theme_id, s.year)
    SELECT
        set_info_cte.set_num,
        set_info_cte.unique_parts_in_set,
        set_info_cte.total_parts_in_set,
        set_info_cte.uniqueness_ratio,
        set_info_cte.year AS set_year,
        t.name AS theme_name    
    FROM set_info_cte
    INNER JOIN themes AS t ON t.id = set_info_cte.theme_id);
