# Aliases for ease of use
HOME = ENV['HOME']
KATANA = ENV['katana']



# Get the directory for the user
# configuration files.
#
def configs
  "#{HOME}/.config"
end



# Generate a string of a specific
# length.
#
def string(length)
  o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
  (0..length).map { o[rand(o.length)] }.join
end



# Custom import method to allow
# requiring anything within katana without
# having to specify directories
#
def use(*modules)
  Dir["#{KATANA}/**/*.rb"].each do |file|
    name = File::basename(file, '.*')

    if modules.include? name
      require file
    end
  end
end
