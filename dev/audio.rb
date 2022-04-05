# Audio information within the current system.
# Nicely wrapped into a module that can be used
# by any other script that might need to retrieve
# the information somehow.
#
# This allows for the same API to be used everywhere
# and not be dependent on the underlying tools used to
# get said data.
#
# Includes Audio for both input and output (Mic/Sound)
module Audio
  CHANNEL = 'Master'

  @GET = ""
  @SET = ""
  @SET_NO_CH = "" # Provide custom channel


  # Setup simple prebuilt commands to run amixer
  # with the configured sinks and channels
  def self.setup
    sink = current_sink

    @GET = "amixer -c #{sink} get #{CHANNEL}"
    @SET = "amixer -c #{sink} set #{CHANNEL}"
    @SET_NO_CH = "amixer -c #{sink} set"
  end

  
  # Get the current volume on the currently
  # used channel, in percent.
  def self.current_volume
    mixer_data = `#{@GET}`.lines.last
    volume = mixer_data.split[3]

    return volume.delete("^0-9").to_i
  end


  # Get the currently used sink.
  # 0: for the integrated speakers and headphones plugged
  #    in through the headphone jack
  # n: bluetooth headphones seems to get a random one every time
  #    so we figure it out here
  def self.current_sink
    mixer_data = `pactl list sinks short | grep RUNNING`
    
    if mixer_data.length < 5
      return 0
    end

    return mixer_data.split.first.to_i
  end


  # Check whether or not the headphones are
  # plugged into the headphone jack
  #
  # FIXME: This doesn't work with bluetooth yet
  def self.using_headphones
    data = `pactl list sinks | grep 'Active Port'`

    return data.include? 'headphones'
  end


  # Check whether or not the volume is muted
  def self.is_muted
    data = `#{@GET}`.lines.last
    status = data.split[5].delete("^a-z")

    return status == 'off'
  end


  # Set the volume to a specific value, in percent
  def self.set_volume(to) `#{@SET} #{to}%` end


  # Increase the volume
  def self.raise(by = 10) `#{@SET} #{by}%+` end


  # Decrease the volume
  def self.lower(by = 10) `#{@SET} #{by}%-` end


  # Toggle the volume on or off
  # with the ability to optionally
  # specify what state the volume should
  # be toggled to
  def self.toggle(override = nil)
    if not override
      # If it's muted we want to do the opposite
      override = is_muted() ? :on : :off
    end

    case override
    when :on
      `#{@SET} unmute`
      `#{@SET_NO_CH} Headphone unmute`
      `#{@SET_NO_CH} Speaker unmute`
      `#{@SET_NO_CH} 'Bass Speaker' unmute`
    when :off
      `#{@SET} mute`
    end
  end
end




module Microphone
  CHANNEL = 'Capture'

  # Get and Set premade commands to run 
  # amixer on the chosen channel
  @GET = "amixer get #{CHANNEL}"
  @SET = "amixer set #{CHANNEL}"


  # Get the current volume of the currently
  # used Capture channel, in percent.
  def self.current_volume
    data = `#{@GET}`.lines.last
    volume = data.split[4]

    return volume.delete("^0-9").to_i
  end


  # Check whether or not the microphone is capturing audio
  def self.is_muted
    data = `#{@GET}`.lines.last
    status = data.split[6].delete("^a-z")

    return status == 'off'
  end


  # Set the microphone volume to
  # a specific value
  def self.set_volume(to) `#{@SET} #{to}%` end


  # Raise the microphone volume
  # by a specific amount
  def self.raise(by = 10) `#{@SET} #{by}%+` end


  # Lower the microphone volume
  # by a specific amount
  def self.lower(by = 10) `#{@SET} #{by}%-` end


  # Toggle the microphone on or off
  # with the optional ability to specify
  # exactly what state the microphone
  # should be toggled to
  def self.toggle(override = nil)
    # If no args provided just do it normaly
    if not override
      `#{@SET} toggle`
      return
    end

    case override
    when :on
      `#{@SET} cap`
    when :off  
      `#{@SET} nocap`
    end
  end
end
