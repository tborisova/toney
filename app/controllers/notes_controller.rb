class NotesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :month
  load_and_authorize_resource :note, :through => :month

  rescue_from Mongoid::Errors::DocumentNotFound do |exception|
    redirect_to months_url, :alert => 'Record not found!'
  end
  
  def index
    @notes = @month.notes
  end

  def new
  end

  def show
  end

  def edit
  end

  def create
    if @note.save
      flash[:notice] = "Note has been created."
      redirect_to action: :index
    else
      flash[:alert] = "Note has not been created."
      render "new"
    end
  end

  def update
    if @note.update(note_params)
      flash[:notice] = "Note has been updated."
      redirect_to [@month, @note]
    else
      flash[:alert] = "Note has not been updated."
      render action: "edit"
    end
  end

  def destroy
    @note.destroy
    flash[:notice] = "Note has been deleted."
    
    redirect_to action: :index
  end

  private

    def note_params
      params.require(:note).permit(:title, :money)
    end
end
