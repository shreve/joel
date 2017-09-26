require 'io/console'

require_relative './ansi'
require_relative './database'
# require_relative './cursor'
require_relative './email_client'
require_relative './renderer'
require_relative './state'
require_relative './view'

class App
  attr_accessor :state

  def initialize
    @renderer = Renderer.new
    @state = State.new
  end

  def run
    IO.console.raw do
      ANSI.clear_screen
      loop do
        render
        handle_input
      end
    end
  end

  def render
    ANSI.move_cursor(0, 0)
    previous_view = @current_view
    @current_view = View.new(@state).render
    @renderer.render_diff(previous_view, @current_view)
    ANSI.move_cursor(0, 0)
  end

  def handle_input
    char = $stdin.getc
    case char
    when 'q' then ANSI.clear_screen and exit(0)

    when 'j' then @state.focus_down
    when 'k' then @state.focus_up
    when 'h' then @state.focus_left
    when 'l' then @state.focus_right

    when 'g' then @state.focus_first
    when 'G' then @state.focus_last

    when 'R' then @current_view = nil

    when "\r" then @state.select!
    end
  end
end
