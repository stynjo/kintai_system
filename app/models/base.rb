class Base < ApplicationRecord
  validates :name, presence: true
  validates :type, presence: true
  validates :number, presence: true
  self.inheritance_column = :_type_disabled
end
