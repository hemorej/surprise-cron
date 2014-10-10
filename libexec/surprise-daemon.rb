require 'surprise'

$lock = DAEMON_ROOT + "/.rufus-scheduler.lock"

DaemonKit::Application.running! do |config|

  frequency = DaemonKit.arguments.options[:frequency]
  interval = DaemonKit.arguments.options[:interval]
  
  surprise = Surprise.new(interval, frequency, false)
 
  config.trap("TERM") { surprise.stop }
  config.trap("INT")  { surprise.stop }

  surprise.start
end
