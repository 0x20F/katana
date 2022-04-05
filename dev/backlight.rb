# Wrapper module around backlight control
# tools. Backlight includes both keyboard
# and screen brightness.
#
# - Keyboard backlight is not implemented yet
#
# Required tools to use:
# - light (for screen backlight info)
module Backlight
  # Increase the brightness level of 
  # the screen
  def self.raise(by = 10) `light -A #{by}` end


  # Decrease the brightness level of
  # the screen
  def self.lower(by = 10) `light -U #{by}` end


  # Get the current brightness
  # level of the screen
  def self.screen_level() `light -G` end
end
