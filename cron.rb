require 'rufus-scheduler'
require './lib.rb'
require './job.rb'

def load_validate_options
  validate_options(load_options)
end

def validate_options(options)
  mandatory_parameters = ["timespan", "frequency"]
  mandatory_parameters.each do | param |
    if !options.has_key? param || options[param].empty?
      puts "Missing mandatory parameters " + param.to_s
      exit 22
    end
  end

  timespan  = Integer(options["timespan"]) rescue nil
  frequency = Integer(options["frequency"]) rescue nil

  if(timespan.nil? || frequency.nil? || timespan < 1 || frequency < 1)
    puts "Invalid parameters, use numbers"
    exit 22
  end

  block = (timespan/frequency)
  if(block < 1)
    exit 22
  end

  return timespan, frequency, block
end

def load_options
  begin
    load_json('options.json')
  rescue IOError => e
    puts "Could not read options"
    exit 22
  end
end

def reset_frequency(frequency_offset = 0)
  $frequency_start = Time.now + frequency_offset
  $interval_start  = $frequency_start
  $interval_end    = $interval_start + $block
end

trap "SIGINT" do
  puts "Exiting"
# save state
  exit 130
end





scheduler = Rufus::Scheduler.new(:lockfile =>  ".rufus-scheduler.lock")

$timespan, $frequency, $block = load_validate_options
count = 0
reset_frequency
puts "FS " + $frequency_start.to_s
puts "IS " + $interval_start.to_s
puts "IE " + $interval_end.to_s
first = Time.at(rand($interval_start..$interval_end))

scheduler.every '1d', :first_at => first, :overlap => false do |job|
  if count < $frequency
    begin
      handler = Job.new
      handler.work
      count = count + 1
    rescue StandardError => error
      puts "Error occurred while executing job"
#      what to do, reschedule ? keep going ?
#      log(e.message, "ERROR")
    end
  end

  elapsed = (Time.now - $frequency_start).to_i
  if count >= $frequency || elapsed >= $timespan
    count = 0
    reset_frequency($timespan % elapsed)
    job.next_time = $frequency_start

  else
    $interval_start = $interval_start + $block
    $interval_end = $interval_start + $block
    job.next_time = Time.at(rand($interval_start..$interval_end))

  end
end

scheduler.join
