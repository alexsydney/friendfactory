class Posting::Avatar < Posting::Base

  has_attached_file :image,
      :styles => {
          :h480      => [ 'x480',     :png ],
          :iphone    => [ '320x480#', :png ],
          :portrait  => [ '200x280#', :png ],
          :ad        => [ '300x250#', :png ],
          :square    => [ '100x100#', :png ]},
      :default_style => :portrait
  
  validates_attachment_presence     :image
  validates_attachment_size         :image, :less_than => 5.megabytes
  validates_attachment_content_type :image, :content_type => [ 'image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png' ]

end
