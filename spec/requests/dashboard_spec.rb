require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /" do
    it "redirects guests to the sign-in page" do
      get root_path

      expect(response).to redirect_to(new_session_path)
    end

    it "shows the dashboard to signed-in users" do
      user = create(:user, password: "password123")
      sign_in(user, password: "password123")

      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
