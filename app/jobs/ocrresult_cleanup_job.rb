class OcrresultCleanupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    logger.info "Starting OCR result cleanup job with args: #{args.inspect}"
    old_results = OcrResult.where('created_at < ?', 1.day.ago)
    # Process the results (e.g., delete them)
    deleted = old_results.destroy_all
    logger.info "Deleted #{deleted.size} old OCR results"
  end

end
