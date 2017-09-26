class State
  attr_accessor :focus, :selection, :current_column

  def initialize
    self.focus = { mailbox: 0, email: 0 }
    self.selection = { mailbox: 0, email: -1 }
    self.current_column = :mailbox
  end

  def focus_down
    focus[current_column] += 1
  end

  def focus_up
    focus[current_column] -= 1 unless focus[current_column] < 1
  end

  def focus_first
    focus[current_column] = 0
  end

  def focus_last
    focus[current_column] = 60
  end

  def focus_left
    self.current_column = :mailbox
  end

  def focus_right
    self.current_column = :email
  end

  def select!
    selection[current_column] = focus[current_column]
  end
end
