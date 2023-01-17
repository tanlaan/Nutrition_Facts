# frozen_string_literal: true

require 'test_helper'

# Tests for the Branded Food Controller
class BrandedFoodControllerTest < ActionDispatch::IntegrationTest
  # We probably don't care to differentiate if it's just:
  # - Unique sub-sequence
  # - GTIN that wasn't found
  # - It's over length
  # This test should cover those cases
  test 'should return error when given more than 13 characters' do
    get '/upc/12345678901234'
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'Item not found in database.', json_response['error']
    # assert_select 'error', 'Item not found in database.'
    # expect_response.to be_success
    # expect(JSON['error']).to eq("Item not found in database.")
    # assert true
  end
  test 'should return successfully and with more than 1 object' do
    print 'Add test data before this actually works.'
    assert false

    # We need to actually add an item to the test database otherwise
    # it we can't test a matching barcode -- derp
    #
    # Crunch masters UPC: 879890001431
    get '/upc/0000000000000'
    # get '/upc/879890001431'
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal true, json_response['error'].nil?
  end
end
