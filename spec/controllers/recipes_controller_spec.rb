require 'rails_helper'

RSpec.describe RecipesController, type: :controller do
  let(:user_session) { { userinfo: { 'id' => 'test_user_123' } } }

  before do
    allow(controller).to receive(:logged_in_using_omniauth?).and_return(true)
    session[:userinfo] = user_session[:userinfo]
  end

  describe 'GET #new' do
    context 'when OCR data originates from a URL import' do
      let(:ocr_result) do
        OcrResult.create!(
          result: [{ 'title' => 'URL Recipe', 'ingredients' => ['egg'], 'steps' => ['Cook it'] }].to_json,
          source_url: 'https://example.com/my-recipe'
        )
      end

      before do
        request.flash[:ocr_data] = ocr_result.id
        request.flash[:recipe_index] = 0
      end

      it 'pre-fills the recipe source with the imported URL' do
        get :new

        expect(assigns(:recipe).source).to eq('https://example.com/my-recipe')
      end
    end

    context 'when OCR data originates from an image import' do
      let(:ocr_result) do
        OcrResult.create!(
          result: [{ 'title' => 'Image Recipe', 'ingredients' => ['egg'], 'steps' => ['Cook it'] }].to_json
        )
      end

      before do
        request.flash[:ocr_data] = ocr_result.id
        request.flash[:recipe_index] = 0
      end

      it 'leaves the recipe source blank' do
        get :new

        expect(assigns(:recipe).source).to be_blank
      end
    end

    context 'without OCR data in flash' do
      it 'leaves the recipe source blank' do
        get :new

        expect(assigns(:recipe).source).to be_blank
      end
    end
  end
end
