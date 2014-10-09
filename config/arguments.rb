require File.dirname(__FILE__) + '/../libexec/surprise'

opts.on('-n', '--number NUMBER', Integer, 'how many times it should run') do |freq|
 @options[:frequency] = freq
end

opts.on('-t', '--time INTERVAL', Integer, 'the unit time for the frequency, in seconds') do |interval|
 @options[:interval] = interval
end

opts.on_tail('-h', '--help', 'display this message') do
  puts opts
  exit
end

opts.on_tail('-v', '--version', 'show version') do
  puts Surprise.version
  exit
end


begin
  opts.parse(ARGV)

  Surprise.validate_arguments(@options)

rescue OptionParser::InvalidOption, OptionParser::MissingArgument, OptionParser::InvalidArgument => e
   puts e.message unless e.message.nil?
   puts opts
   exit
end
