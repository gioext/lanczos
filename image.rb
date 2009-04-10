module Image
  class PPM
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
      @data = Array.new(width * height * 3)
      @data.fill(255)
    end

    def self.load(file)
      open(file, 'rb') do |f|
        type = f.gets.strip
        width, height = f.gets.strip.split(' ').map { |d| d.to_i } 
        depth = f.gets.strip.to_i
        pixel_string = f.read
        data = pixel_string.unpack('C*')
        img = self.new(width, height)
        img.set_data(data)
      end
    rescue => ex
      ptus ex
    end

    def get(x, y)
      @data.slice((x + y * @width) * 3, 3)
    end

    def set(x, y, pixel) 
      @data[(x + y * @width) * 3, 3] = pixel
    end

    def set_data(data)
      @data = data
      self
    end

    def write(file)
      open(file, 'wb') do |f|
        f.printf("P6\n")
        f.printf("%d %d\n", @width, @height)
        f.printf("%d\n", 255)
        @data.each do |e|
          f.putc(e)
        end
      end
    end
  end
end

if __FILE__ == $0
  img = Image::PPM.new(100, 100)
#  img = Image::PPM.load('test.ppm')
  img.write('sample.ppm')
end
