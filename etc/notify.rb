# Wrapper around functionality used
# to send data to a notification daemom.
#
# This greatly simplifies the work a script
# needs to do just to send out a notification.
#
# Required tools to use:
# - dunstify (for sending notifications directly to the dunst daemon)
class Notification
  @message_id = 123
  
  @appname = ''
  @summary = ''
  @icon = ''
  @urgency = :low
  @hint = ''
  @replace = ''


  # Create a new notification object 
  # with a specific id.
  #
  # Id isn't required if you don't intend
  # to replace the notification.
  def initialize(id = 1234)
    @message_id = id
  end


  # Set the application name that should
  # show up in the notification
  def appname(name)
    @appname = "-a '#{name}'"
    self
  end


  # Set the contents of the notification
  def summary(text)
    @summary = "'#{text}'"
    self
  end


  # Set a notification icon
  # Dunst will probably know where to look
  # for this, otherwise just a full path
  # should do it
  def icon(name)
    @icon = "-i '#{name}'"
    self
  end


  # Set the urgency of the notifications.
  # Any urgency that dunst dupports is 
  # also supported here, only difference
  # is they're symbols that get converted
  # to strings before dunst, e.g.
  #
  # :low
  # :normal
  # :critical
  def urgency(level)
    @urgency = "-u #{level.to_s}"
    self
  end


  # Set a given hint for the notification.
  # A simple example would be to set the
  # progress percentage of the progress
  # bar inside the notification
  def hint(value)
    # We're probably going to want an array here later
    @hint = "-h '#{value}'"
    self
  end


  # Make the notification into something
  # that will replace a previous one with
  # the same ID
  def replace
    @replace = "-r '#{@message_id}'"
    self
  end


  # Send the notification
  # by running dunst and giving it all the
  # defined parameters.
  def send
    `dunstify #{@appname} #{@urgency} #{@icon} #{@replace} #{@hint} #{@summary}`
  end
end

