class Phone < ActiveRecord::Base
  belongs_to :client
  validates_presence_of :number
  before_save :strip_hyphens
  
  def strip_hyphens
    self.number.gsub!(/[\(\)\s-]/, "")
  end
  
  def pretty
    if self.number.length == 7
      n = self.number.split("")
      return "#{n[0]}#{n[1]}#{n[2]}-#{n[3]}#{n[4]}#{n[5]}#{n[6]}"
    elsif self.number.length == 10
      n = self.number.split("")
      return "#{n[0]}#{n[1]}#{n[2]}-#{n[3]}#{n[4]}#{n[5]}-#{n[6]}#{n[7]}#{n[8]}#{n[9]}"
    elsif self.number.length == 11
      n = self.number.split("")
      return "#{n[0]}-#{n[1]}#{n[2]}#{n[3]}-#{n[4]}#{n[5]}#{n[6]}-#{n[7]}#{n[8]}#{n[9]}#{n[10]}"
    else
      return self.number
    end
  end
end
