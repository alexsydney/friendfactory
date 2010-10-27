class Posting::Message < Posting::Base

  alias_attribute :sender,    :user
  alias_attribute :sender_id, :user_id

  belongs_to :receiver, :class_name => User.class_name, :foreign_key => 'receiver_id'
  
  scope :unread, :conditions => { :read_at => nil }

  before_save { |message| message[:private] = true }

  validates_presence_of :receiver_id
  
  attr_accessible :receiver_id, :subject, :body

  def read?
    !!read_at
  end
  
  def recipient_for(user)
    [ sender, receiver ].detect{ |recipient| recipient != user }
  end

  def direction_for(user)
    sender == user ? 'from' : 'to'
  end

  def latest_reply
    leaf = self.children.last
    leaf.nil? ? self : leaf.latest_reply
  end

  def to_s
    "{ :id => #{self.id}, :sender => #{sender.to_s}, :receiver => #{receiver.to_s} :subject => '#{subject}' }"
  end
  
  private
  
  def reply_subject(subject = nil)
    subject || self.subject && self.subject !~ /^Re:\s/ ? 'Re: ' + self.subject : self.subject
  end
      
end
