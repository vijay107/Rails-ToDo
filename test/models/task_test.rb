require "test_helper"

class TaskTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "visiting the index" do
    visit tasks_url
    assert_selector "h1", text: "Task Names"
  end
end
