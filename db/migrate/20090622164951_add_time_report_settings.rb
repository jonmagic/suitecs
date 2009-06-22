class AddTimeReportSettings < ActiveRecord::Migration
  def self.up
    Setting.create(:key => "first_day_of_payroll", :value => "saturday")
    Setting.create(:key => "last_day_of_payroll", :value => "friday")
  end

  def self.down
    first_day = Setting.find(:first, :conditions => {:key => "first_day_of_payroll"})
    first_day.destroy
    last_day = Setting.find(:first, :conditions => {:key => "last_day_of_payroll"})
    last_day.destroy
  end
end
