require 'spec_helper'

describe Friendship do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :buddy_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    pending
    Friendship.create!(@valid_attributes)
  end
end
