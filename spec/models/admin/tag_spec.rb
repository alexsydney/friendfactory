require 'spec_helper'

describe Admin::Tag do

  it 'is valid with valid attributes' do
    pending
    tag = Admin::Tag.new(:taggable_type => 'UserInfo', :defective => 'crap')
    tag.should be_valid
  end

  it 'is not valid without taggable_type' do
    pending
    tag = Admin::Tag.new(:defective => 'crap')
    tag.should_not be_valid
  end

  it 'is not valid without defective' do
    pending
    tag = Admin::Tag.new(:taggable_type => 'UserInfo')
    tag.should_not be_valid
  end
  
  it 'has accessible corrected attribute' do
    pending
    tag = Admin::Tag.new(:corrected => 'correct')
    tag.corrected.should == 'correct'
  end
  
end
