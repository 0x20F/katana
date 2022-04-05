require 'socket'


# Neat wrapper around rofi for creating
# menus dynamically from within any of your
# scripts. This also accounts for multiple 
# rofi windows that replace each other allowing you
# to nicely have an initial window with a specific theme
# that indicates that something is loading.
#
# Required tools to use:
# - rofi
class Menu

  # Set menu to a specific type.
  #
  # Available types are:
  #   :custom
  #   :default
  #
  def initialize(type = :default)
    @type = type
   
    @lines = []
    @active_lines = []
    @urgent_lines = []

    @loading = false
    @separator_ch = "\n"

    @parent, @child = UNIXSocket.pair
    @process = {
      :rofi => nil,
      :fork => nil
    }
  end


  # Create a new process with separate pipes
  # and run the menu inside that process so
  # the script can sit and work on other things
  # while the menu shows up.
  #
  # This gives us the ability to show a loading
  # menu while we calculate anything heavier
  # in the background for the actual menu we
  # want to display
  #
  def show(message = nil)
    @process[:fork] = fork do
      @parent.close

      r, w = IO.pipe
      command = build_command()

      pid = Process::spawn(
        command, 
        :in => r, 
        :out => @child
      )
     
      message = @lines.join(@separator_ch) if not message
      w.puts(message)

      @child.send("#{pid}", 0)
    end

    @process[:rofi] = @parent.recv(100).to_i
    
    # The forked process won't be used for
    # anything else, so we can clean it up
    # quickly.
    sleep 1 # Wait a bit before killing anything
            # This means that every loading menu will
            # have a loading time of at least 1 second.
            # It's not pretty but it'll do for now.
    kill_fork

    self
  end


  # Display a placeholder menu with
  # the same specific theme where only
  # a line that indicates that the other
  # lines are loading is visible.
  #
  # Basically a "loading screen" for menus
  # that might do some heavier lifting in
  # the background.
  #
  # The wifi menu is one such example.
  #
  def loading(status, message = 'Loading...')
    if status == :on
      @loading = true

      destroy()
      show(message) 
      return
    end

    @loading = false

    destroy()
    show()
  end


  # Await for a value from the menu,
  # this is blocking so when it's called,
  # nothing after it will run unless the 
  # used chooses an option from the currently
  # visible menu.
  #
  # Will not run at all if no menu is currently visible
  #
  def value
    return nil unless @process[:rofi]

    # Setup an automatic cleanup if
    # nothing happens for a while.
    #
    # If rofi is closed without a choice,
    # this will keep waiting for a value, exit 
    # eventually.
    Thread::new() do 
      sleep 120
      destroy()
      exit
    end

    @parent.recv(65535).split.join(' ').force_encoding('utf-8')
  end


  # Add a new line to the final payload
  # that rofi will display.
  #
  # Optionally, a status for the line can be
  # specified. Available statuses are:
  #   :active
  #   :urgent
  #
  def add_line(line, status = nil)
    @lines.push(line)
    
    case status
    when :active
      @active_lines.push(@lines.length - 1)
    when :urgent
      @urgent_lines.push(@lines.length - 1)
    end

    self
  end


  # Make sure to clear all the created processes
  # as well as cleanup any other things that 
  # might linger after the script has finished
  # running.
  #
  # Since rofi runs in a separate, forked process
  # those can't be left alive after the script
  # is finished. They'll just be zombies.
  #
  def destroy
    kill_fork
    kill_rofi
  end


  # Sometimes, the parent script might
  # want to finish early and not wait
  # for a response from rofi.
  #
  # That script will need to explicitly
  # destroy all of its child processes
  # on exit while leaving the rofi processes
  # alive.
  #
  def kill_fork
    pid = @process[:fork]
    Process::kill('INT', pid) if pid

    @process[:fork] = nil
  end


  # Usually after a loading 'screen' is done,
  # the entire forked process along with rofi
  # needs to be cleaned up so a new rofi can
  # be reopened.
  #
  def kill_rofi
    pid = @process[:rofi]

    if not pid
      return
    end

    begin
      Process::kill('INT', pid)
    rescue Errno::ESRCH => _
      # Process might've been killed by user
    ensure
      @process[:rofi] = nil
    end
  end


  # Compose the command that will run
  # when the menu is toggled on
  #
  def build_command
    mode = '-dmenu'

    if @type == :default and not @loading
      mode = '-show drun'
    end

    command = [
      "rofi #{mode}",
      @prompt,
      @max_lines,
      @markup,
      @separator,
      @theme,
      @insensitive,
      @icons,
      @eh
    ]

    if @active_lines.length > 0
      command.push("-a #{@active_lines.join(',')}")
    end

    if @urgent_lines.length > 0
      command.push("-u #{@urgent_lines.join(',')}")
    end

    command.join(' ')
  end


  # Tell the menu what to show as 
  # the prompt text when it spawns
  #
  def prompt(text)
    @prompt = "-p '#{text}'"
    self
  end


  # Tell the menu how many lines
  # it should display
  #
  def max_lines(max)
    @max_lines = "-lines #{max}"
    self
  end


  # Tell the menu whether to interpret
  # the rows as markup language
  #
  def markup
    @markup = '-markup-rows'
    self
  end


  # Tell the menu what theme to use.
  # Theme directory must be defined inside
  # the 'rofi_themes' environment variable
  #
  def theme(theme)
    directory = ENV['rofi_themes']
    @theme = "-theme '#{directory}/#{theme}'"
    self
  end


  # Tell the menu what the line separator is,
  # in case you don't want to use the default
  # newline character
  #
  def line_separator(sep)
    # Save the character as well as the parameter
    # since the character might be used somewhere else
    @separator_ch = "#{sep}"
    @separator = "-sep #{sep}"
    self
  end


  # Tell the menu that it shouldn't care
  # about casing when matching search queries
  #
  def insensitive
    @insensitive = '-i'
    self
  end


  # Tell the menu that it should show
  # the icons provided in the data for
  # each custom row
  #
  def icons
    @icons = '-show-icons'
    self
  end


  # Tell the menu how high each row 
  # should be
  #
  def row_height(height)
    @eh = "-eh #{height}"
    self
  end


  private :build_command

end



