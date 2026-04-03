class OcrResult < ApplicationRecord
  has_one_attached :image
  has_many_attached :extra_images
end
