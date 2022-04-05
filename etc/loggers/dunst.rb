require_relative 'logger'
require 'json'



class DunstLogger
  include Logger


  def file
    '/tmp/dunstlog'
  end


  def on_add(items, line)
    items.unshift(line)
  end

  
  def on_read(contents)
    json = JSON.parse(contents)
    json['notifications'] || []
  end

  
  def on_end(items)
    final = {
      :notifications => items
    }

    final.to_json
  end

  
  def on_new(pieces)
    # Replace newlines with spaces
    clean = pieces.collect do |p| p.split.join(' ') end

    hash = {
      :appname => clean[0],
      :summary => clean[1],
      :body => clean[2],
      :icon => clean[3],
      :urgency => clean[4],
      :timestamp => Time.now.strftime("%I:%M %p")
    }

    hash
  end
end
