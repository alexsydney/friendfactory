class Posting::WaveProxy < Posting::Base
  belongs_to :resource, :class_name => 'Wave::Base', :foreign_key => 'resource_id'
end