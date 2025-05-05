CREATE TABLE themes

(
 theme_id INT PRIMARY KEY, -- constraints
 theme_name VARCHAR(140) NOT NULL,
 parent_id INT 
);


CREATE TABLE colors

(
 color_id INT PRIMARY KEY, -- constraints
 color_name VARCHAR(200) NOT NULL,
 rgb VARCHAR(6) NOT NULL,
 is_trans BOOLEAN NOT NULL --whether transparent or not
); 

CREATE TABLE part_categories

(
 part_cat_id INT PRIMARY KEY, -- constraints
 categ_name VARCHAR(200) NOT NULL
);

CREATE TABLE parts

(
 part_num VARCHAR(20) PRIMARY KEY, -- constraints
 part_name VARCHAR(250) NOT NULL,
 part_cat_id INT REFERENCES part_categories
);

CREATE TABLE lego_sets

(
 set_num VARCHAR(20) PRIMARY KEY, -- constraints
 set_name VARCHAR(256) NOT NULL,
 set_year INT,
 theme_id INT REFERENCES themes,
 num_parts INT
);

CREATE TABLE minifigs

(
 fig_num VARCHAR(20) PRIMARY KEY, -- constraints
 fig_name VARCHAR(256) NOT NULL,
 num_parts INT
);

CREATE TABLE inventories

(
 inventory_id INTEGER PRIMARY KEY,
 inv_vers INT,
 set_num VARCHAR(120) REFERENCES lego_sets
);

CREATE TABLE inventory_sets

(
 inventory_id INT REFERENCES inventories,
 set_num VARCHAR(120) REFERENCES lego_sets,
 quantity INT
);

CREATE TABLE inventory_parts

(
 inventory_id INT REFERENCES inventories,
 part_num VARCHAR(120) REFERENCES parts, -- constraints
 color_id INT REFERENCES colors,
 quantity INT NOT NULL,
 is_spare BOOLEAN NOT NULL
);

CREATE TABLE inventory_minifigs

(
 inventory_id INT REFERENCES inventories,
 fig_num VARCHAR(120) REFERENCES minifigs,
 quantity INT NOT NULL
);

ALTER TABLE colors RENAME COLUMN rgb TO hex;

ALTER TABLE themes ALTER COLUMN theme_name TYPE TEXT;

ALTER TABLE colors ALTER COLUMN color_name TYPE TEXT;

ALTER TABLE colors ALTER COLUMN hex TYPE TEXT;

ALTER TABLE colors ALTER COLUMN is_trans TYPE TEXT;

ALTER TABLE part_categories ALTER COLUMN categ_name TYPE TEXT;

ALTER TABLE parts ALTER COLUMN part_num TYPE TEXT;

ALTER TABLE parts ALTER COLUMN part_name TYPE TEXT;

ALTER TABLE lego_sets ALTER COLUMN set_num TYPE TEXT;

ALTER TABLE lego_sets ALTER COLUMN set_name TYPE TEXT;

ALTER TABLE minifigs ALTER COLUMN fig_num TYPE TEXT;

ALTER TABLE minifigs ALTER COLUMN fig_name TYPE TEXT;

ALTER TABLE inventories ALTER COLUMN set_num TYPE TEXT;

ALTER TABLE inventory_minifigs ALTER COLUMN fig_num TYPE TEXT;

ALTER TABLE inventory_parts ALTER COLUMN part_num TYPE TEXT;

ALTER TABLE inventory_parts ALTER COLUMN is_spare TYPE TEXT;

ALTER TABLE inventory_sets ALTER COLUMN set_num TYPE TEXT;

