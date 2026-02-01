require "test_helper"

class Admin::TimeSlotsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_time_slots_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_time_slots_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_time_slots_edit_url
    assert_response :success
  end
end
