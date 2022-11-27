drop schema if exists usda cascade;
create schema usda;

create table usda.food(
  fdc_id text,
  data_type text,
  description text,
  food_category_id text,
  publication_date text
);
copy usda.food
from '/home/chris/Documents/USDA Food Datas/food.csv' 
with (FORMAT csv, DELIMITER ',');

create table usda.food_nutrient(
  id text,
  fdc_id text,
  nutrient_id text,
  amount text,
  data_points text,
  derivation_id text,
  min text,
  max text,
  median text,
  footnote text,
  min_year_acquired text
);
copy usda.food_nutrient
from '/home/chris/Documents/USDA Food Datas/food_nutrient.csv'
with (FORMAT csv, DELIMITER ',');

create table usda.food_attribute(
  id text,
  fdc_id text,
  seq_num text,
  food_attribute_type_id text,
  name text,
  value text
);
copy usda.food_attribute
from '/home/chris/Documents/USDA Food Datas/food_attribute.csv'
with (FORMAT csv, DELIMITER ',');

create table usda.food_update_log_entry(
  id text,
  description text,
  lat_updated text
);
copy usda.food_update_log_entry
from '/home/chris/Documents/USDA Food Datas/food_update_log_entry.csv'
with (FORMAT csv, DELIMITER ',');

create table usda.branded_food(
  fdc_id text,
  brand_owner text,
  brand_name text,
  subbrand_name text,
  gtin_upc text,
  ingredients text,
  not_a_significant_source_of text,
  serving_size text,
  serving_size_unit text,
  household_serving_fulltext text,
  branded_food_category text,
  data_source text,
  package_weight text,
  modified_date text,
  available_date text,
  market_country text,
  discontinued_date text,
  preparation_state_code text,
  trade_channel text
);
copy usda.branded_food
from '/home/chris/Documents/USDA Food Datas/branded_food.csv'
with (FORMAT csv, DELIMITER ',');

