$: << ENV['katana']


require 'utils'


use 'notify', 'clipboard'


# Required tools in order to use:
# - maim (for screenshots)
# - yay && checkupdates (for system updates)
module System

  # Take a screenshot of whatever is on screen
  # at this very moment, making sure to:
  #   1. add the screenshot to the clipboard
  #   2. save the image in /tmp (by default)
  #   3. show a nice notification with the saved image
  #
  def self.screenshot(path: '/tmp', delay: 0)
    sleep(delay)

    filename = "#{path}/#{string(25)}.png"

    # Take the screenshot
    `maim --format png #{filename}`

    # Add the image data to the clipboard
    data = File::open(filename, 'rb').read
    Clipboard::add(data, image: true)

    # Send a notification
    Notification::new(5123)
      .appname('Screenshot')
      .summary("Screenshot saved at #{filename}")
      .icon(filename)
      .urgency(:low)
      .send()
  end


  # Get all the available package updates 
  # within the system, including packages
  # from 'pacman' and 'aur'
  def self.updates()
    hash = {
      pac: `checkupdates`.lines,
      aur: `yay -Qua`.lines
    }
  end
end


