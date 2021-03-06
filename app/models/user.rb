class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  has_many :listings, dependent: :destroy
  has_many :orders, dependent: :destroy

  #------------------------------------------------------
  # Make sure that the email exists and is unique in 
  # the database.
  #------------------------------------------------------
  validates_presence_of :email
  validates_uniqueness_of :email
end
