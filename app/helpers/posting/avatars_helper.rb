module Posting::AvatarsHelper

  def thimble_link_to_profile(profile, path = nil)
    profile = profile.profile(current_site) if profile.is_a?(User)
    if profile.present?
      path = wave_profile_path(profile) if path.nil?
      link_to(thimble_image_tag(profile), path)
    end
  end

  def thimble_image_tag(user_or_profile, opts = {})
    size = opts.delete(:size) || '32x32'
    if user_or_profile.present?
      handle = user_or_profile.handle
      image_tag(user_or_profile.avatar.url(:thumb), :size => size, :alt => handle, :title => handle)
    end
  end

  def headshot_image_tag(profile, opts = {})
    opts.merge!(:size => '190x190', :alt => profile.handle, :title => profile.handle)
    image_tag(profile.avatar.url(:polaroid), opts)
  end

  def placeholder_image_tag(opts = {})
    css_class = [ 'placeholder', opts.delete(:class) ].compact * ' '
    image_tag 'friskyfactory/silhouette-q.gif', opts.merge(:site => false, :class => css_class)
  end

  def empty_image_tag(opts = {})
    css_class = [ 'empty', opts.delete(:class) ].compact * ' '
    image_tag 'ffffff.gif', opts.merge(:site => false, :class => css_class)
  end

  def empty_thumb_image_tag(opts = {})
    css_class = [ 'thumb', opts.delete(:class) ].compact.join(' ')
    empty_image_tag(:class => css_class)
  end

end
