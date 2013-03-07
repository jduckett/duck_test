class Book < ActiveRecord::Base

  before_save :my_save

  def my_save
#     return false
    return true
  end

  def my_method
    return "yesz"
  end
  
end

