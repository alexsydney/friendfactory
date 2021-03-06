class Personage < ActiveRecord::Base

  include ActiveRecord::Transitions

  self.inheritance_column = nil

  attr_accessible \
      :user_attributes,
      :persona_attributes,
      :default

  delegate \
      :site,
      :email,
      :admin?,
      :gid,
      :current_login_at,
      :last_login_at,
      :online?,
      :offline?,
    :to => :user

  delegate \
      :handle,
      :display_handle,
      :first_name,
      :last_name,
      :dob,
      :age,
      :description,
      :location,
      :avatar,
      :avatar?,
      :tag_list,
      :location_list,
      :biometric_list,
      :featured?,
      :subscribe!,
      :unsubscribe!,
    :to => :persona

  state_machine do
    state :enabled
    state :disabled

    event :disable do
      transitions :to => :disabled, :from => [ :enabled ]
    end

    event :enable do
      transitions :to => :enabled, :from => [ :disabled ]
    end
  end

  def default=(bool)
    if self[:default] = bool
      self[:state] = :enabled
    end
  end

  belongs_to :user, :autosave => true

  alias :user_record :user

  belongs_to :persona,
      :class_name => 'Persona::Base',
      :autosave   => true

  scope :site, lambda { |site|
      joins(:user).
      where(:users => { :site_id => site.id })
  }

  scope :user, lambda { |user|
      where(:user_id => user.id)
  }

  scope :type, lambda { |*types|
      joins(:persona).
      merge(Persona::Base.type(*types))
  }

  scope :wave, lambda { |wave|
      select('distinct "personages".*').
      joins(:postings => :waves).
      joins(:persona).
      where(:postings => { :waves => { :id => wave.id }}).
      merge(Posting::Base.published).
      merge(Persona::Base.has_avatar)
  }

  scope :homeable, lambda { |site|
      type(:ambassador, :place, :community).
      enabled.
      site(site).
      joins(:user).
      merge(User.enabled)
  }

  scope :enabled, where(:state => :enabled)

  scope :exclude, lambda { |*ids|
      where('"personages"."id" NOT IN (?)', ids)
  }

  scope :sidebar_rollcall, lambda { |site, persona_type, limit, *exclude_ids|
      enabled.
      site(site).
      type(persona_type).
      joins(:profile).
      includes(:persona => :avatar).
      exclude(*exclude_ids).
      where('"personas"."avatar_id" IS NOT NULL').
      limit(limit).
      order('"postings"."updated_at" DESC')
  }

  def self.uid(id)
    "uid_#{id}" if id
  end

  def uid
    Personage.uid(id)
  end

  ### Avatar

  def publish_avatar_to_profile_wave
    avatar = persona.avatar_without_silhouette
    if avatar && avatar.unpublished?
      avatar.publish!
      profile.postings << avatar
      avatar
    end
  end

  def create_and_publish_avatar_to_profile_wave(attrs)
    avatar = persona.build_avatar(attrs)
    if persona.save
      avatar.publish!
      profile.postings << avatar
    end
    avatar
  end

  ### User Record

  accepts_nested_attributes_for :user

  ### Persona

  accepts_nested_attributes_for :persona

  def persona_attributes=(attrs)
    if persona.nil?
      type = attrs.delete(:type)
      klass = type.constantize
      self.persona = klass.new(attrs)
    elsif persona[:id] == attrs.delete('id').to_i
      persona.update_attributes(attrs)
    end
  end

  def persona_type
    if persona
      persona[:type].demodulize.downcase
    end
  end

  def display_name
    [ persona_type.try(:titleize), handle ].compact.join(' ')
  end

  ### Profile

  belongs_to :profile, :class_name => 'Wave::Base', :autosave => true

  alias_method :profile_without_initialized_user=, :profile=

  def profile=(profile)
    profile.user = self if profile
    self.profile_without_initialized_user = profile
  end

  after_create :create_profile_wave

  private

  def create_profile_wave
    if persona && profile.nil?
      wave = persona.default_profile_type.constantize.published.new
      wave.sites.push(site)
      update_attribute(:profile, wave)
    end
  end

  ### Friendships

  public

  has_many :friendships,
      :foreign_key => "user_id",
      :class_name  => "Friendship::Base"

  has_many :friends, :through => :friendships do
    def type(*types)
      where(:friendships => { :type => types.map(&:to_s) })
    end
  end

  has_many :inverse_friendships,
      :foreign_key => "friend_id",
      :class_name  => "Friendship::Base"

  has_many :inverse_friends,
      :through => :inverse_friendships,
      :source  => :user do
    def type(*types)
      where(:friendships => { :type => types.map(&:to_s) })
    end
  end

  alias :admirers :inverse_friends

  def toggle_poke(personage)
    if personage[:id] == self[:id]
      nil
    elsif poke = friendships.type(Friendship::Poke).find_by_friend_id(personage[:id])
      poke.destroy
      nil
    elsif poke = Friendship::Poke.new(:friend => personage)
      friendships << poke
      poke
    end
  end

  def has_friended?(personage_id, type)
    friendships.type(type).find_by_friend_id(personage_id).present?
  end

  def has_poked?(personage_id)
    has_friended?(personage_id, ::Friendship::Poke)
  end

  ### Waves

  public

  has_many :bookmarks

  has_many :waves,
      :class_name  => 'Wave::Base',
      :foreign_key => 'user_id'

  ### Conversations

  has_many :conversations, class_name: "Wave::Conversation", foreign_key: "user_id"

  def find_or_create_conversation_with receiver, site = nil
    if receiver != self
      conversation = conversations.recipient(receiver).first
      conversation = create_conversation_with receiver, site unless conversation
      conversation
    end
  end

  def create_conversation_with(receiver, site)
    if receiver && site
      wave = conversations.build
      wave.resource = receiver
      site.waves << wave
      wave.publish!
      wave
    end
  end

  private :create_conversation_with

  def inbox(site)
    conversations.site(site).chatty.published
  end

  ### Postings

  has_many :postings,
      :class_name  => 'Posting::Base',
      :foreign_key => 'user_id'

  has_many :publications, :through => :postings

  ###

  has_many :subscriptions,
      :class_name  => 'Subscription::Base',
      :foreign_key => 'user_id'

  ### Invitations

  has_many :invitations,
      :foreign_key => 'user_id',
      :class_name  => 'Invitation::Base'

  has_one :invitation_confirmation,
      :foreign_key => 'invitee_id',
      :class_name  => 'Invitation::Confirmation'

  # @invitations = personage.profile.postings.type(Posting::Invitation).order('"postings"."created_at" DESC').limit(Wave::InvitationsHelper::MaximumDefaultImages)

  def find_or_create_invitation_wave_for_site(site)
    invitation_wave_for_site(site) || create_invitation_wave_for_site(site)
  end

  def find_invitation_wave_by_id(id)
    waves.type(Wave::Invitation).published.find_by_id(id)
  end

  def invitation_wave_for_site(site)
    waves.site(site).type(Wave::Invitation).published.limit(1).try(:first)
  end

  private

  def create_invitation_wave_for_site(site)
    wave = Wave::Invitation.new.tap { |wave| wave.user = self }
    site.waves << wave && wave.publish!
    wave.reload
  end

  ### Photos Wave

  public

  has_one :photos_wave,
      :class_name  => 'Wave::Photo',
      :foreign_key => 'user_id'

  def find_or_create_photos_wave
    if photos_wave.nil?
      create_photos_wave
      photos_wave.publish!
    end
    photos_wave
  end

  ### Emailable

  def emailable?
    if persona && user_record
      self.enabled? && user_record.enabled? && persona.emailable?
    end
  end

end
