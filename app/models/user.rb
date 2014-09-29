class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
  					:first_name, :last_name, :phone, :role, :avatar, :organization_id,
            :time_unit_id, :class_of, :title
  # attr_accessible :title, :body

  belongs_to :organization
  belongs_to :time_unit

  has_many :user_classes, dependent: :destroy
  has_many :user_expectations, dependent: :destroy
  has_many :relationships, dependent: :destroy
  has_many :user_tests, dependent: :destroy
  has_many :user_extracurricular_activities, dependent: :destroy
  has_many :user_extracurricular_activity_details, dependent: :destroy
  has_many :user_service_organizations, dependent: :destroy
  has_many :user_service_hours, dependent: :destroy
  has_many :parent_guardian_contacts, dependent: :destroy
  has_many :user_milestones, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :user_assignments, dependent: :destroy
  has_many :user_gpas, dependent: :destroy

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

  def role_name
    index = Constants.UserRole.values.index self.role.to_i
    Constants.UserRole.keys[index].to_s.capitalize
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

class UserQuerier < Querier
  def initialize
    super(User)
  end

  def filter_attributes(attributes)
    if attributes.include?(:avatar) then attributes -= [:avatar]
      attributes << :avatar_file_name
    end
    return super(attributes)
  end

  def generate_domain
    super
    # Set default_url for :avatar_file_name if :avatar_file_name is nil
    @domain.each do |d|
      if d.keys.include?(:avatar_file_name) and d[:avatar_file_name].nil?
        d[:avatar_file_name] = Paperclip::Attachment.default_options[:default_url]
      end
    end
    return @domain
  end

  def generate_view(conditions = {})
    super(conditions)
    # Rename :avatar_file_name to :square_avatar_url
    @view.each do |v|
      if v.keys.include?(:avatar_file_name)
        v[:square_avatar_url] = v.delete(:avatar_file_name)
      end
    end
    return @view
  end


end


class ViewUser2

  def initialize(options = {})

    user = options[:user]
    unless user.nil?
      @id = user.id unless !user.has_attribute?(:id)
      @email = user.email unless !user.has_attribute?(:email)
      @first_name = user.first_name unless !user.has_attribute?(:first_name)
      @last_name = user.last_name unless !user.has_attribute?(:last_name)
      @full_name = user.full_name unless !user.has_attribute?(:full_name)
      @first_last_initial = user.first_last_initial unless !user.has_attribute?(:first_last_initial)
      @title = user.title unless !user.has_attribute?(:title)
      @phone = user.phone unless !user.has_attribute?(:phone)
      @role = user.role unless !user.has_attribute?(:role)
      @organization_id = user.organization_id unless !user.has_attribute?(:organization_id)
      @square_avatar_url = user.avatar.url(:square) unless !user.has_attribute?(:avatar_file_name)
      @time_unit_id = user.time_unit_id unless !user.has_attribute?(:time_unit_id)
      @class_of = user.class_of.to_i unless !user.has_attribute?(:class_of)
      @login_count = user.sign_in_count unless !user.has_attribute?(:sign_in_count)
      @last_login = user.current_sign_in_at ? user.current_sign_in_at.strftime("%m/%d/%Y") : "Has not logged in yet" unless !user.has_attribute?(:current_sign_in_at)

      @is_student = user.student? unless !user.has_attribute?(:role)
      @is_mentor = user.mentor? unless !user.has_attribute?(:role)
      @is_org_admin = user.org_admin? unless !user.has_attribute?(:role)
      @is_super_admin = user.super_admin? unless !user.has_attribute?(:role)
    end

    @organization_name = options[:organization].name unless options[:organization].nil?
    @relationships = options[:relationships] unless options[:relationships].nil?
    @user_expectations = options[:user_expectations] unless options[:user_expectations].nil?
    @user_milestones = options[:user_milestones] unless options[:user_milestones].nil?
    @user_classes = options[:user_classes] unless options[:user_classes].nil?
    @user_service_hours = options[:user_service_hours] unless options[:user_service_hours].nil?
    @user_extracurricular_activity_details = options[:user_extracurricular_activity_details] unless options[:user_extracurricular_activity_details].nil?
    @user_tests = options[:user_tests] unless options[:user_tests].nil?
    @assignments = options[:assignments] unless options[:assignments].nil?
    @user_assignments = options[:user_assignments] unless options[:user_assignments].nil?
  end

end
