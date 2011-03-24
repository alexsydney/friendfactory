class Invitation < ActiveRecord::Base  
  validates_presence_of :code, :site_id, :sponsor_id  
  belongs_to :site
  belongs_to :sponsor, :class_name => User
end
