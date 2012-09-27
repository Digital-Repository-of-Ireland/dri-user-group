class Group < ActiveRecord::Base
  attr_accessible :name, :description
  #make name have to be unique
end
