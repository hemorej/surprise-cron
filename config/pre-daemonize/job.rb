class Job

  def initialize
  end

  def read_config
# read some custom job configuration
  end

  def work
    puts "hello "+Time.now.to_s
  end

end

