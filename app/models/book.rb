class Book < ActiveRecord::Base
  validates_presence_of :name, :author, :cover

  has_attached_file :cover, :path => ":class/:attachment/:id/:basename.:extension"
#  has_attached_file :cover, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :path => ":class/:attachment/:id/:basename_:styles.:extension"
  validates :cover, :attachment_presence => true
  validates_attachment_content_type :cover, :content_type => /\Aimage\/.*\Z/

  has_many :events

  before_post_process :rename_image_file

  def rename_image_file
    extension = File.extname(cover_file_name).downcase
    self.cover.instance_write(:file_name, "#{SecureRandom.hex(12)}#{extension}")
    logger.debug("=== rename to #{self.cover_file_name}")
  end
end
