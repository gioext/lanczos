module Image
  class PPM
    def load(file)
      open(file, 'rb') do |f|
        @type = f.gets.strip
        @w, @h = f.gets.strip.split(' ').map { |d| d.to_i } 
        @depth = f.gets.strip.to_i
        pixel_string = f.read
        @data = pixel_string.unpack('C*')
      end
      true
    rescue => ex
      ptus ex
    end

    def get(x, y)
      @data.slice((x + y * @w) * 3, 3)
    end

    def write(file)
      open(file, 'wb') do |f|
        @data.each do |e|
          f.puts e.to_s
        end
      end
    end
  end
end
