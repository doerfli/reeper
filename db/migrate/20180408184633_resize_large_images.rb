class ResizeLargeImages < ActiveRecord::Migration[5.2]
  def up
    Recipe.all.each{ |r|
      puts r.name
      resized_images = []
      to_delete = []
      r.recipe_images.each{ |i|
        next if i.blob.byte_size < 2000000
        # puts i.inspect
        # puts i.blob.inspect

        img = MiniMagick::Image.read(i.download)
        img.quality(60)
        tmpfile = Tempfile.new('img')
        img.write(tmpfile)
        tmpfile.close

        to_delete << i
        resized_images << {
          :filename => i.blob.filename,
          :content_type => i.blob.content_type,
          :data => tmpfile
        }
      }

      resized_images.each{ |i|
        r.recipe_images.attach({
          io: i[:data].open,
          filename: i[:filename],
          content_type: i[:content_type]
        })
        puts "attached #{i[:filename]}"
      }
      to_delete.each { |d|
        d.purge
        puts "deleted #{d.filename}"
      }
    }
  end

  def down
  end
end
