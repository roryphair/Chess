class Player
  attr_reader :color, :display
  def initialize(color,display)
      @color = color
      @display = display
  end
end


class HumanPlayer < Player
  
  def make_move
    completed = false
    until completed
      display.cursor.get_input(color)
      completed = display.cursor.get_piece_move(color)
    end
  end

end