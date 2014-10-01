DaemonKit::Application.running! do |config|
  config.trap( 'INT' ) do
    puts "Exiting"
    File.delete(DAEMON_ROOT + "/.rufus-scheduler.lock")
  end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
end

$lock = DAEMON_ROOT + "/.rufus-scheduler.lock"
scheduler = Rufus::Scheduler.new(:lockfile =>  $lock)

def reset_frequency(frequency_offset = 0)
  $frequency_start = Time.now + frequency_offset
  $interval_start  = $frequency_start
  $interval_end    = $interval_start + $block
end

# Run our 'cron' dameon, suspending the current thread
# DaemonKit::Cron.run

$interval = DaemonKit.arguments.options[:interval]
$frequency = DaemonKit.arguments.options[:frequency]
$block = DaemonKit.arguments.options[:block]
$count = 0
reset_frequency
first = Time.at(rand($interval_start..$interval_end))

scheduler.every '1d', :first_at => first, :overlap => false do |job|
  if $count < $frequency
    begin
      handler = Job.new
      handler.work
      $count = $count + 1
    rescue StandardError => error
      puts "Error occurred while executing job"
#      what to do, reschedule ? keep going ? count up to treshold and quit completely ?
    end
  end

  elapsed = (Time.now - $frequency_start).to_i
  if $count >= $frequency || elapsed >= $interval
    $count = 0
    reset_frequency($interval % elapsed)
    job.next_time = $frequency_start

  else
    $interval_start = $interval_start + $block
    $interval_end = $interval_start + $block
    job.next_time = Time.at(rand($interval_start..$interval_end))

  end
end

scheduler.join

