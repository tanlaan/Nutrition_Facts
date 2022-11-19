# Operation Nutrition Facts: Introduction

## Part 1:

- Download CSV
- Get data into postgresql locally
- Build new ruby application
- Import schema
- Produce simplified REST API that just gives back all data on a food if the GTIN matches

## Part 2:

- Build docker container that will use a local source of the CSV to import into a dockerized version of postgres
- Automate downloading and unzipping the CSV as required
- Make docker port forwarded to local machine to be available for Ruby on Rails application

## Part 3:

- Build out Ruby on Rails application to mirror USDA API
- Build docker container for that Ruby on Rails application
- Put both together to create a dockerized nutrition facts application

## Sources
### Nutrition Facts

- Food Data Central: https://fdc.nal.usda.gov/index.html
- Data Set Download: https://fdc.nal.usda.gov/download-datasets.html
- API Guide: https://fdc.nal.usda.gov/api-guide.html
- OPEN API Representation: https://app.swaggerhub.com/apis/fdcnal/food-data_central_api/1.0.1
- Additional API Spec: https://fdc.nal.usda.gov/api-spec/fdc_api.html
- Data Type Comparison: https://fdc.nal.usda.gov/data-documentation.html

### CSV -> Postgres

- Use zcat and either a pipe or a program function to import without unzipping to disk: https://stackoverflow.com/questions/41738829/importing-zipped-csv-file-into-postgresql
- Create table then copy data from CSV: https://stackoverflow.com/questions/2987433/how-to-import-csv-file-data-into-a-postgresql-table

### Ruby on Rails

- Make sure to specify your table name when making new models for existing DB: https://guides.rubyonrails.org/v6.1/active_record_basics.html#overriding-the-naming-conventions
- Schema to Scaffold gem: https://github.com/frenesim/schema_to_scaffold
  - Article on using it: https://twinsunsolutions.com/blog/building-a-ruby-on-rails-app-with-a-legacy-database/
  - Accessing postgres schema produced in CSV->Postgres section. It’s considered a namespace and doesn’t show up in psql when you run the \dt (list tables) command. https://dba.stackexchange.com/questions/183748/postgres-permissions-schema-not-showing-using-dt
    - That’s the postgres side of things, you can do the same for the Ruby side alone if all you want to know/do is to interface with your ruby app. https://dba.stackexchange.com/questions/191745/set-search-path-for-postgres-in-a-rails-app
