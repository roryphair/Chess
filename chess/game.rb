require_relative 'board'
require_relative 'display'
require 'byebug'
require_relative 'human_player'
class Game
  attr_reader :display, :board
  attr_accessor :current_player
  def initialize()
    @board = Board.new
    @display = Display.new(@board)
    @player1 = HumanPlayer.new(:white, @display)
    @player2 = HumanPlayer.new(:black, @display)
    @current_player = @player1
  end

  def play
    puts 'WELCOME TO CHESS MY LORD'
    until board.checkmate?(@player1.color) || board.checkmate?(@player2.color)
      @current_player.make_move
      swap_turn!
    end
    @board.render
    puts " #{@current_player.color} HAS WON, THEY WILL BE FOREVER HAPPY IN A LAND OF ETERNAL WONDER"
  end

  private

  def notify_players

  end

  def swap_turn!
    @current_player == @player1 ? @current_player = @player2 : @current_player = @player1
  end

end
g = Game.new()
g.play
# i = 0
# while i < 10
#   g.display.cursor.get_input
#   g.display.render
#   i+=1
# end
# g.display.render
# g.board.move_piece(:black, [6,5], [5,5])
# g.display.render
# g.board.move_piece(:white, [1,4], [3,4])
# g.display.render
# g.board.move_piece(:black, [6,6], [4,6])
# g.display.render
# g.board.move_piece(:white, [0,3], [4,7])
# g.display.render

# p g.board.in_check?(:white)
# p g.board.in_check?(:black)
# p g.board.checkmate?(:white)
# p g.board.checkmate?(:black)

