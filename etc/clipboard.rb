# Required tools to use:
# - xclip (for the clipboard itself)
module Clipboard
  CLIPBOARD = 'xclip -selection clipboard'


  # Add strings, numbers, characters
  # to the clipboard, images will require
  # more specificity
  #
  def self.add(data, image: nil, format: 'image/png')
    type = ''

    if image
      type = "-t #{format}"
    end

    IO::popen("#{CLIPBOARD} #{type}", 'w') { |p| p << data }
  end


  # Get data saved in the clipboard
  #
  def self.get
    `#{CLIPBOARD} -o`
  end


  # Clear the clipboard contents
  #
  def self.clear
    IO::popen(CLIPBOARD, 'w') { |c| c << '' }
  end
end
