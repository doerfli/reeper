require 'rails_helper'

RSpec.describe UrlImportController, type: :controller do
  let(:user_session) { { userinfo: { 'id' => 'test_user_123' } } }
  let(:mistral_service) { instance_double(MistralaiService) }
  let(:jina_service) { instance_double(JinaService) }
  let(:url) { 'https://example.com/my-recipe' }

  before do
    allow(controller).to receive(:logged_in_using_omniauth?).and_return(true)
    session[:userinfo] = user_session[:userinfo]

    allow(JinaService).to receive(:new).and_return(jina_service)
    allow(MistralaiService).to receive(:new).and_return(mistral_service)
    allow(jina_service).to receive(:fetch_markdown).and_return('# Recipe markdown')
  end

  describe 'POST #create' do
    context 'with a single recipe response' do
      let(:single_recipe) do
        [{
          'title' => 'Test Recipe',
          'ingredients' => ['flour', 'sugar'],
          'steps' => ['Mix ingredients', 'Bake']
        }]
      end

      before do
        allow(mistral_service).to receive(:parse_url_to_recipes).and_return(single_recipe)
      end

      it 'stores the imported URL as source_url on the OcrResult' do
        post :create, params: { url: url }

        ocrresult = OcrResult.last
        expect(ocrresult.source_url).to eq(url)
      end

      it 'redirects to the new recipe path with OCR data in flash' do
        post :create, params: { url: url }

        expect(response).to redirect_to(new_recipe_path)
        expect(flash[:ocr_data]).to be_present
        expect(flash[:recipe_index]).to eq(0)
      end
    end

    context 'with a multiple recipe response' do
      let(:multiple_recipes) do
        [
          { 'title' => 'Recipe 1' },
          { 'title' => 'Recipe 2' }
        ]
      end

      before do
        allow(mistral_service).to receive(:parse_url_to_recipes).and_return(multiple_recipes)
      end

      it 'still stores source_url and redirects to the recipe selection page' do
        post :create, params: { url: url }

        ocrresult = OcrResult.last
        expect(ocrresult.source_url).to eq(url)
        expect(response).to redirect_to(select_recipe_ocr_path(ocrresult.id))
      end
    end

    context 'with an invalid URL' do
      it 'redirects back with an alert and does not create an OcrResult' do
        expect {
          post :create, params: { url: 'not-a-url' }
        }.not_to change(OcrResult, :count)

        expect(response).to redirect_to(new_url_recipes_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'when markdown fetch fails' do
      before do
        allow(jina_service).to receive(:fetch_markdown).and_return('')
      end

      it 'redirects back with an alert and does not create an OcrResult' do
        expect {
          post :create, params: { url: url }
        }.not_to change(OcrResult, :count)

        expect(response).to redirect_to(new_url_recipes_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'when no recipes are extracted' do
      before do
        allow(mistral_service).to receive(:parse_url_to_recipes).and_return([])
      end

      it 'redirects back with an alert and does not create an OcrResult' do
        expect {
          post :create, params: { url: url }
        }.not_to change(OcrResult, :count)

        expect(response).to redirect_to(new_url_recipes_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
