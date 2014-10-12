require 'mail'
require 'feedjira'

class Job

  JOB_ROOT = File.expand_path(File.dirname(__FILE__))  unless defined?( JOB_ROOT )
  def initialize
  end

  def read_config
# read some custom job configuration
  end


  def greeting
    now = Time.now
    hrs = now.hour

    msg = "Mornin' Sunshine!" if (hrs >=  0)
    msg = "Good morning" if (hrs >=  6)
    msg = "Good afternoon" if (hrs >=  12)
    msg = "Good evening" if (hrs >= 17)

    msg
  end

  def work

    urls = %w[http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day?format=xml]
    feeds = Feedjira::Feed.fetch_and_parse urls
    feed = feeds['http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day?format=xml']

    begin
      message_body = File.read(JOB_ROOT + '/template.html')
      messages     = File.readlines(JOB_ROOT + '/messages')
      from_to      = Hash[*File.read(JOB_ROOT + '/from_to').split(/[, \n]+/)]
    rescue Errno::ENOENT => e
      puts e
      raise StandardError
    end

    message_body.gsub!('message_placeholder', messages.sample)
    message_body.gsub!('image_placeholder', feed.entries.first.image )
    message_body.gsub!('greeting_placeholder', greeting)

    if from_to['from'].blank? || from_to['to'].blank?
      raise StandardError.new("Email sender/recipient not properly configured")
    end

    mail = Mail.new do
      from    from_to['from']
      to      from_to['to']
      subject 'Surprise !'
      body    message_body
    end

    mail.header['Content-Type'] = 'text/html; charset=UTF-8'
    mail.deliver!
  end

end
