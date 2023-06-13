require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  self.use_transactional_tests = true

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { user: { email: 'test@example.com' } } }

      it 'creates a new user' do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns status :created' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns the created user as JSON' do
        post :create, params: valid_params
        created_user = User.last
        expect(JSON.parse(response.body)['email']).to eq(created_user.email)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { user: { email: '' } } }

      it 'does not create a new user' do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)
      end

      it 'returns status :unprocessable_entity' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the user errors as JSON' do
        post :create, params: invalid_params
        expect(JSON.parse(response.body)).to be_present
      end
    end
  end
end
