# coding: utf-8
class View
  @db = Database.new

  class << self
    attr_accessor :db
  end

  attr_accessor :state

  def initialize(state)
    @state = state
  end

  def render
    [
      top_bar,
      *normalize_col_width(body),
      footer
    ]
  end

  private

  def top_bar
    text = rpad('jacob@wellopp.com', ANSI.size[:width])
    [ANSI.color(text, fg: :white, bg: :blue)]
  end

  def footer
    text = lpad('Shrevemail v0.1', ANSI.size[:width])
    [ANSI.color(text, fg: :white, bg: :blue)]
  end

  def body
    emails = db.emails(limit: ANSI.size[:height] - 2, sort: { seqno: :desc })
    mailboxes = db.mailboxes
    emails.map.with_index do |email, i|
      [
        highlight(mailboxes[i] || '', :mailbox, i),
        '│',
        highlight([
                    format_date(email[4]),
                    format_sender(email[3]),
                    format_header(email[2])
                  ].join(' '), :email, i)
      ]
    end
  end

  def db
    self.class.db
  end

  def highlight(text, field, i)
    if @state.focus[field] == i
      ANSI.color(text, fg: :black, bg: :yellow)
    elsif @state.selection[field] == i
      ANSI.color(text, fg: :black, bg: :green)
    else
      text
    end
  end

  def rpad(text, width)
    clean = ANSI.strip(text)
    if clean.length > width
      ANSI.trim(text, width)
    else
      ANSI.inject(text, right: (' ' * (width - clean.length)))
    end
  end

  def lpad(text, width)
    return text[0..width] if text.length >= width
    (' ' * (width - text.length)) + text
  end

  def format_date(date)
    Time.parse(date).strftime '%Y-%m-%d %l:%M:%S %p'
  end

  def format_sender(string)
    string = format_header(string)
    if string.include?('<')
      string.match(/<(.*)>/)[1]
    else
      string
    end
  end

  def format_header(string)
    string.sub(/^(From|Subject): /, '').gsub("\r\n", '')
  end

  def normalize_col_width(view)
    widths = col_widths(view)
    view.map do |line|
      line.map.with_index do |col, i|
        rpad(col.to_s, widths[i])
      end
    end
  end

  def col_widths(arr)
    widths = arr[0].map.with_index do |_line, i|
      col_width(arr, i)
    end
    widths[-1] = ANSI.size[:width] - (widths.reduce(0, :+) - widths[-1])
    widths
  end

  def col_width(arr, col)
    arr.reduce(0) do |max, line|
      length = ANSI.strip(line[col].to_s).length
      [max, length].max
    end
  end
end
