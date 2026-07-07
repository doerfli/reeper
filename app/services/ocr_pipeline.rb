class OcrPipeline
  PAGE_BREAK_MARKER = "\n\n---\n**[NEW SCANNED PAGE]**\n---\n\n"

  # files_with_types is an array of [tempfile, content_type] pairs.
  def extract_recipes(files_with_types, ai_method)
    case ai_method
    when 'mistral_only'
      mistral_service.parse_markdown_to_recipes(combined_ocr_markdown(files_with_types))
    when 'mistral_openai'
      openai_service.parse_markdown_to_recipes(combined_ocr_markdown(files_with_types))
    else
      openai_service.ocr_multi(files_with_types)
    end
  end

  private

  # Runs Mistral OCR on each image in turn, then joins the resulting markdown
  # pages into one document (separated by PAGE_BREAK_MARKER) for a single parse step.
  def combined_ocr_markdown(files_with_types)
    markdowns = files_with_types.each_with_index.map do |(tempfile, content_type), index|
      markdown = mistral_service.ocr_to_markdown(tempfile, content_type)
      raise "Mistral OCR returned empty markdown for image #{index + 1}" if markdown.blank?

      markdown
    end

    markdowns.join(PAGE_BREAK_MARKER)
  end

  def openai_service
    @openai_service ||= OpenaiService.new
  end

  def mistral_service
    @mistral_service ||= MistralaiService.new
  end
end
