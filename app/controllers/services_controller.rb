class ServicesController < ApplicationController
  before_action :set_service, only: %i[edit update destroy]

  def index
    @services = Current.user.services.order(:name)
  end

  def new
    @service = Current.user.services.new
  end

  def edit
  end

  def create
    @service = Current.user.services.new(service_params)

    if @service.save
      redirect_to services_path, notice: "Service was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @service.update(service_params)
      redirect_to services_path, notice: "Service was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @service.destroy!

    redirect_to services_path, notice: "Service was successfully destroyed.", status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_service
    @service = Current.user.services.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def service_params
    params.expect(service: [:name, :duration_minutes, :price, :description, :active])
  end
end
