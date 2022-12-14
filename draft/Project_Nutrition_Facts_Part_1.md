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

