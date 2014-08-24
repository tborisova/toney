class MonthsController < ApplicationController
  before_action :authenticate_user!  
  load_and_authorize_resource

  rescue_from Mongoid::Errors::DocumentNotFound do |exception|
    flash[:alert] = 'Month not found!'
    redirect_to months_url
  end

  def index
  end

  def new
  end

  def show
  end

  def edit
  end

  def update
    if @month.update(month_params)
      flash[:notice] = 'Month updated!'
      redirect_to @month    
    else
      flash[:alert] = 'Month not updated!'
      render 'edit'
    end
  end

  def create
    @month.user = current_user
    if @month.save
      flash[:notice] = 'Month successfully created!'
      redirect_to @month
    else
      flash[:alert] = 'Month is not created!'
      render 'new'
    end
  end

  def destroy
    @month.destroy
    flash[:notice] = 'Month destroyed!'

    redirect_to action: :index
  end

  private

  def month_params
    params.require(:month).permit(:start, :end, :money)
  end
end
