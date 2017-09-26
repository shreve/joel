# coding: utf-8
class Renderer
  attr_reader :emails

  def generate_view
    [top_bar, *body, footer]
  end

  def render(current)
    ANSI.clear_screen
    ANSI.move_cursor(0, 0)
    # widths = col_widths(current)
    print current.map(&:join).join("\r\n")
  end

  def render_diff(previous, current)
    return render(current) if previous.nil?

    lines = [previous.length, current.length].max
    lines.times.each do |i|
      next if previous[i] == current[i]

      ANSI.move_cursor(i, 0)
      print ANSI.reset
      print current[i].join
      print ANSI.reset
    end
  end
end
