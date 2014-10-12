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

  
  describe 'lockfile' do
    
    it 'creates on start, deletes on stop' do

      $surprise = Surprise.new(10, 2)
      surprise_thread = Thread.new{ $surprise.start }
      file_checker_thread = Thread.new{
       sleep(1)
       expect($surprise.running?).to be true
       daemon_path = File.expand_path("../", File.dirname(__FILE__))
       expect(File.read(daemon_path+"/.rufus-scheduler.lock")).to_not be_nil
       $surprise.stop
       expect{File.read(daemon_path+"/.rufus-scheduler.lock")}.to raise_error(Errno::ENOENT)
      } 

    surprise_thread.join
    file_checker_thread.join
    end

   it 'does not start if lockfile exists' do

      $surprise = Surprise.new(10, 2)
      $surprise_2 = Surprise.new(20, 4)

      surprise_thread = Thread.new{ $surprise.start }

      file_checker_thread = Thread.new{
        sleep(1)
        expect($surprise.running?).to be true
	expect{$surprise_2.start}.to raise_error(Rufus::Scheduler::NotRunningError)

       $surprise.stop
      }

    surprise_thread.join
    file_checker_thread.join
    
    end
  end

  describe 'correctness' do
    it 'runs the specified number of times' do

      $surprise = Surprise.new(4, 3)

      surprise_thread = Thread.new{ $surprise.start }
      sleeper_thread = Thread.new{ 
	sleep(4)
	expect($surprise.runs).to be >= 3
	$surprise.stop
      }
    surprise_thread.join
    sleeper_thread.join

    end
  end
end
