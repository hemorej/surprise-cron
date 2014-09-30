require 'json'

def load_json( filename )
  begin
    JSON.parse( IO.read(filename) )
  rescue Exception => e
    DaemonKit.logger.error(e.message)
    DaemonKit.logger.error(e.backtrace.inspect)
    raise IOError.new("Error reading specified file")
  end
end

def write_json( hash, location )

  if location !~ /\.json$/i
    location = location + ".json"
  end

  location = sanitize_filename(location)

  File.open(location, "w") do |f|
    f.write(JSON.pretty_generate(hash))
  end
end

def sanitize_filename(filename)

  fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m
  fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }
  fn.join '.'

end


