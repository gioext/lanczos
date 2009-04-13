require 'rubygems'
require 'spec'

require 'image.rb'

describe Image::PPM do
  before :each do
    @img = Image::PPM.new(100, 200)
  end

  it "width" do
    @img.width.should == 100
  end

  it "height" do
    @img.height.should == 200
  end

  it "get pixel" do
    @img.get(10, 10).should == [255, 255, 255]
    lambda { @img.get(101, 10) }.should raise_error
    lambda { @img.get(100, 201) }.should raise_error
  end

  it "set pixel" do
    @img.set(10, 10, [1, 2, 3])
    @img.get(10, 10).should == [1, 2, 3]

    lambda { @img.set(101, 10, [1, 2, 3]) }.should raise_error
    lambda { @img.set(101, 10, [1, 2, 3]) }.should raise_error
  end

  it "load ppm" do
    @img = Image::PPM.load('test.ppm')
    @img.width.should == 77
    @img.height.should == 59
    @img.data.length.should == 77 * 59 * 3
  end

  it "save ppm" do
    @img.write("spec.ppm")
  end
end
