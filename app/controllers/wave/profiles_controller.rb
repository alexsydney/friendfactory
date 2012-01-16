class Wave::ProfilesController < ApplicationController

  extend ActiveSupport::Memoizable

  before_filter :require_user

  helper_method :wave, :postings, :profile
  helper_method :page_title

  layout 'wave/community'

  cattr_reader :per_page

  def index
    @@per_page = 102
    @waves = find_profiles_tagged_with(params[:tag]) || find_all_profiles
    @tags = tag_counts_for_current_site
    respond_to do |format|
      format.html
    end
  end

  def show
    @@per_page = 50
    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'headshot', :locals => { :personage => wave.user }
        else
          render
        end
      end
    end
  end

  # === Panes ===

  def signals
    @wave = Wave::Profile.find_by_id(params[:id])
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  def biometrics
    @wave = Wave::Profile.find_by_id(params[:id])
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def photos
    @wave = Wave::Profile.find_by_id(params[:id])
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  def invitations
    if @wave = Wave::Profile.find_by_id(params[:id])
      @invitations = @wave.postings.type(Posting::Invitation).order('created_at asc').limit(Wave::InvitationsHelper::MaximumDefaultImages)
    end
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  def conversation
    @legacy = params[:legacy]
    if receiver = Wave::Profile.find_by_id(params[:id]).try(:user)
      @wave = current_user.find_or_create_conversation_with(receiver, current_site).mark_as_read
    end
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def pokes
    if @profile = Wave::Profile.find(params[:id])
      @avatars = @profile.inverse_friends.
          type(Friendship::Poke).
          includes(:persona => :avatar).
          order('`friendships`.`created_at` desc').
          limit(9).
          map { |p| p.persona.avatar }
    end
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  def location
    profile = Wave::Base.find(params[:id])
    @personage = profile.user
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  private

  def find_profiles_tagged_with(tag)
    return unless tag.present?
    Wave::Profile.tagged_with(scrubbed_tag(tag), :on => current_site).
        where(:state => :published).
        order('updated_at desc').
        paginate(:page => params[:page], :per_page => @@per_page)
  end

  def find_all_profiles
    current_site.waves.
        type(Wave::Profile).
        where(:state => :published).
        order('updated_at desc').
        paginate(:page => params[:page], :per_page => @@per_page)
  end

  def tag_counts_for_current_site
    Wave::Profile.tag_counts_on(current_site).order('name asc')
  end

  def scrubbed_tag(tag)
    tag.downcase.gsub(/-/, ' ')
  end

  ###

  def wave
    # TODO Rescue from find exception
    current_site.waves.type(Wave::Profile, Wave::Ambassador, Wave::Place, Wave::Community).find(params[:id])
  end

  memoize :wave

  alias :profile :wave

  def postings
    wave.postings.published.order('updated_at desc').paginate(:page => params[:page], :per_page => @@per_page)
  end

  memoize :postings

  def page_title
    "#{current_site.display_name} - #{wave.user.handle}"
  end

  memoize :page_title

end
