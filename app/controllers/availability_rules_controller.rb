class AvailabilityRulesController < ApplicationController
  def index
    @availability_rule = Current.user.availability_rules.new
    load_rules
  end

  def create
    @availability_rule = Current.user.availability_rules.new(availability_rule_params)

    if @availability_rule.save
      redirect_to availability_rules_path, notice: "Interval added."
    else
      load_rules
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    Current.user.availability_rules.find(params.expect(:id)).destroy!

    redirect_to availability_rules_path, notice: "Interval removed.", status: :see_other
  end

  private

  # A hash like { "monday" => [rule, rule], "friday" => [rule] }.
  def load_rules
    @rules_by_weekday = Current.user.availability_rules.order(:start_time).group_by(&:weekday)
  end

  def availability_rule_params
    params.expect(availability_rule: %i[weekday start_time end_time])
  end
end
