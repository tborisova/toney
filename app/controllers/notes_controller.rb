class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_month, only: [:edit, :show, :update, :destroy, :new, :create, :index]
  before_action :load_note, only: [:edit, :show, :update, :destroy]

  def index
    authorize! :show, @month
    p 'HERE'
    @notes = @month.notes
  end

  def new
    authorize! :create, Note
    @note = @month.notes.build
  end

  def show
      authorize! :show, @note
  end

  def edit
      authorize! :update, @note
  end

  def create
    authorize! :create, Note
    @note = @month.notes.build(note_params)
    if @note.save
      flash[:notice] = "Note has been created."
      redirect_to [@month, @note]
    else
      flash[:alert] = "Note has not been created."
      render "new"
    end
  end

  def update
    authorize! :update, @note
    if @note.update(note_params)
      flash[:notice] = "Note has been updated."
      redirect_to [@month, @note]
    else
      flash[:alert] = "Note has not been updated."
      render action: "edit"
    end
  end

  def destroy
    authorize! :destroy, @note
    @note.destroy
    flash[:notice] = "Ticket has been deleted."
    
    redirect_to @month
  end

  private

    def note_params
      params.require(:note).permit(:title, :money)
    end
    
    def load_month
      begin
        @month = Month.find(params[:month_id])
      rescue
        flash[:alert] = 'Month not found!'
        redirect_to action: :index
      end
    end

    def load_note
      begin
        @note = @month.notes.find(params[:id])
      rescue
        flash[:alert] = 'Note not found!'
        redirect_to action: :index
      end
    end
end
