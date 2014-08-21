require 'rails_helper'
include ControllerMacros

RSpec.describe MonthsController, :type => :controller do

  before(:all) { @user = FactoryGirl.create(:user) }
  let(:month) { double('month').as_null_object }
  let(:id) { '1' }
  let(:unauthorized_alert) { 'You are not authorized to access this page.' }
  let(:unsigned_alert) { 'You need to sign in or sign up before continuing.' }
  let(:month_params) { { start: 'start', end: 'end', money: '12.33' } }

  context 'GET' do
    
    context 'index' do
      
      context 'not logged in user' do

        it 'denies access' do
        
          get :index

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do
        
        before { login_user @user }
  
        it 'gets all his months' do
          expect(Month).to receive(:accessible_by).with(@ability, :index).and_return 'months'

          get :index

          expect(assigns(:months)).to eq 'months'
        end

        it 'renders index template' do

          get :index

          expect(response).to render_template :index
        end  
      end
    end

    context 'new' do

      context 'not logged in users' do
        
        it 'denies access' do
        
          get :new
        
          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in users' do
        
        before { login_user @user }

        it 'makes new month' do

          get :new
          
          expect(assigns(:month)).to be_new_record
        end

        it 'authorizes that user can create a month' do
          expect(@ability).to receive(:authorize!).with(:new, Month)

          get :new
        end

        context 'sucessful authorization' do
          
          it 'render new template' do
          
            get :new

            expect(response).to render_template :new
          end
        end

        context 'unsucessful authorization' do

          it 'redirects to root url' do
            expect(@ability).to receive(:authorize!).and_raise CanCan::AccessDenied

            get :new
            
            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end

    context 'show' do

      context 'not logged in user' do
         it 'denies access' do
        
          get :show, id: id
        
          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end    
      end

      context 'logged in user' do
        before do
          login_user @user
          allow(Month).to receive(:find).with(id).and_return month
        end

        it 'gets month by id' do
          get :show, id: id

          expect(assigns(:month)).to eq month
        end

        it 'authorizes that user can read the month' do
          expect(@ability).to receive(:authorize!).with(:show, month)
          
          get :show, id: id
        end

        context 'month is not found' do
          
          it 'redirects to index action' do
            allow(Month).to receive(:find).with(id).and_raise ActiveRecord::RecordNotFound

            get :show, id: id

            expect(response).to redirect_to action: :index
            expect(flash[:alert]).to eq 'Month not found!'
          end
        end

        context 'sucessful authorization' do
          it 'renders show template' do
            expect(@ability).to receive(:authorize!).with(:show, month).and_return true
            
            get :show, id: id

            expect(response).to render_template :show
          end
        end

        context 'unsucessful authorization' do

          it 'redirects to root url' do
            expect(@ability).to receive(:authorize!).with(:show, month).and_raise CanCan::AccessDenied
            
            get :show, id: id

            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end

    context 'edit' do

      context 'not logged in user' do
         it 'denies access' do
        
          get :edit, id: id
        
          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq 'You need to sign in or sign up before continuing.'
        end    
      end

      context 'logged in user' do
        before do
          login_user @user
          allow(Month).to receive(:find).with(id).and_return month
        end

        it 'gets month by id' do
          
          get :edit, id: id

          expect(assigns(:month)).to eq month
        end

        it 'authorizes that user can edit the month' do
          expect(@ability).to receive(:authorize!).with(:edit, month)

          get :edit, id: id
        end

        context 'month is not found' do
          
          it 'redirects to index action' do
            allow(Month).to receive(:find).with(id).and_raise ActiveRecord::RecordNotFound

            get :edit, id: id

            expect(response).to redirect_to action: :index
            expect(flash[:alert]).to eq 'Month not found!'
          end
        end

        context 'sucessful authorization' do

          it 'renders edit template' do
            expect(@ability).to receive(:authorize!).with(:edit, month).and_return true

            get :edit, id: id

            expect(response).to render_template 'edit'
          end
        end

        context  'unsucessful authorization' do

          it 'redirects to root url' do

            expect(@ability).to receive(:authorize!).with(:edit, month).and_raise CanCan::AccessDenied

            get :edit, id: id

            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end
  end

  context 'POST' do

    context 'create' do

      context 'not logged in user' do

        it 'denies access' do

          post :create, month: {}

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do
        before { login_user @user }

        it 'instances month object from params' do
          expect(Month).to receive(:new).with(month_params).and_return month
          allow(month).to receive(:save).and_return false
          
          post :create, month: month_params
        end

        it 'authorizes that user can create month' do
          allow(Month).to receive(:new).with(month_params).and_return month
          allow(month).to receive(:save).and_return false
          expect(@ability).to receive(:authorize!).with(:create, month).and_return true
          
          post :create, month: month_params
        end

        context 'sucessful authorization' do
          
          it 'saves the month' do
            allow(Month).to receive(:new).with(month_params).and_return month
            expect(month).to receive(:save).and_return false
              
            post :create, month: month_params
          end

          it 'assigns current user to the month\'s user' do
            allow(Month).to receive(:new).with(month_params).and_return month
            expect(month).to receive(:user=).with(@user)
            allow(month).to receive(:save).and_return false

            post :create, month: month_params
          end

          context 'sucessful save' do
            
            it 'redirects to the new month' do
              month = FactoryGirl.build(:month)

              allow(Month).to receive(:new).with(month_params).and_return month
              
              post :create, month: month_params

              expect(flash[:notice]).to eq 'Month successfully created!'
              expect(response).to redirect_to month
            end
          end

          context 'unsucessful save' do

            it 'renders new template' do

              allow(Month).to receive(:new).with(month_params).and_return month
              expect(month).to receive(:save).and_return false

              post :create, month: month_params

              expect(flash[:alert]).to eq 'Month is not created!'
              expect(response).to render_template 'new'
            end
          end
        end

        context 'unsucessful authorization' do

          it 'redirects to root url' do

            expect(@ability).to receive(:authorize!).with(:create, Month).and_raise CanCan::AccessDenied

            post :create, month: month_params

            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end
  end

  context 'PUT' do
    
    context 'update' do

      context 'not logged in user' do

        it 'denies access' do

          put :update, month: {}, id: id

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do

        before do
          login_user @user
        end

        it 'finds month object by params' do

          expect(Month).to receive(:find).with(id).and_raise ActiveRecord::RecordNotFound

          put :update, month: month_params, id: id
        end

        it 'authorizes that user can update the month' do

          allow(Month).to receive(:find).with(id).and_return month
          expect(@ability).to receive(:authorize!).with(:update, month).and_raise CanCan::AccessDenied

          put :update, month: month_params, id: id
        end

        context 'month is not found' do
          
          it 'redirects to index action' do
            allow(Month).to receive(:find).with(id).and_raise ActiveRecord::RecordNotFound

            put :update, month: month_params, id: id

            expect(response).to redirect_to action: :index
            expect(flash[:alert]).to eq 'Month not found!'
          end
        end

        context 'sucessful authorization' do

          it 'updates the month by params' do
            
            allow(Month).to receive(:find).with(id).and_return month
            expect(month).to receive(:update).with(month_params).and_return false

            put :update, month: month_params, id: id
          end

          context 'sucessful update' do

            it 'redirects to the month' do
              month = FactoryGirl.create(:month)
              allow(Month).to receive(:find).with(id).and_return month
              allow(month).to receive(:update).and_return true

              put :update, month: month_params, id: id

              expect(flash[:notice]).to eq 'Month updated!'
              expect(response).to redirect_to month
            end
          end

          context 'unsucessful update' do

            it 'renders edit template' do
              allow(Month).to receive(:find).with(id).and_return month
              allow(month).to receive(:update).and_return false

              put :update, month: month_params, id: id

              expect(response).to render_template :edit
              expect(flash[:alert]).to eq 'Month not updated!'
            end
          end 
        end

        context 'unsucessful authorization' do

          it 'redirects to root_url' do
            allow(Month).to receive(:find).with(id).and_return month
            expect(@ability).to receive(:authorize!).with(:update, month).and_raise CanCan::AccessDenied

            put :update, month: month_params, id: id

            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end
  end

  context 'DELETE' do

    context 'destroy' do

      context 'not logged in user' do

        it 'denies access' do
          
          delete :destroy, id: id

          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq unsigned_alert
        end
      end

      context 'logged in user' do
        
        before do
          login_user @user
        end

        it 'finds the month by id' do

          expect(Month).to receive(:find).with(id).and_return month

          delete :destroy, id: id
        end

        it 'authorizes that user can delete the month' do
          allow(Month).to receive(:find).with(id).and_return month

          expect(@ability).to receive(:authorize!).with(:destroy, month)

          delete :destroy, id: id
        end

        context 'month not found' do

          it 'redirects to index action' do
            allow(Month).to receive(:find).with(id).and_raise ActiveRecord::RecordNotFound

            delete :destroy, id: id

            expect(response).to redirect_to action: :index
            expect(flash[:alert]).to eq 'Month not found!'
          end
        end

        context 'sucessful authorization' do

          it 'destroy the month' do
            allow(Month).to receive(:find).with(id).and_return month

            expect(month).to receive(:destroy)

            delete :destroy, id: id
          end

          it 'redirects to the index action' do

            allow(Month).to receive(:find).with(id).and_return month

            delete :destroy, id: id

            expect(response).to redirect_to action: :index
            expect(flash[:notice]).to eq 'Month destroyed!'
          end
        end

        context 'unsucessful authorization' do

          it 'redirects to root_url' do
            allow(Month).to receive(:find).with(id).and_return month
            allow(@ability).to receive(:authorize!).with(:destroy, month).and_raise CanCan::AccessDenied

            delete :destroy, id: id

            expect(response).to redirect_to root_url
            expect(flash[:alert]).to eq unauthorized_alert
          end
        end
      end
    end
  end
end