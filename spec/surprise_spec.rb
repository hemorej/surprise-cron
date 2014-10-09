require File.dirname(__FILE__) + '/spec_helper.rb'

describe Surprise do

#interval, frequency

  before :each do
  end

  after :each do
  end

  describe 'arguments' do

    it 'shows version' do 
      expect(Surprise.version).to match(/\d+/)
    end
 
    it 'refuses empty parameters' do
      expect{
        Surprise.new(nil, nil)
      }.to raise_error(OptionParser::MissingArgument)
    end
    
    it 'checks mandatory parameters' do
      expect{
        Surprise.new(nil, 10)
      }.to raise_error(OptionParser::MissingArgument)
      
      expect{
        Surprise.new(4, nil)
      }.to raise_error(OptionParser::MissingArgument)
    end

    it 'checks block value' do
      expect{
	Surprise.new(4, 10) #block too small, multiple jobs per second
      }.to raise_error(OptionParser::InvalidOption)
    end

    it 'checks invalid options' do
      expect{
	Surprise.new(4, -4)
      }.to raise_error(OptionParser::InvalidOption)

      expect{
	Surprise.new('abc', 4)
      }.to raise_error(ArgumentError)

      expect{
	Surprise.new(0, 4)
      }.to raise_error(OptionParser::InvalidOption)
    end

    it 'accepts valid options' do
      surprise = Surprise.new(10, 2)
      expect(surprise.interval).to eq(10)
      expect(surprise.frequency).to eq(2)
    end
  end
end
