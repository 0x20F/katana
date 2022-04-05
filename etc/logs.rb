# Use whenever you want to get the logs
# for something custom that you keep track
# of within the system.
#
# Default implementations include: Dunst at /tmp/dunstlog
class Logs
  
  # Types:
  #   Dunst
  def self.get(type)
    Dir["#{ENV['katana']}/etc/loggers/*.rb"].each { |file| require file }

    logger = Kernel.const_get("#{type.capitalize}Logger").new

    return logger
  end
end
