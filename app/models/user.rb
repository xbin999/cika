class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_uniqueness_of :name, :email

  has_attached_file :avatar, :path => ":class/:attachment/:id/:basename.:extension"
  validates :avatar, :attachment_presence => false
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :events

  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :genres

  before_post_process :rename_image_file

  def rename_image_file
    extension = File.extname(avatar_file_name).downcase
    self.avatar.instance_write(:file_name, "#{SecureRandom.hex(12)}#{extension}")
  end
end
