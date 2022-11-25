class BrandedFood < ApplicationRecord
  self.table_name = 'branded_food'
  self.primary_key = 'fdc_id'
end