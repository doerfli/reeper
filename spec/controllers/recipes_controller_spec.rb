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

      it 'pre-fills the recipe source with the imported URL' do
        get :new, flash: { ocr_data: ocr_result.id, recipe_index: 0 }

        expect(assigns(:recipe).source).to eq('https://example.com/my-recipe')
      end
    end

    context 'when OCR data originates from an image import' do
      let(:ocr_result) do
        OcrResult.create!(
          result: [{ 'title' => 'Image Recipe', 'ingredients' => ['egg'], 'steps' => ['Cook it'] }].to_json
        )
      end

      it 'leaves the recipe source blank' do
        get :new, flash: { ocr_data: ocr_result.id, recipe_index: 0 }

        expect(assigns(:recipe).source).to be_blank
      end
    end

    context 'without OCR data in flash' do
      it 'leaves the recipe source blank' do
        get :new

        expect(assigns(:recipe).source).to be_blank
      end

      it 'renders without an OcrResult' do
        get :new

        expect(response).to have_http_status(:success)
        expect(assigns(:ocrresult)).to be_nil
      end
    end

    describe 'the imported-image gallery' do
      render_views

      let(:ocr_result) do
        OcrResult.create!(result: [{ 'title' => 'Pancakes' }].to_json).tap do |result|
          2.times do |i|
            result.images.attach(
              io: File.open('spec/fixtures/test_image.jpg'),
              filename: "page#{i + 1}.jpg",
              content_type: 'image/jpeg'
            )
          end
        end
      end

      it 'renders a checked checkbox for every imported image' do
        get :new, flash: { ocr_data: ocr_result.id, recipe_index: 0 }

        checkboxes = response.body.scan(/<input type="checkbox" name="attach_ocr_image_ids\[\]"[^>]*>/)
        expect(checkboxes.count).to eq(2)
        expect(response.body).to include(I18n.t('recipes.form.import_images'))
        ocr_result.ordered_images.each do |attachment|
          expect(response.body).to match(/value="#{attachment.id}"[^>]*checked/)
        end
      end

      it 'renders no gallery for a manually entered recipe' do
        get :new

        expect(response).to have_http_status(:success)
        expect(response.body).not_to include('attach_ocr_image_ids')
      end
    end
  end

  describe 'POST #create' do
    # recipes.user_id has a foreign key, so create takes the id of a real user.
    let(:user) { FactoryBot.create(:user) }
    let(:recipe_params) { { name: 'Pancakes', ingredients: 'flour', instructions: 'mix' } }

    before { session[:userinfo] = { 'id' => user.id } }

    def build_ocr_result(image_count: 2)
      OcrResult.create!(result: [{ 'title' => 'Pancakes' }].to_json).tap do |ocr_result|
        image_count.times do |i|
          ocr_result.images.attach(
            io: File.open('spec/fixtures/test_image.jpg'),
            filename: "page#{i + 1}.jpg",
            content_type: 'image/jpeg'
          )
        end
      end
    end

    context 'with an OcrResult and no image selection params' do
      it 'attaches every imported image' do
        ocr_result = build_ocr_result

        post :create, params: { recipe: recipe_params, ocrresult_id: ocr_result.id }

        expect(Recipe.last.recipe_images.count).to eq(2)
      end
    end

    context 'with an explicit image selection' do
      it 'attaches only the selected image' do
        ocr_result = build_ocr_result
        second = ocr_result.ordered_images.second

        post :create, params: {
          recipe: recipe_params,
          ocrresult_id: ocr_result.id,
          attach_ocr_image_ids: ['', second.id.to_s]
        }

        images = Recipe.last.recipe_images
        expect(images.count).to eq(1)
        expect(images.first.blob.filename.to_s).to eq('page2.jpg')
      end

      it 'attaches nothing when every image is unchecked' do
        ocr_result = build_ocr_result

        post :create, params: {
          recipe: recipe_params,
          ocrresult_id: ocr_result.id,
          attach_ocr_image_ids: ['']
        }

        expect(Recipe.last.recipe_images.count).to eq(0)
      end

      it 'ignores an image id belonging to a different OcrResult' do
        ocr_result = build_ocr_result(image_count: 1)
        other = build_ocr_result(image_count: 1)

        post :create, params: {
          recipe: recipe_params,
          ocrresult_id: ocr_result.id,
          attach_ocr_image_ids: ['', other.ordered_images.first.id.to_s]
        }

        expect(Recipe.last.recipe_images.count).to eq(0)
      end
    end

    context 'when the recipe is invalid' do
      it 're-renders the form with the OcrResult so the images survive' do
        ocr_result = build_ocr_result

        post :create, params: {
          recipe: recipe_params.merge(name: ''),
          ocrresult_id: ocr_result.id,
          attach_ocr_image_ids: ['', ocr_result.ordered_images.first.id.to_s]
        }

        expect(response).to render_template(:new)
        expect(assigns(:ocrresult)).to eq(ocr_result)
        expect(assigns(:selected_ocr_image_ids)).to eq([ocr_result.ordered_images.first.id.to_s])
      end
    end

    context 'when entered manually, without any OCR import' do
      it 'creates the recipe with no images' do
        expect {
          post :create, params: { recipe: recipe_params }
        }.to change(Recipe, :count).by(1)

        expect(Recipe.last.recipe_images.count).to eq(0)
      end

      it 're-renders the form when invalid' do
        post :create, params: { recipe: recipe_params.merge(name: '') }

        expect(response).to render_template(:new)
        expect(assigns(:ocrresult)).to be_nil
      end
    end
  end
end
