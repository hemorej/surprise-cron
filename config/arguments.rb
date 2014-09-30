require_relative 'version.rb'

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

  mandatory = [:frequency, :interval]
  missing = mandatory.select{ |param| @options[param].nil? }
  unless missing.empty?
    puts "Missing options: #{missing.join(', ')}"
    puts opts
    exit
  end

  if(@options[:frequency] < 1 || @options[:interval] < 1)
    puts "Invalid parameters, numbers too small"
    exit 22
  end

  block = (@options[:interval]/@options[:frequency])
  if(block < 1)
    puts "Invalid parameters, numbers too small"   
    exit 22
  else
    @options[:block] = block
  end

rescue OptionParser::InvalidOption, OptionParser::MissingArgument, OptionParser::InvalidArgument
   puts "Invalid Argument"
   puts opts
   exit
end
