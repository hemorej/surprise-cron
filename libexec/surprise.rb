class Surprise

  attr_reader :failed_jobs, :failure_threshold, :frequency_start, :interval_start, :interval_end, :block, :interval, :frequency
  VERSION = '0.1'

  def initialize(interval, frequency, check = true)
    if check
      opts = {:interval => interval, :frequency=> frequency}
      Surprise.validate_arguments(opts)
    end

    @interval = interval
    @frequency = frequency
    @block = interval/frequency

    @failed_jobs = 0
    @failure_threshold = 10

    @count = 0
    reset_frequency
    @first = Time.at(rand(@interval_start..@interval_end))

  end 

  def self.version
    VERSION
  end 

  def self.validate_arguments(opts={})
    mandatory = [:frequency, :interval]
    missing = mandatory.select{ |param| opts[param].nil? }
    unless missing.empty?
      raise OptionParser::MissingArgument, " #{missing.join(', ')}"
    end

    interval = opts[:interval]
    frequency = opts[:frequency]

    if(interval < 1 || frequency < 1)
      raise OptionParser::InvalidOption, 'Numbers too small'
    end

    if( interval/frequency < 1)
      raise OptionParser::InvalidOption, 'Numbers too small'
    end
  end


  def reset_frequency(frequency_offset = 0)
    @frequency_start = Time.now + frequency_offset
    @interval_start  = @frequency_start
    @interval_end    = @interval_start + @block
  end


  def start

    @scheduler = Rufus::Scheduler.new(:lockfile =>  $lock)

    @scheduler.every '1d', :first_at => @first, :overlap => false do |job|
      if @count < @frequency
        begin
          handler = Job.new
          handler.work
          @count = @count + 1
        rescue StandardError => error
          puts "Error occurred while executing job"
          puts error
          failed_jobs = failed_jobs + 1
          DaemonKit::Application.stop if failed_jobs >= failure_threshold
        end
      end

      elapsed = (Time.now - @frequency_start).to_i
      if @count >= @frequency || elapsed >= @interval
        @count = 0
        reset_frequency(@interval % elapsed)
        job.next_time = @frequency_start

      else
        @interval_start = @interval_start + @block
        @interval_end = @interval_start + @block
        job.next_time = Time.at(rand(@interval_start..@interval_end))

      end
    end

    @scheduler.join
  end

  def stop
    File.delete($lock)
    @scheduler.shutdown
  end

end


