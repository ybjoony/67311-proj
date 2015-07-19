-- TABLE STRUCTURE FOR PATS DATABASE
--
-- by Abe Yoon & Leo Ying
--
--
CREATE TABLE owners(
id SERIAL PRIMARY KEY,
first_name character varying(50) NOT NULL,
last_name character varying(50) NOT NULL,
street character varying(255) NOT NULL,
city character varying(50) NOT NULL,
state character varying(50) DEFAULT 'PA',
zip character varying(12) NOT NULL,
phone char(10),
email character varying(50),
active boolean DEFAULT true
);

CREATE TABLE pets(
id SERIAL PRIMARY KEY,
name character varying(50) NOT NULL,
animal_id integer NOT NULL,
owner_id integer NOT NULL,
female boolean NOT NULL,
date_of_birth DATE,
active boolean DEFAULT true
);

CREATE TABLE visits(
id SERIAL PRIMARY KEY,
pet_id INTEGER NOT NULL,
date DATE NOT NULL,
weight INTEGER,
overnight_stay boolean DEFAULT false,
total_charge INTEGER DEFAULT 0
);

CREATE TABLE animals(
id SERIAL PRIMARY KEY,
name character varying(50) NOT NULL,
active boolean DEFAULT true
);

CREATE TABLE medicines(
id SERIAL PRIMARY KEY,
name character varying(50) NOT NULL,
description text NOT NULL,
stock_amount INTEGER NOT NULL,
method character varying(50) NOT NULL,
unit character varying(50) NOT NULL,
vaccine boolean DEFAULT false
);

CREATE TABLE medicine_costs(
id SERIAL PRIMARY KEY,
medicine_id INTEGER NOT NULL,
cost_per_unit INTEGER NOT NULL,
start_date DATE NOT NULL,
end_date DATE
);

CREATE TABLE animal_medicines(
id SERIAL PRIMARY KEY,
animal_id INTEGER NOT NULL,
medicine_id INTEGER NOT NULL,
recommended_num_of_units INTEGER
);

CREATE TABLE visit_medicines(
id SERIAL PRIMARY KEY,
visit_id INTEGER NOT NULL,
medicine_id INTEGER NOT NULL,
units_given INTEGER NOT NULL,
discount numeric(3,2) DEFAULT 0
);

CREATE TABLE procedures(
id SERIAL PRIMARY KEY,
name character varying(50) NOT NULL,
description text,
length_of_time INTEGER NOT NULL,
active boolean DEFAULT true
);

CREATE TABLE treatments(
id SERIAL PRIMARY KEY,
visit_id INTEGER NOT NULL,
procedure_id INTEGER NOT NULL,
successful boolean,
discount numeric(3,2) DEFAULT 0
);

CREATE TABLE procedure_costs(
id SERIAL PRIMARY KEY,
procedure_id INTEGER NOT NULL,
cost INTEGER NOT NULL,
start_date DATE NOT NULL,
end_date DATE
);

CREATE TABLE notes(
id SERIAL PRIMARY KEY,
notable_type character varying(50) NOT NULL,
notable_id INTEGER NOT NULL,
title character varying(50) NOT NULL,
content text NOT NULL,
user_id INTEGER NOT NULL,
date DATE NOT NULL
);

CREATE TABLE users(
id SERIAL PRIMARY KEY,
first_name character varying(50) NOT NULL,
last_name character varying(50) NOT NULL,
username character varying(50) NOT NULL UNIQUE,
role character varying(50) NOT NULL,
password_digest character varying(500) NOT NULL,
active boolean DEFAULT true
);
