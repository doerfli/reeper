require 'rails_helper'

RSpec.describe OcrController, type: :controller do
  let(:user_session) { { userinfo: { 'id' => 'test_user_123' } } }
  let(:openai_service) { instance_double(OpenaiService) }

  before do
    # Mock authentication
    allow(controller).to receive(:logged_in_using_omniauth?).and_return(true)
    session[:userinfo] = user_session[:userinfo]

    # Mock OpenAI service
    allow(OpenaiService).to receive(:new).and_return(openai_service)
  end

  describe 'POST #scan' do
    let(:file) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }

    context 'with single recipe response' do
      let(:single_recipe) do
        [{
          'title' => 'Test Recipe',
          'ingredients' => ['flour', 'sugar'],
          'steps' => ['Mix ingredients', 'Bake']
        }]
      end

      before do
        allow(openai_service).to receive(:ocr).and_return(single_recipe)
      end

      it 'creates OCR result and redirects to new recipe path' do
        post :scan, params: { files: [file] }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['redirect_url']).to include('recipes/new')
      end

      it 'stores OCR data in flash' do
        post :scan, params: { files: [file] }

        expect(flash[:ocr_data]).to be_present
        expect(flash[:recipe_index]).to eq(0)
      end
    end

    context 'with multiple recipes response' do
      let(:multiple_recipes) do
        [
          {
            'title' => 'Recipe 1',
            'ingredients' => ['ingredient 1'],
            'steps' => ['step 1']
          },
          {
            'title' => 'Recipe 2',
            'ingredients' => ['ingredient 2'],
            'steps' => ['step 2']
          }
        ]
      end

      before do
        allow(openai_service).to receive(:ocr).and_return(multiple_recipes)
      end

      it 'redirects to recipe selection page' do
        post :scan, params: { files: [file] }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['redirect_url']).to include('select_recipe')
      end

      it 'does not store data in flash immediately' do
        post :scan, params: { files: [file] }

        expect(flash[:ocr_data]).to be_nil
      end
    end

    context 'with OCR error' do
      before do
        allow(openai_service).to receive(:ocr).and_raise(StandardError.new('API Error'))
      end

      it 'returns error response' do
        post :scan, params: { files: [file] }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'POST #select_recipe' do
    let(:ocr_result) do
      OcrResult.create!(
        result: [
          { 'title' => 'Recipe 1' },
          { 'title' => 'Recipe 2' }
        ].to_json
      )
    end

    context 'for new recipe flow' do
      it 'stores selection in flash and redirects to new recipe' do
        post :select_recipe, params: {
          ocr_result_id: ocr_result.id,
          recipe_index: 1
        }

        expect(response).to redirect_to(new_recipe_path)
        expect(flash[:ocr_data]).to eq(ocr_result.id.to_s)
        expect(flash[:recipe_index]).to eq(1)
      end
    end

    context 'for reparse flow' do
      let(:recipe) { Recipe.create!(name: 'Existing Recipe', user_id: 'test_user') }

      it 'redirects to edit recipe path' do
        post :select_recipe, params: {
          ocr_result_id: ocr_result.id,
          recipe_index: 0,
          reparse_recipe_id: recipe.id
        }

        expect(response).to redirect_to(edit_recipe_path(recipe))
        expect(flash[:ocr_data]).to eq(ocr_result.id.to_s)
      end
    end

    context 'with invalid recipe index' do
      it 'defaults to 0 for negative index' do
        post :select_recipe, params: {
          ocr_result_id: ocr_result.id,
          recipe_index: -1
        }

        expect(flash[:recipe_index]).to eq(0)
      end
    end
  end

  describe 'GET #show_recipe_selection' do
    let(:ocr_result) do
      OcrResult.create!(
        result: [
          { 'title' => 'Recipe 1' },
          { 'title' => 'Recipe 2' }
        ].to_json
      )
    end

    it 'loads OCR result and parses recipes' do
      get :show_recipe_selection, params: { id: ocr_result.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:ocr_result)).to eq(ocr_result)
      expect(assigns(:recipes)).to be_an(Array)
      expect(assigns(:recipes).length).to eq(2)
    end

    context 'with invalid OCR result ID' do
      it 'redirects with error message' do
        get :show_recipe_selection, params: { id: 'invalid' }

        expect(response).to redirect_to(recipes_path)
        expect(flash[:error]).to be_present
      end
    end
  end
end
