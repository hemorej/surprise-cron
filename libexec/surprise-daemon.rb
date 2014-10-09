require 'surprise'

$lock = DAEMON_ROOT + "/.rufus-scheduler.lock"

DaemonKit::Application.running! do |config|

  frequency = DaemonKit.arguments.options[:frequency]
  interval = DaemonKit.arguments.options[:interval]

  surprise = Surprise.new(interval, frequency, false)
  surprise.start

  config.trap( 'INT' ) do
    puts "Exiting"
    File.delete($lock)
  end
end
