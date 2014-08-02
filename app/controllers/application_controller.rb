class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def load_month
    begin
      @month = Month.find(params[:id])
    rescue
      flash[:alert] = 'Month not found!'
      redirect_to action: :index
    end
  end
end
