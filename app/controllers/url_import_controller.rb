class UrlImportController < ApplicationController
  include Secured

  def create
    url = params[:url].to_s.strip

    unless valid_url?(url)
      flash[:alert] = I18n.t('url_import.errors.invalid_url')
      redirect_to new_url_recipes_path and return
    end

    ai_method = params[:ai_method].presence || 'mistral_url'

    begin
      markdown = jina_service.fetch_markdown(url)

      if markdown.blank?
        flash[:alert] = I18n.t('url_import.errors.fetch_failed')
        redirect_to new_url_recipes_path and return
      end

      if ai_method == 'openai_url'
        magic_data_json = openai_service.parse_url_to_recipes(markdown)
        used_ai_method = 'jina_openai'
      else
        magic_data_json = mistral_service.parse_url_to_recipes(markdown)
        used_ai_method = 'jina_mistral'
      end

      if magic_data_json.empty?
        flash[:alert] = I18n.t('url_import.errors.no_recipes')
        redirect_to new_url_recipes_path and return
      end

      ocrresult = OcrResult.create(result: magic_data_json.to_json, ai_method: used_ai_method)

      if magic_data_json.length > 1
        redirect_to select_recipe_ocr_path(ocrresult.id)
      else
        flash[:ocr_data] = ocrresult.id
        flash[:recipe_index] = 0
        redirect_to new_recipe_path
      end
    rescue => e
      logger.error "URL import error: #{e.message}"
      flash[:alert] = I18n.t('url_import.errors.processing_failed')
      redirect_to new_url_recipes_path
    end
  end

  private

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end

  def jina_service
    @jina_service ||= JinaService.new
  end

  def openai_service
    @openai_service ||= OpenaiService.new
  end

  def mistral_service
    @mistral_service ||= MistralaiService.new
  end
end
