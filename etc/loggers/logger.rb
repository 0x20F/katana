module Logger
  # ----------------------------------------
  # Methods that will be available to all the
  # implementors of this interface.
  # ----------------------------------------

  # Get all the items from the log file,
  # fully parsed using the custom parsing method
  def all
    c = contents
    c ? on_read(c) : []
  end

  # Add a new entry to the existing entries
  def append(*args)
    c = contents
    
    line = on_new(args)
    items = c ? on_read(c) : []
    items = on_add(items, line)

    # If a max entry limit is defined, automatically
    # remove the earliest one.
    if items.length > max && max != 0
      items.shift
    end

    file = on_end(items)

    save(file)
  end

  # Clear the log file of all entries
  def clear
    File.open(file, 'w') do |f| f.truncate(0) end
  end



  # ----------------------------------------
  # Methods that will need to be implemented
  # by each logger.
  # ----------------------------------------

  # Define how the logger should parse
  # the given log file into an array of items
  def on_read(_contents)
    raise 'Logger has not defined how to parse the logs'
  end

  # Define how the logger should take
  # the array of items that has been created
  # and turn it back into something that can
  # be stored inside a file
  def on_end(_items)
    raise 'Logger has not defined how to rewire everything back'
  end

  # Allow the loggers to define a custom way
  # of inserting new items into the logs
  def on_add(items, line)
    items.push(line)
  end

  # Define how the logger should interpret
  # the data given when adding a new log
  def on_new(*_pieces)
    raise 'Logger has not defined how to handle new data'
  end

  # Define where the log file for a
  # specific logger is located
  def file
    raise 'No log file defined'
  end

  # Define how many lines should be allowed
  # in the log. Default (0) is unlimited
  def max
    0
  end




  # ----------------------------------------
  # Private methods that are only used within
  # the interface
  # ----------------------------------------
  private

  # Open up the defined log file and read all
  # of its contents
  def contents
    return nil unless File.exists?(file)
    entries = IO::read(file)
    entries == '' ? nil : entries
  end

  # Save new data to the original file by either
  # overwriting everything within it or appending
  # to it
  def save(new_contents, append = nil)
    flag = append ? 'a' : 'w'

    File.open(file, flag) do |file|
      file.write(new_contents)
    end
  end
end
