class ReportsController < ApplicationController
  before_filter :login_required

  def index
    redirect_to '/report/time_sheet'
  end

end