class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
  					:first_name, :last_name, :phone, :role, :avatar, :organization_id,
            :time_unit_id, :class_of
  # attr_accessible :title, :body

  belongs_to :organization
  belongs_to :time_unit

  has_many :user_classes, dependent: :destroy
  has_many :user_expectations, dependent: :destroy
  has_many :relationships, dependent: :destroy
  has_many :user_tests, dependent: :destroy
  has_many :user_extracurricular_activities, dependent: :destroy
  has_many :user_extracurricular_activity_events, dependent: :destroy
  has_many :user_service_activities, dependent: :destroy
  has_many :user_service_activity_events, dependent: :destroy
  has_many :parent_guardian_contacts, dependent: :destroy

  has_attached_file :avatar, styles: {
    square: '140x140#',
    medium: '300x300>'
  }

  # Validate the attached image is image/jpg, image/png, etc
  #validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  #validates_attachment_size :avatar, :in => 0.megabytes..2.megabytes

  validates_attachment :avatar,
    :content_type => { :content_type => /\Aimage\/.*\Z/, :message => "You must choose an image file" },
    :size => { :in => 0..2.megabytes, :message => "The file must be less than 2 megabytes in size" }

  def full_name
    return self.first_name + " " + self.last_name
  end

  def first_last_initial
    return self.first_name + " " + self.last_name[0].capitalize + "."
  end

  def super_admin?
  	return self.role.to_i == Constants.UserRole[:SUPER_ADMIN]
  end

  def org_admin?
    return self.role.to_i == Constants.UserRole[:ORG_ADMIN]
  end

  def mentor?
    return self.role.to_i == Constants.UserRole[:MENTOR]
  end

  def student?
    return self.role.to_i == Constants.UserRole[:STUDENT]
  end

  def abilities
    @abilities ||= begin
                     abilities = Six.new
                     abilities << Ability
                     abilities
                   end
  end

  def can? action, subject
    abilities.allowed?(self, action, subject)
  end
end
