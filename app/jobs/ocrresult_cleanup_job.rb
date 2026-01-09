class OcrresultCleanupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    log.info "Starting OCR result cleanup job with args}"
    old_results = OcrResult.where('created_at < ?', 3.days.ago)
    # Process the results (e.g., delete them)
    old_results.destroy_all
    log.info "Deleted #{old_results.size} old OCR results"
  end

end
