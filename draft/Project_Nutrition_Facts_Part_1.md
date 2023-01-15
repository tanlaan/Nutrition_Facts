# Operation Nutrition Facts: Part 1

## Building an MVP Dataset API

### Introduction

I've been having ideas lately that involve food consumption both through purchasing as well as for dieting. Being able to look up a food by UPC code and have it's nutrition information readily available seems like a pretty powerful thing. Lucky for us, the USDA has provided a public data set for just such an occasion. They even have a public API that you merely have to apply for. This is fantastic! The rates are even pretty good, especially if they are ran client side as the API key is limited to 1000 queries per hour per IP address. The thing is, there are plenty of public data sets that may **not** have a public API or may have less reasonable limits. In that case, this walk through should get you the information you need in order to locally query the data in any fashion you see fit!

### Get the data

To begin we need to download the `.csv` file from their website. For this part, we are going to do everything "manually", later I would like to look in to automating the data acquisition portion of this in order to keep the data up to date, with as little bandwidth usage as possible. Their main website is: https://fdc.nal.usda.gov/index.html which gives a cursory look at what the data is about. However you can find the `.csv` files here: https://fdc.nal.usda.gov/download-datasets.html . Find the most recent link under the label "Full Download of All Data Types". This download as of the production of this article is ~300MB in size. Unzipping this file results in an additional ~2GB of space. Finally pulling that data into a Postgres database will result in yet another ~2GB of file size. Once imported however, you are free to delete the files, although I wouldn't jump to that point just yet, you may want to mess around with your data imports later.


### Install Postgres

With the data downloaded and unzipped, we should probably make sure we have postgres installed on out machine. Go on over to https://www.postgresql.org/download/ to grab the installer for your particular system. Follow the instructions for installation and make sure we have a user available to run the `.sql` file we will be using for our data import. The gist of what our file will contain is explained in this stackoverflow post: https://stackoverflow.com/questions/2987433/how-to-import-csv-file-data-into-a-postgresql-table . The basic steps we will repeat are as follows:

1. check for and `create schema`
2. for each csv file:
  1. `create table` with each csv header as a column and their type as `text` to start to make things easy to import
  2. use the `copy` command to copy the data from the csv with delimeter information.

In this particular case we want to get the data from all the CSVs we downloaded from the USDA. These include: food.csv, food_attribute.csv, food_nutrient.csv, food_update_log_entry.csv. So what are these files about and what are they used for? Luckily the USDA has a fantastic explanation included with their files. If you check out the file "Download & API Field Descriptions October 2022.pdf" you can see what their respective fields are and get an idea of how the data is linked together.

### Write Some SQL

We need to get our data out of the CSV we downloaded and in to the database we just installed. The easiest way is going to be writing up a `.sql` file that will allow us to run it in `psql`.

Because we may run this more than once, our first step is to drop the schema we are about to create from the table. In a sense this means we can guarantee that the table we indend to populate _will not exist_ when we go to create it or modify it.

```
drop schema if exists usda cascade;
```

We then need to create the new schema and our first table within in it.

```
create schema usda;

create table usda.food(
  fdc_id text,
  data_type text,
  description text,
  food_category_id text,
  publication_date text
);
```

What this does is creates some columns that we will fill with our data from the CSV. This dataset actually comes with a metadata file that will tell you all the column  names and their associated data types. For now we will keep them all as text in order to make sure that we can easily ingest the data to the new database. 

This is actually where you may want to diverge from these instructions and actually make them their specific data type if it could have benefits to how you use your data in the future.

The next step is to import the data for this table from the CSV we downloaded.
```
copy usda.food
from '/home/chris/Documents/USDA Food Datas/food.csv' 
with (FORMAT csv, DELIMITER ',');
```

You then do the same cycle for the other 4 tables.

```
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
```

### Run Said SQL

I had created a user during my postgres installation that matched my username.

This command will:

`psql` run a psql command `-U` Run as user `chris` `-d` Run against the `usda` database `-a` output all information `-f` use this full and specific file path.

```
psql -U chris -d usda -a -f '/home/chris/Documents/USDA Food Datas/usda/import.sql'
```

This command may take a decent bit to process through that 2gb `.csv` file depending on your computer.

Once completed we should now have the database ready for use by a rails app! We just need to make one first.

### Make a Rails App

Have `rails` create a `new` rails app called `usda` 

```
rails new usda
```

We now have the skeleton of a rails app created for us. The next step is to hook up the tables we just made to rails. Rails expects a specific kind of table formatting as a default, this is having the [singularized_table_name_id]("https://www.bigbinary.com/books/learn-rubyonrails-book/summarizing-rails-naming-conventions#naming-conventions-for-databases"). The problem is that our tables from the CSV file do not follow this pattern. So we must specify where to look for via `self.table_name` and `self.primary_key`.

```
# src/app/models/branded_food.rb
class BrandedFood < ApplicationRecord
  self.table_name = 'branded_food'
  self.primary_key = 'fdc_id'
end
```

We had a reference included with the dataset that should make it very easy to identify which column is the table id. Do this for all the other tables.

```
# src/app/models/food_attribute.rb -- ditto
# src/app/models/food_nutrient.rb  -- ditto
# src/app/models/food.rb  -- ditto
```

### Making an API

We will need both a route to a controller as well as the controller itself to handle gathering the needed data for a request.