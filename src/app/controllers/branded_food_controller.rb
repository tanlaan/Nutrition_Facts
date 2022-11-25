class BrandedFoodController < ApplicationController
  def show
    @food = BrandedFood.where('gtin_upc like ?', "%#{params[:id]}%")
    if @food.empty?
      render json: { error: 'Item not found in database.' }
    else
      render json: @food
    end
  end
end