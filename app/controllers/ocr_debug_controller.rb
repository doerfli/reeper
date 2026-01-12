class OcrDebugController < ApplicationController
  include Secured

  def index
    @page_title = I18n.t('ocr_debug.title')
  end

  def upload
    file = params[:files].first

    # Call Mistral AI OCR
    markdown = mistralai_service.ocr_to_markdown(file.tempfile, file.content_type)

    # Create OcrResult and attach the image
    ocr_result = OcrResult.create(result: markdown)
    ocr_result.image.attach(file)
    ocr_result.save

    # Return JSON with redirect to show page
    render json: { success: true, redirect_url: ocr_debug_path(ocr_result.id) }
  end

  def show
    @ocr_result = OcrResult.find(params[:id])
    render plain: @ocr_result.result
  end

  private

  def mistralai_service
    @mistralai_service ||= MistralaiService.new
  end
end
