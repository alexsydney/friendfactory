class Subscription::Conversation < Subscription::Base

  LastNotifiedHoursAgo = 4

  scope :notify?, lambda {
    unless super
      where('(`notified_at` IS NULL) OR (`notified_at` < ?)', LastNotifiedHoursAgo.hours.ago.utc)
    end
  }

end
