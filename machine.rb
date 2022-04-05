# Wrapper module to do things and get
# status on things that relate to the
# machine itself, e.g. if the lid of 
# the laptop is closed or not.
#
# Required tools in order to use:
# - systemctl (for system on/off)
# - bspwm (for logout)
module Machine
  # Power off the machine
  #
  def self.off
    `systemctl poweroff`
  end


  # Reboot the machine
  #
  def self.reboot
    `systemctl reboot`
  end


  # Suspend the machine, as well
  # as making sure to lock the screen
  #
  def self.suspend
    `slock`
  end


  # Log the current user out and
  # exit the display manager
  #
  def self.logout
    `bspc quit`
  end


  # Lock the screen
  #
  def self.lock
    scripts = ENV['scripts']
    `#{scripts}/lock/lock-screen`
  end
end
