require 'rufus-scheduler'
require 'fileutils'

class Job
  def initialize
  end

  def read_config
# read some custom job configuration
  end

  def work
    puts 'Hello, I\'m working '+Time.now.to_s
  end

end
