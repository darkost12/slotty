module Public
  class MastersController < BaseController
    def show
      @services = @master.services.active.order(:name)
    end
  end
end
