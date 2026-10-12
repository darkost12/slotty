# Pages a client opens without an account: /book/<master slug>/...
module Public
  class BaseController < ApplicationController
    allow_unauthenticated_access
    before_action :set_master

    private

    # Unknown slug → ActiveRecord::RecordNotFound → 404.
    def set_master
      @master = User.find_by!(slug: params[:slug])
    end
  end
end
