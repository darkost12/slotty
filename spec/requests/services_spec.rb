require "rails_helper"

RSpec.describe "Services", type: :request do
  let(:user) { create(:user) }
  let(:valid_params) { { service: { name: "Haircut", duration_minutes: 45, price: 30 } } }
  let(:invalid_params) { { service: { name: "", duration_minutes: 0, price: -1 } } }

  context "when signed out" do
    it "redirects GET /services to sign in" do
      get services_path

      expect(response).to redirect_to(new_session_path)
    end

    it "does not create a service" do
      expect { post services_path, params: valid_params }.not_to change(Service, :count)

      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signed in" do
    before { sign_in(user) }

    describe "GET /services" do
      it "lists only the current user's services" do
        create(:service, user: user, name: "My haircut")
        create(:service, name: "Other user massage")

        get services_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("My haircut")
        expect(response.body).not_to include("Other user massage")
      end
    end

    describe "GET /services/new" do
      it "renders the form" do
        get new_service_path

        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /services" do
      it "creates a service owned by the current user" do
        expect { post services_path, params: valid_params }
          .to change(user.services, :count).by(1)

        expect(response).to redirect_to(services_path)
        expect(user.services.last).to have_attributes(name: "Haircut", duration_minutes: 45, price: 30)
      end

      it "ignores a user_id passed in params" do
        other_user = create(:user)
        params = { service: valid_params[:service].merge(user_id: other_user.id) }

        post services_path, params: params

        expect(other_user.services).to be_empty
        expect(user.services.count).to eq(1)
      end

      it "re-renders the form with 422 on invalid data" do
        expect { post services_path, params: invalid_params }.not_to change(Service, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "GET /services/:id/edit" do
      it "renders the form for an own service" do
        service = create(:service, user: user)

        get edit_service_path(service)

        expect(response).to have_http_status(:ok)
      end
    end

    describe "PATCH /services/:id" do
      let(:service) { create(:service, user: user, name: "Old name") }

      before { service }

      it "updates an own service" do
        patch service_path(service), params: { service: { name: "New name" } }

        expect(response).to redirect_to(services_path)
        expect(service.reload.name).to eq("New name")
      end

      it "re-renders the form with 422 on invalid data" do
        patch service_path(service), params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        expect(service.reload.name).to eq("Old name")
      end
    end

    describe "DELETE /services/:id" do
      it "destroys an own service" do
        service = create(:service, user: user)

        expect { delete service_path(service) }.to change(Service, :count).by(-1)

        expect(response).to redirect_to(services_path)
      end
    end

    context "with another user's service" do
      let(:other_service) { create(:service, name: "Not yours") }

      before { other_service }

      it "returns 404 on edit" do
        get edit_service_path(other_service)

        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 on update and leaves the service unchanged" do
        patch service_path(other_service), params: { service: { name: "Hacked" } }

        expect(response).to have_http_status(:not_found)
        expect(other_service.reload.name).to eq("Not yours")
      end

      it "returns 404 on destroy and keeps the service" do
        expect { delete service_path(other_service) }.not_to change(Service, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
