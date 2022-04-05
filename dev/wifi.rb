# Wrapper around commands that retrieve
# and control information about wireless
# network connections
module Wifi
  
  # Return an array of SSID: UUID pairs of
  # networks that we have been connected to
  # previously
  #
  def self.known_connections
    # First line is column headers
    list = `nmcli con show`.lines[1..-1]
    known = []

    list.map do |item|
      # SSID - UUID - TYPE - DEVICE
      data = item.split

      connection = {
        :ssid => data[0],
        :uuid => data[1]
      }

      known.push(connection)
    end

    known
  end


  # Whether or not the device is
  # currently connected to wifi
  #
  def self.connected?
    `nmcli -f WIFI g`.include? 'enabled'
  end


  # The SSID and all other information about
  # the network the device is currently 
  # connected to
  #
  def self.current
    lines = `nmcli -t -f active,ssid,chan dev wifi`.lines

    network = {}

    lines.each do |line|
      status, name, channel = line.split(':')

      if status == 'yes'
        
        network = {
          :ssid => name,
          :channel => channel.gsub(/\n/, '')
        }

        break
      end
    end

    network
  end


  # Get a full list of all scanned networks and
  # compile a new list of hashes to provide
  # easy access to all info about each network
  #
  def self.list
    fields = 'SSID,SECURITY,BARS,CHAN'

    # First line is column headers
    lines = `nmcli --fields #{fields} dev wifi list`.lines[1..-1]

    networks = []

    lines.each do |network|
      data = network.split

      hash = {
        :ssid => data[0],
        :security => data[1],
        :signal => data[2],
        :channel => data[3]
      }

      networks.push(hash)
    end

    networks
  end


  # Connect to a specific wifi network.
  # If password is provided, use it, otherwise
  # assume the network doesn't have one
  #
  def self.connect(ssid, pass = nil)
    password = pass ? "password \"#{pass}\"" : ''
    
    # FIXME: This thing will break if password is sent in empty like that
    `nmcli dev wifi con "#{ssid}" #{password}`
  end


  # Turn on the wifi card
  #
  def self.on
    `nmcli radio wifi on`
  end


  # Turn off the wifi card
  #
  def self.off
    `nmcli radio wifi off`
  end
end




