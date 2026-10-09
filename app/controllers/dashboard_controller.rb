class DashboardController < ApplicationController
  def show
    @services = Current.user.services.active.order(:name)
  end
end
