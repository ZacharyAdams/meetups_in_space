class Meetup < ActiveRecord::Base
  has_many :usermeetups
  has_many :users, through: :usermeetups
  validates :name, presence: true
  validates :location, presence: true
end


