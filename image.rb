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
        getline = lambda {
          while line = f.gets.strip
            return line unless line[0, 1] == '#' || line.empty?
          end
        }
        type = getline.call
        width, height = getline.call.split(' ').map { |d| d.to_i } 
        depth = getline.call.to_i
        pixel_string = f.read
        data = pixel_string.unpack('C*')
        img = self.new(width, height)
        img.set_data(data)
      end
    rescue => ex
      puts ex
    end

    def get(x, y)
      raise StandardError, "over width" if x > @width
      raise StandardError, "over height" if x > @height
      @data.slice((x + y * @width) * 3, 3)
    end

    def set(x, y, pixel) 
      raise StandardError, "over width" if x > @width
      raise StandardError, "over height" if x > @height
      @data[(x + y * @width) * 3, 3] = pixel
    end

    def set_data(data)
      raise StandardError "over data size" unless @data.length == data.length
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
#  img = Image::PPM.new(100, 100)
  img = Image::PPM.load('test.ppm')
  img.write('sample.ppm')
end
