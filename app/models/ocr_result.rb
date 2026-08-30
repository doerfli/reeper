class OcrResult < ApplicationRecord
  has_many_attached :images

  # Active Storage declares the attachments association without a default order, so sort
  # explicitly: upload order is what makes the first image the recipe's main picture.
  def ordered_images
    images.attachments.sort_by(&:id)
  end
end
