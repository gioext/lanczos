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

def filter(x)
  if x < 0
    0
  elsif x > 255
    255
  else
    x.to_i
  end
end

img = Image::PPM.load('test.ppm')

sw = img.width
sh = img.height
n = 3
scale = 2 
dw = (sw * scale).to_i
dh = (sh * scale).to_i

dist = Image::PPM.new(dw, dh)

dh.times do |h|
  dw.times do |w|
    x0 = (w + 0.5) / scale
    y0 = (h + 0.5) / scale

    x_range = ((x0 - n).to_i..(x0 + n).to_i).reject { |d| d < 0 || d >= sw }
    y_range = ((y0 - n).to_i..(y0 + n).to_i).reject { |d| d < 0 || d >= sh }
    r = g = b = 0
    weight_total = 0
    y_range.each do |y|
      x_range.each do |x|
        pix = img.get(x, y)
        xl = ((x + 0.5) - x0).abs
        yl = ((y + 0.5) - y0).abs
        weight = lanczos(xl, n) * lanczos(yl, n)
        r += pix[0] * weight
        g += pix[1] * weight
        b += pix[2] * weight
        weight_total += weight
      end
    end
    if weight_total != 0.0
      r /= weight_total
      g /= weight_total
      b /= weight_total
    end
    r = filter(r)
    g = filter(g)
    b = filter(b)

    dist.set(w, h, [r, g, b]);
  end
end

dist.write('sample.ppm')
