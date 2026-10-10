require "rails_helper"

RSpec.describe "Availability rules", type: :request do
  let(:user) { create(:user) }
  let(:valid_params) { { availability_rule: { weekday: "monday", start_time: "10:00", end_time: "14:00" } } }

  context "when signed out" do
    it "redirects to sign in" do
      get availability_rules_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signed in" do
    before { sign_in(user) }

    describe "GET /availability_rules" do
      it "shows only the current user's intervals" do
        create(:availability_rule, user: user, weekday: :monday, start_time: "09:15", end_time: "11:45")
        create(:availability_rule, user: create(:user), weekday: :monday, start_time: "17:20", end_time: "18:40")

        get availability_rules_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("09:15")
        expect(response.body).not_to include("17:20")
      end
    end

    describe "POST /availability_rules" do
      it "creates an interval for the current user" do
        expect { post availability_rules_path, params: valid_params }
          .to change(user.availability_rules, :count).by(1)

        expect(response).to redirect_to(availability_rules_path)
      end

      it "returns 422 when the interval overlaps an existing one" do
        create(:availability_rule, user: user, weekday: :monday, start_time: "12:00", end_time: "16:00")

        expect { post availability_rules_path, params: valid_params }.not_to change(AvailabilityRule, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns 422 when end time is before start time" do
        params = { availability_rule: { weekday: "monday", start_time: "14:00", end_time: "10:00" } }

        expect { post availability_rules_path, params: params }.not_to change(AvailabilityRule, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "DELETE /availability_rules/:id" do
      it "removes an own interval" do
        rule = create(:availability_rule, user: user)

        expect { delete availability_rule_path(rule) }.to change(AvailabilityRule, :count).by(-1)

        expect(response).to redirect_to(availability_rules_path)
      end

      it "returns 404 for another user's interval and keeps it" do
        other_user = create(:user)
        rule = create(:availability_rule, user: other_user)

        expect { delete availability_rule_path(rule) }.not_to change(AvailabilityRule, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
