module Posting::PostingsHelper

  DateName = Struct.new(:date, :day_name)

  def profile_avatar_image_tag(profile, opts)
    if avatar = profile.avatar
      html = image_tag(avatar.image.url(opts.delete(:style)), opts.merge(:site => false))
      block_given? ? yield(html) : html
    end
  end
  
  def avatar_image_tag(user_or_avatar, opts = {})
    if user_or_avatar.is_a?(Hash)
      opts = user_or_avatar
      user_or_avatar = nil
    end
    
    opts.reverse_merge!(
        :online_badge    => true,
        :style           => :polaroid,
        :site            => false,
        :anonymous       => true,
        :link_to_profile => true)    
    
    if opts[:style].to_sym == :thimble
      opts[:style], opts[:class] = :thumb, [ 'thimble', opts[:class] ].compact.join(' ')
    end

    klass = [ 'avatar', opts[:style], opts[:class] ]
        
    if user_or_avatar.present?
      user, avatar = user_or_avatar.is_a?(User) ?
          [ user_or_avatar, user_or_avatar.profile(current_site).avatar ] :
          [ user_or_avatar.user, user_or_avatar ]

      if user.present? && avatar.present?
        opts.reverse_merge!(:alt => user.handle(current_site))
        online = 'online' if (user.online? && (opts[:online_badge] == true))
        klass = (klass << online).compact * ' '
        
        image_tag = image_tag(avatar.url(opts[:style].to_sym),
            :alt   => opts[:alt],
            :class => klass,
            :site  => opts[:site],
            :id    => opts[:id],
            :title => user.handle(current_site))
        
        if opts[:link_to_profile]
          return link_to(image_tag, wave_profile_path(user.profile(current_site)), :class => 'profile')
        else
          return image_tag
        end
      end
    end

    # user_or_avatar not present
    
    if opts[:anonymous] == true
      klass = (klass << 'silhouette').compact * ' '
      with_options :class => klass, :site => false, :id => opts[:id] do |options|
        # case opts[:gender]
        # when UserInfo::GuyGender
        #   then options.image_tag 'friskyfactory/silhouette-guy.gif'
        # when UserInfo::GirlGender
        #   then options.image_tag 'friskyfactory/silhouette-girl.gif'
        # else
        #   options.image_tag 'friskyfactory/silhouette-q.gif'
        # end
        options.image_tag 'friskyfactory/silhouette-q.gif'
      end      
    end
  end
  
  def render_posting(posting)
    posting_type = posting.class.name.demodulize.tableize
    render :partial => File.join('posting', posting_type, posting_type.singularize), :object => posting
  end
  
  def day_names_from_today
    today = Date.today
    1.upto(6).inject([]) do |memo, num|
      date = today + num.days
      memo << DateName.new(date, date.strftime("%A"))
    end
  end

  def sticky_until_tag
    "Sticky&nbsp;until&nbsp;#{select_tag(:sticky_until, options_from_collection_for_select(day_names_from_today, :date, :day_name), :include_blank => true)}".html_safe
  end

  def spinner_tag
    image_tag('spinner-vertical.gif', :style => 'visibility:hidden', :class => 'spinner', :alt => 'Working...')
  end

  def posted_distance_of_time(posting)
    content_tag(:span, :class => 'date') do
      prefix = posting.updated_at == posting.created_at ? 'Posted' : 'Updated'
      "#{prefix} #{distance_of_time_in_words_to_now(posting.updated_at)} ago"
    end
  end

end
