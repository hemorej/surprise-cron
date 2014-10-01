$lock = DAEMON_ROOT + "/.rufus-scheduler.lock"
$failed_jobs = 0
$failure_threshold = 10

DaemonKit::Application.running! do |config|
  config.trap( 'INT' ) do
    puts "Exiting"
    File.delete($lock)
  end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
end

def reset_frequency(frequency_offset = 0)
  $frequency_start = Time.now + frequency_offset
  $interval_start  = $frequency_start
  $interval_end    = $interval_start + $block
end


scheduler = Rufus::Scheduler.new(:lockfile =>  $lock)

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
      $failed_jobs = $failed_jobs + 1
      DaemonKit::Application.stop if $failed_jobs >= $failure_threshold
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

