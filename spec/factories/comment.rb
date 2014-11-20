# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    user_id          -1
    title            "default_title"
    comment          "default_comment"
    commentable_type "default_type"
    commentable_id   -1
  end
end
