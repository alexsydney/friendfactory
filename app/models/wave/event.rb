class Wave::Event < Wave::Base
  
  extend Forwardable

  attr_accessible :promoter_name, :description, :start_date, :end_date, :user_id

  def_delegators :event_info, :start_date, :start_date=, :end_date, :end_date=

  acts_as_taggable

  acts_as_slugable :source_column => :description, :slug_column => :slug

  has_many :profiles, :through => :invitations

  after_save do |event|
    event.event_info.save
    wave = Wave::Base.find_by_slug(Wave::CommunitiesController::DefaultWaveSlug)
    if wave
      posting = Posting::WaveProxy.new(:user_id => event.user_id)
      posting.resource = event
      posting.save    
      wave.postings << posting
    end
    true
  end

  def promoter_name=(name)
    self.topic = name
  end
  
  def promoter_name
    self.topic
  end
  
  def event_info
    self.resource ||= Resource::Event.new
  end
  
end
