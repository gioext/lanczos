require File.dirname(__FILE__) + '/image.rb'

def sinc(x)
  Math.sin(Math::PI * x) / (Math::PI * x)
end

def lanczos(d, n)
  d = d.to_f
  n = n.to_f

  if d == 0.0
    1.0
  elsif d.abs >= n
    0.0
  else
    sinc(d) * sinc(d/n)
  end
end

def filter(x, total)
  if total != 0.0
    x /= total
  end
  if x < 0
    0
  elsif x > 255
    255
  else
    x.to_i
  end
end

img = Image::PPM.load('sample.ppm')

sw = img.width
sh = img.height
n = 3
scale = 0.8 
dw = (sw * scale).to_i
dh = (sh * scale).to_i
db = {}

dist = Image::PPM.new(dw, dh)

dh.times do |h|
  dw.times do |w|
    r = g = b = 0

    if scale > 1
      x0 = (w + 0.5) / scale
      y0 = (h + 0.5) / scale
      x_range = ((x0 - n).to_i..(x0 + n).to_i).reject { |d| d < 0 || d >= sw }
      y_range = ((y0 - n).to_i..(y0 + n).to_i).reject { |d| d < 0 || d >= sh }
      weight_total = 0
      y_range.each do |y|
        x_range.each do |x|
          pix = img.get(x, y)
          xl = ((x + 0.5) - x0).abs
          yl = ((y + 0.5) - y0).abs
          lanczos_x = 0
          if db.has_key?(xl) 
            lanczos_x = db[xl]
          else
            lanczos_x = lanczos(xl, n)
            db[xl] = lanczos_x
          end
          lanczos_y = 0
          if db.has_key?(yl) 
            lanczos_y = db[yl]
          else
            lanczos_y = lanczos(yl, n)
            db[yl] = lanczos_y
          end
          weight = lanczos_x * lanczos_y
          r += pix[0] * weight
          g += pix[1] * weight
          b += pix[2] * weight
          weight_total += weight
        end
      end
    else
      x0 = w + 0.5
      y0 = h + 0.5

      x_bottom = ((x0 - n) / scale).to_i
      x_top = ((x0 + n) / scale).to_i
      x_range = (x_bottom..x_top).reject { |d| d < 0 || d >= sw }

      y_bottom = ((y0 - n) / scale).to_i
      y_top = ((y0 + n) / scale).to_i
      y_range = (y_bottom..y_top).reject { |d| d < 0 || d >= sh }

      weight_total = 0
      y_range.each do |y|
        x_range.each do |x|
          pix = img.get(x, y)
          xl = (((x + 0.5) * scale )- x0).abs
          yl = (((y + 0.5) * scale )- y0).abs
          lanczos_x = 0
          if db.has_key?(xl) 
            lanczos_x = db[xl]
          else
            lanczos_x = lanczos(xl, n)
            db[xl] = lanczos_x
          end
          lanczos_y = 0
          if db.has_key?(yl) 
            lanczos_y = db[yl]
          else
            lanczos_y = lanczos(yl, n)
            db[yl] = lanczos_y
          end
          weight = lanczos_x * lanczos_y
          r += pix[0] * weight
          g += pix[1] * weight
          b += pix[2] * weight
          weight_total += weight
        end
      end
    end

    r = filter(r, weight_total)
    g = filter(g, weight_total)
    b = filter(b, weight_total)
    dist.set(w, h, [r, g, b]);
  end
end
dist.write('sample2.ppm')
