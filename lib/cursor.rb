class Cursor
  attr_reader :row, :col

  def initialize(row = 0, col = 0)
    row = 0 if row < 0
    col = 0 if col < 0
    @row = row
    @col = col
  end

  def left
    Cursor.new(@row, @col - 1)
  end

  def right
    Cursor.new(@row, @col + 1)
  end

  def down
    Cursor.new(@row + 1, @col)
  end

  def up
    Cursor.new(@row - 1, @col)
  end
end
