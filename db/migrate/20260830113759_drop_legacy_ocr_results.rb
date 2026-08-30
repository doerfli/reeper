class DropLegacyOcrResults < ActiveRecord::Migration[8.1]
  def up
    # OcrResult#image / #extra_images were merged into a single #images association.
    # OcrResult is a transient staging record wiped daily by OcrresultCleanupJob, so rather
    # than renaming the attachment rows we drop whatever is in flight.
    #
    # Purge the old-format attachments explicitly: the model now only declares `images`, so
    # destroying the records would not know about these and would orphan the blobs (and
    # their S3 objects). purge (not purge_later) keeps this independent of Sidekiq.
    #
    # Blobs shared with another record are safe: the reparse flow attaches a recipe's own
    # blob to an OcrResult, and the active_storage_attachments -> blobs foreign key makes
    # Blob#purge raise InvalidForeignKey, which it rescues without deleting the file.
    ActiveStorage::Attachment
      .where(record_type: 'OcrResult', name: %w[image extra_images])
      .find_each(&:purge)

    OcrResult.delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
