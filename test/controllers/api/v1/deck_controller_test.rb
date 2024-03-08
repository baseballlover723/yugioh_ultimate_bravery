require "test_helper"

class Api::V1::DeckControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_deck_index_url
    assert_response :success
  end

  test "should get create" do
    get api_v1_deck_create_url
    assert_response :success
  end

  test "should get show" do
    get api_v1_deck_show_url
    assert_response :success
  end

  test "should get destroy" do
    get api_v1_deck_destroy_url
    assert_response :success
  end
end
