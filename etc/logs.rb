class Logs
  
  # Types:
  #   Dunst
  def self.get(type)
    Dir["#{ENV['katana']}/etc/loggers/*.rb"].each { |file| require file }

    logger = Kernel.const_get("#{type.capitalize}Logger").new

    return logger
  end
end
