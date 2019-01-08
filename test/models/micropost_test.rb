require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    # This code is not idiomatically correct.
    @micropost = @user.microposts.build(content: "hello")
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "micropost's content should not be empty" do
    @micropost.content = "  "
    assert_not @micropost.valid?
  end

  test "micropost should not be longer than 140 characters" do
    @micropost.content = "a"*141
    assert_not @micropost.valid?


    test "posts should be most recent first" do
      assert_equal microposts(:most_recent), Micropost.first
    end
  end
end