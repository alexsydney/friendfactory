module ApplicationHelper

  attr_reader :current_layout
  
  def form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    super(record_or_name_or_array, *(args << options.merge(:builder => ButtonFormBuilder)), &proc)    
  end

  def remote_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    super(record_or_name_or_array, *(args << options.merge(:builder => ButtonFormBuilder)), &proc)    
  end
  
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end
  
  def stylesheet(*files)
    files.map! { |file| File.join(current_site.name, file) }
    content_for(:head) { stylesheet_link_tag(*files) }
  end
  
  def image_tag(source, opts = {})    
    source = File.join(current_site.name, source) unless opts.delete(:site) == false
    super(source, opts)
  end
  
  def fixed_container
    content_for(:current_container, 'container_16_fixed')
    content_for(:head, stylesheet_link_tag(File.join('960gs', 'fixed'), :media => 'screen'))
  end

  def button_tag(text = nil, opts = {})
    content_tag(:button, text, opts)
  end
  
  def button_tag_if(boolean, text = nil, opts = {})
    button_tag(text, opts) if boolean
  end
  
  def spinner(opts = {})
    size = case opts[:size]
      when :small then '14x14'
      when :big   then '32x32'
      else '14x14'
    end    
    image_tag('ajax-loader.gif', :size => size, :class => 'spinner', :id => 'spinner', :style => 'display:none')
  end
  
  def link_to_profile(user, opts = {})
    name = opts[:label] || user.full_name
    link_to(name, profile_path(user.profile), :class => 'profile') if user.profile
  end
  
  def portrait_image_tag(user_or_avatar, opts = {})
    avatar_image_tag(user_or_avatar, opts.merge(:size => 'portrait'))
  end
  
  def thumb_image_tag(user_or_avatar, opts = {})
    avatar_image_tag(user_or_avatar, opts.merge(:size => 'thumb'))
  end

  def avatar_image_tag(user_or_avatar, opts = {})    
    user, avatar = if user_or_avatar.present? && user_or_avatar.is_a?(User)
      [ user_or_avatar, user_or_avatar.profile.avatar ]
    else
      [ user_or_avatar.user, user_or_avatar ]
    end
    return '&nbsp;' unless user.present? && avatar.present?
    online = 'online' if (user.online? && !(opts[:online_badge] == false))
    klass  = [ 'avatar', opts[:size], online, opts[:class] ].compact * ' '
    link_to(image_tag(avatar.image.url(opts[:size].to_sym), :alt => user.full_name, :class => klass, :site => false), profile_path(user))
  end      
  
  def distance_of_time_in_words_to_now(date, opts = {})
    suffix = opts[:suffix] || 'ago'
    prefix = opts[:prefix]
    content_tag(:span, :class => 'distance_of_time') do
      returning String.new do |html|
        html << "#{prefix}&nbsp;"
        html << super(date)
        html << "&nbsp;#{suffix}"
      end
    end
  end
  
  def link_to_facebook
    link_to('', 'http://www.facebook.com/pages/Frisky-Hands/297300376633', :target => 'blank', :class => 'web_logos facebook')
  end
    
end
