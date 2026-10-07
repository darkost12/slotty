require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "POST /registration" do
    it "creates a user and signs them in" do
      params = { user: { email_address: "new@example.com",
                         password: "password123",
                         password_confirmation: "password123" } }

      expect { post registration_path, params: }.to change(User, :count).by(1)
      expect(response).to redirect_to(root_path)
    end

    it "re-renders the form on invalid data" do
      post registration_path, params: { user: { email_address: "", password: "x", password_confirmation: "y" } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
