class Digit < ActiveRecord::Base
  belongs_to :user

  default_scope -> { order('created_at DESC') }

  validates :user_id, presence: true
  validates :digit_recognize, :inclusion => { :in => 0..9, :message => "The number must be simple digit." }, presence: true
  validates :digit_user_marked, :inclusion => { :in => 0..9, :message => "The number must be simple digit." }, allow_nil: true

  def correctRecognize
    digit_recognize == digit_user_marked
  end

  def url
    "digits/" + user_id.to_s + "/" + id.to_s + ".png"
  end
end
