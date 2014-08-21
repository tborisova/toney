require 'rails_helper'
include ControllerMacros

RSpec.describe NotesController, :type => :controller do

  before(:all) { @user = FactoryGirl.create(:user) }
  let(:month) { double('month').as_null_object }
  let(:note) { double('note').as_null_object }
  let(:notes) { double('notes').as_null_object }
  let(:month_id) { '1' }
  let(:id) { '1' }
  let(:unauthorized_alert) { 'You are not authorized to access this page.' }
  let(:unsigned_alert) { 'You need to sign in or sign up before continuing.' }
  let(:note_params) { { title: 'phone bil', money: '12.33' } }

  context 'GET' do
    
    context 'index' do

      context 'not logged in user' do

        it 'denies access' do

          get :index, month_id: month_id

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do
        before do
          login_user @user
        end

        it 'searches for the month' do
          expect(Month).to receive(:find).with(month_id)

          get :index, month_id: month_id
        end

        it 'authorizes that user can read the month' do
          allow(Month).to receive(:find).with(month_id).and_return month

          expect(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied
          
          get :index, month_id: month_id
        end

        context 'month is found' do
          before do
            allow(Month).to receive(:find).with(month_id).and_return(month)
            allow(@ability).to receive(:authorize!).with(:show, month).and_return true
            allow(@ability).to receive(:authorize!).with(:index, month => Note).and_return true
          end

          context 'authorization is sucessful' do

            it 'authorizes that user can read month\'s notes' do
              expect(@ability).to receive(:authorize!).with(:index, month => Note).and_raise CanCan::AccessDenied

              get :index, month_id: month_id
            end

            it 'gets all month\'s notes' do
              allow(month).to receive(:notes).and_return 'notes'

              get :index, month_id: month_id
              
              expect(assigns(:notes)).to eq 'notes'
            end

            it 'renders index template' do
              get :index, month_id: month_id

              expect(response).to render_template :index
            end
          end

          context 'authorization is unsucessful' do

            it 'redirects to root url' do
              allow(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

              get :index, month_id: month_id

              expect(response).to redirect_to root_url
              expect(flash[:alert]).to eq unauthorized_alert
            end
          end
        end

        context 'month is not found' do

          it 'redirects to months index' do
            expect(Month).to receive(:find).with(month_id).and_raise ActiveRecord::RecordNotFound

            get :index, month_id: month_id

            expect(response).to redirect_to months_path
            expect(flash[:alert]).to eq 'Record not found!'
          end
        end
      end
    end

    context 'new' do
      
      context 'not logged in user' do
        
        it 'denies access' do

          get :new, month_id: month_id

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do
        before do
          login_user @user
        end

        it 'searches for the month by params' do
          
          expect(Month).to receive(:find).with(month_id)

          get :new, month_id: month_id
        end

        it 'authorizes that user can read the month' do
          allow(Month).to receive(:find).with(month_id).and_return month

          expect(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

          get :new, month_id: month_id
        end

        context 'month is not found' do

          it 'redirects to months index' do
            allow(Month).to receive(:find).with(month_id).and_raise ActiveRecord::RecordNotFound

            get :new, month_id: month_id
            
            expect(response).to redirect_to months_path
            expect(flash[:alert]).to eq 'Record not found!'
          end
        end

        context 'sucessful authorization' do

          it 'authorizes that user can create note of the month' do
            pending 'line 158'
            allow(Month).to receive(:find).with(month_id).and_return month
            allow(@ability).to receive(:authorize!).with(:show, month).and_return true

            expect(@ability).to receive(:authorize!).with(:new, Note).and_raise CanCan::AccessDenied

            get :new, month_id: month_id 
          end

          it 'renders show template' do
            allow(Month).to receive(:find).with(month_id).and_return month
            
            get :new, month_id: month_id

            expect(response).to render_template :new 
          end
        end

        context 'unsucessful authorization' do

          it 'redirects to root url' do
            allow(Month).to receive(:find).with(month_id).and_return month
            allow(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

            get :new, month_id: month_id

            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end

    context 'show' do

      context 'not logged in user' do
        
        it 'denies access' do

          get :show, month_id: month_id, id: id

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do
        
        before do
          login_user @user
        end

        it 'searches for the note\'s month' do

          expect(Month).to receive(:find).with(month_id)

          get :show, month_id: month_id, id: id
        end

        it 'authorizes that user can read the month' do
          allow(Month).to receive(:find).with(month_id).and_return month
          expect(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

          get :show, month_id: month_id, id: id
        end

        context 'month is not found' do

          it 'redirects to months index' do
            allow(Month).to receive(:find).with(month_id).and_raise ActiveRecord::RecordNotFound

            get :show, month_id: month_id, id: id
            
            expect(response).to redirect_to months_path
            expect(flash[:alert]).to eq 'Record not found!'
          end
        end

        context 'sucessful authorization' do

          it 'finds the note by params' do
            allow(Month).to receive(:find).with(month_id).and_return month
            allow(month).to receive(:notes).and_return notes
            
            expect(notes).to receive(:find).with(id)

            get :show, month_id: month_id, id: id
          end

          context 'note is not found' do

            it 'redirects to months index' do
              allow(Month).to receive(:find).with(month_id).and_return month
              allow(month).to receive(:notes).and_return notes
              allow(notes).to receive(:find).with(id).and_raise ActiveRecord::RecordNotFound
                
              get :show, month_id: month_id, id: id

              expect(response).to redirect_to months_path
              expect(flash[:alert]).to eq 'Record not found!'
            end
          end

          context 'note is found' do
            before do
              allow(Month).to receive(:find).with(month_id).and_return month
              allow(month).to receive(:notes).and_return notes
              allow(notes).to receive(:find).with(id).and_return note
            end

            it 'authorizes that user can read the note' do
              allow(@ability).to receive(:authorize!).with(:show, month).and_return true
              expect(@ability).to receive(:authorize!).with(:show, note).and_raise CanCan::AccessDenied

              get :show, month_id: month_id, id: id
            end

            it 'renders show template' do

              get :show, month_id: month_id, id: id

              expect(response).to render_template :show
            end
          end
        end

        context 'unsucessful authorization' do

          it 'redirects to root url' do
            allow(Month).to receive(:find).and_return month
            allow(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

            get :show, month_id: month_id, id: id
            
            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end

    context 'edit' do

      context 'not logged in user' do
        
        it 'denies access' do

          get :edit, month_id: month_id, id: id

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do
        
        before { login_user @user }

        it 'searches for the note\'s month' do
          expect(Month).to receive(:find).with(month_id)

          get :edit, month_id: month_id, id: id
        end

        it 'authorizes that user can read the month' do
          allow(Month).to receive(:find).with(month_id).and_return month
          expect(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

          get :edit, month_id: month_id, id: id
        end

        context 'month is not found' do

          it 'redirects to months index' do
            expect(Month).to receive(:find).with(month_id).and_raise ActiveRecord::RecordNotFound

            get :edit, month_id: month_id, id: id

            expect(response).to redirect_to months_path
            expect(flash[:alert]).to eq 'Record not found!'
          end
        end

        context 'sucessful authorization' do

          it 'finds the note by params'  do
            allow(Month).to receive(:find).with(month_id).and_return month
            allow(month).to receive(:notes).and_return notes
            expect(notes).to receive(:find).with(id)

            get :edit, month_id: month_id, id: id
          end

          context 'note is found' do
            
            before do
              allow(Month).to receive(:find).with(month_id).and_return month
              allow(month).to receive(:notes).and_return notes
              allow(notes).to receive(:find).with(id).and_return note
            end

            it 'authorizes that user can edit the note' do
              allow(@ability).to receive(:authorize!).with(:show, month).and_return true
              expect(@ability).to receive(:authorize!).with(:edit, note).and_raise CanCan::AccessDenied

              get :edit, month_id: month_id, id: id
            end

            it 'renders edit template' do

              get :edit, month_id: month_id, id: id

              expect(response).to render_template :edit
            end
          end

          context 'note is not found' do

            it 'redirects to months index' do
              allow(Month).to receive(:find).with(month_id).and_return month
              allow(month).to receive(:notes).and_return notes
              allow(notes).to receive(:find).with(id).and_raise ActiveRecord::RecordNotFound

              get :edit, month_id: month_id, id: id

              expect(response).to redirect_to months_path
              expect(flash[:alert]).to eq 'Record not found!'
            end
          end
        end

        context 'unsucessful authorization' do

          it 'redirects to root url' do
              allow(Month).to receive(:find).with(month_id).and_return month
              expect(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

              get :edit, month_id: month_id, id: id

              expect(response).to redirect_to root_url
              expect(flash[:alert]).to eq unauthorized_alert            
          end
        end
      end
    end
  end

  context 'POST' do

    def make_request
      post :create, month_id: month_id, note: note_params
    end

    context 'create' do

      context 'not logged in user' do

        it 'denies access' do

          make_request

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do

        before { login_user @user }

        it 'finds the month by params' do
          
          expect(Month).to receive(:find).with(month_id)
          
          make_request
        end

        it 'authorizes that user can read the month' do

          allow(Month).to receive(:find).and_return month
          expect(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

          make_request
        end

        context 'month is not found' do
          
          it 'redirects to months index' do
            allow(Month).to receive(:find).and_raise ActiveRecord::RecordNotFound

            make_request

            expect(response).to redirect_to months_path
            expect(flash[:alert]).to eq 'Record not found!'
          end
        end

        context 'sucessful authorization' do

          it 'authorizes that user can create Note' do

            allow(Month).to receive(:find).with(month_id).and_return month
            allow(month).to receive(:notes).and_return notes
            allow(notes).to receive(:new).with(note_params).and_return note
            allow(@ability).to  receive(:authorize!).with(:show, month)

            expect(@ability).to receive(:authorize!).with(:create, note).and_raise CanCan::AccessDenied

            make_request
          end

          it 'creates note from params to the month' do

            allow(Month).to receive(:find).with(month_id).and_return month
            allow(month).to receive(:notes).and_return notes
            expect(notes).to receive(:new).with(note_params).and_return note
            
            make_request
          end

          context 'sucessful create' do

            it 'redirects to index of notes' do

              allow(Month).to receive(:find).with(month_id).and_return month
              allow(month).to receive(:notes).and_return notes
              allow(notes).to receive(:new).with(note_params).and_return note
              allow(note).to receive(:save).and_return true

              make_request

              expect(response).to redirect_to action: :index
              expect(flash[:notice]).to eq 'Note has been created.'
            end
          end

          context 'unsucessful create' do

            it 'renders new template' do
              allow(Month).to receive(:find).with(month_id).and_return month
              allow(month).to receive(:notes).and_return notes
              allow(notes).to receive(:new).with(note_params).and_return note
              allow(note).to receive(:save).and_return false

              make_request

              expect(response).to render_template :new
              expect(flash[:alert]).to eq 'Note has not been created.'
            end
          end
        end

        context 'unsucessful authorization' do

          it 'redirects to root url' do
            allow(Month).to receive(:find).with(month_id).and_return month
            allow(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

            make_request

            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end
  end

  context 'PUT' do

    def make_request
      
      put :update, month_id: month_id, id: id, note: note_params
    end

    context 'update' do
      
      context 'not logged in user' do

        it 'denies access' do

          make_request

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do
        
        before { login_user @user }

        it 'finds the month by params' do
          expect(Month).to receive(:find).with(month_id)

          make_request
        end

        it 'authorizes that user can read the month' do
          allow(Month).to receive(:find).and_return month

          expect(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied
          
          make_request
        end

        context 'month is not found' do
          
          it 'redirects to months index' do
            
            allow(Month).to receive(:find).with(month_id).and_raise ActiveRecord::RecordNotFound

            make_request

            expect(response).to redirect_to months_path
            expect(flash[:alert]).to eq 'Record not found!'
          end

        end

        context 'sucessful authorization' do
          before do
            allow(Month).to receive(:find).and_return month
            allow(@ability).to receive(:authorize!)
          end

          it 'finds the note from params' do
            allow(month).to receive(:notes).and_return notes # in the double -> notes: notes
            expect(notes).to receive(:find).with(id).and_raise ActiveRecord::RecordNotFound

            make_request
          end
          
          it 'authorizes that user can update the note' do
            allow(month).to receive(:notes).and_return notes # in the double -> notes: notes
            allow(notes).to receive(:find).with(id).and_return note
            expect(@ability).to receive(:authorize!).with(:update, note).and_raise CanCan::AccessDenied

            make_request
          end
          
          it 'update the note with the params' do
            allow(month).to receive(:notes).and_return notes # in the double -> notes: notes
            allow(notes).to receive(:find).with(id).and_return note
            expect(note).to receive(:update).with(note_params).and_return false

            make_request
          end
          
          context 'sucessful update' do

            it 'redirects to the note' do
              pending 
              note = FactoryGirl.create(:note)
              expect(Month).to receive(:find).with(note.month_id).and_return note.month

              put :update, month_id: note.month_id, id: note.id, note: note_params

              expect(response).to redirect_to note
              expect(flash[:notice]).to eq 'Note has been updated.'
            end
          end

          context 'unsucessful update' do

            it 'renders edit template' do
              allow(month).to receive(:notes).and_return notes # in the double -> notes: notes
              allow(notes).to receive(:find).with(id).and_return note
              expect(note).to receive(:update).with(note_params).and_return false

              make_request

              expect(response).to render_template :edit
              expect(flash[:alert]).to eq 'Note has not been updated.'
            end
          end
        end

        context 'unsucessful authorization' do

          it 'redirects to root url' do
            allow(Month).to receive(:find).and_return month
            allow(@ability).to receive(:authorize!).and_raise CanCan::AccessDenied

            make_request

            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end
  end

  context 'DELETE' do

    context 'destroy' do
     
     def make_request
        
        delete :destroy, month_id: month_id, id: id
     end

     context 'not logged in user' do
        
        it 'denies access' do

          make_request

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do
        
        before { login_user @user }

        it 'searches for the note\'s month' do
          expect(Month).to receive(:find).with(month_id)

          make_request
        end

        it 'authorizes that user can read the month' do
          allow(Month).to receive(:find).with(month_id).and_return month

          expect(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied

          make_request
        end

        context 'month is not found' do

          it 'redirects to months index' do
            allow(Month).to receive(:find).with(month_id).and_raise ActiveRecord::RecordNotFound

            make_request

            expect(response).to redirect_to months_path
            expect(flash[:alert]).to eq 'Record not found!'
          end

        end

        context 'sucessful authorization' do
          before do
            allow(Month).to receive(:find).and_return month
            allow(@ability).to receive(:authorize!)
            allow(month).to receive(:notes).and_return notes
            allow(notes).to receive(:find).and_return note
          end

          it 'finds the note by params'  do
            expect(notes).to receive(:find).with(id).and_return note

            make_request
          end

          it 'authorizes that user can destroy the note' do
            expect(@ability).to receive(:authorize!).with(:destroy, note).and_raise CanCan::AccessDenied

            make_request
          end

          it 'destroys the note' do
            expect(note).to receive(:destroy)

            make_request
          end

          it 'redirects to index of notes' do
            
            make_request

            expect(response).to redirect_to action: :index
            expect(flash[:notice]).to eq 'Note has been deleted.'
          end

        end

        context 'unsucessful authorization' do

          it 'redirects to root url' do
            allow(Month).to receive(:find).and_return month
            allow(@ability).to receive(:authorize!).and_raise CanCan::AccessDenied

            make_request

            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end
  end
end
