<h1 align="center">katana</h1>
<p align="center">toolkit for whoever is tired of writing unreadable bash scripts</p>

<br/>
<br/>

## Quick Info
- Example usages can be found [here in my chaotic dotfiles](https://github.com/0x20F/dotfiles/tree/master/.scripts).
- Most of the tools it runs on aren't hot-swappable (yet) so keep that in mind.
- Every tool that needs to be installed in order for a module to work is defined within the module itself.

## Simple Usage
```ruby
# Load `katana` into your script
$: << ENV['katana']

# Require the `utils` module so you have an easier time importing things
require 'utils'

# Use any of the available `katana` modules to develop your script
use 'logs' 'machine' 

# Do whatever your script needs to do below...
Machine::off()
```