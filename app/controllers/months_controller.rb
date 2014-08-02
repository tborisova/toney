class MonthsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_month, only: [:edit, :show, :update, :destroy]

  def index
    @months = Month.accessible_by(current_ability)
  end

  def new
    authorize! :create, Month
    @month = Month.new
  end

  def show
    authorize! :show, @month
  end

  def edit
    authorize! :update, @month
  end

  def update
    authorize! :update, @month
    if @month.update(month_params)
      flash[:notice] = 'Month updated!'
      redirect_to @month    
    else
      flash[:alert] = 'Month not updated!'
      render 'edit'
    end
  end

  def create
    authorize! :create, Month

    @month = Month.new(month_params)
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
    authorize! :destroy, @month
    @month.destroy
    flash[:notice] = 'Month destroyed!'

    redirect_to action: :index
  end

  private

  def month_params
    params.require(:month).permit(:start, :end, :money)
  end
end
