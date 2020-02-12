require 'colorize'
require 'colorized_string'
require 'singleton'
require 'byebug'
module Slideable
  def moves
    color == :white ? oppose_col = :black : oppose_col = :white
    arr = []
    directions.each do |direction|
      next_spot = [pos[0] + direction[0], pos[1] + direction[1]]
      while board.valid_pos?(color, next_spot)
        arr << next_spot
        break if board[next_spot].color == oppose_col
        next_spot = [next_spot[0] + direction[0], next_spot[1] + direction[1]]
      end
    end
    arr
  end
end

module Stepable
  def moves
    arr = []
    # debugger
    directions.each do |direction|
      next_spot = [pos[0] + direction[0], pos[1] + direction[1]]
      arr << next_spot if board.valid_pos?(color, next_spot)
    end
    arr
  end
end

class Piece
  attr_accessor :pos 
  attr_reader :directions, :color, :board, :text_color, :representation
  def initialize(color, board, pos)
    @directions = []
    @color, @board, @pos, = color, board, pos
    if color == :white
      @text_color = :white
    else
      @text_color = :black
    end
    @representation = ' P '
  end

  def pos= (new_pos)
    @pos = new_pos
  end
  # returns array of moves

  def inspect
    ' ' + @representation.encode('utf-8') + ' '
  end

  def to_s
     ' ' + @representation.encode('utf-8') + ' '
  end

  def valid_moves
    moves.select {|move| !move_into_check?(move)}
  end
  
  def move_into_check?(end_pos)
    new_board = board.dup
    new_board.move_piece!(color,pos,end_pos)
    new_board.in_check?(color)
  end

  def get_opp_color
    color == :white ? :black : :white
  end
  
end

class Pawn < Piece
  attr_reader :diagonal
  def initialize(color, board, position)
    super
    @representation = "\u2659"
    @representation = "\u265F" if color == :white 
    @starting_pos = position
    if @color == :white
      @directions = [[1,0] , [2,0]]
      @diagonal = [[1,1], [1,-1]]
    else
      @directions = [[-1,0] , [-2,0]]
      @diagonal = [[-1,1], [-1,-1]]
    end
  end

  def moves
    #change if not starting position
    opp_col = get_opp_color
    if @starting_pos != pos
      if @color == :white
        @directions = [[1,0]]
      else
        @directions = [[-1,0]]
      end
    end
    arr = []
    # debugger
    directions.each do |direction|
      next_spot = [pos[0] + direction[0], pos[1] + direction[1]]
      if next_spot[0] >=0 && next_spot[0] < 8 && next_spot[1] >=0 && next_spot[1] < 8 && board[next_spot] == NullPiece.instance
        arr << next_spot 
      end
    end
    diagonal.each do |direction|
      next_spot = [pos[0] + direction[0], pos[1] + direction[1]]
      if next_spot[0] >=0 && next_spot[0] < 8 && next_spot[1] >=0 && next_spot[1] < 8 && board[next_spot].color == opp_col
        arr << next_spot 
      end
    end

    arr

  end
end

class Rook < Piece
  include Slideable
  def initialize(color, board, position)
    super
    @representation = "\u2656"
    @representation[-1] = "\u265C" if color == :white 
    @directions = [[1,0], [0,1], [0,-1], [-1,0]]
  end
end

class Bishop < Piece
  include Slideable
  def initialize(color, board, position)
    super
    @representation = "\u2657"
    @representation[-1] = "\u265D" if color == :white 
    @directions = [[1,1], [-1,1], [1,-1], [-1,-1]]
  end
end

class Queen < Piece
  include Slideable
  def initialize(color, board, position)
    super
    @representation = "\u2655"
    @representation[-1] = "\u265B" if color == :white 
    @directions = [[1,1], [-1,1], [1,-1], [-1,-1], [1,0], [0,1], [0,-1], [-1,0]]
  end
end


class Knight < Piece
  include Stepable
  def initialize(color, board, position)
    super
    @representation = "\u2658"
    @representation[-1] = "\u265E" if color == :white 
    @directions =  [[2,1], [2,-1], [1,2], [1,-2], [-2,1], [-2,-1], [-1,2], [-1,-2]]
  end
end

class King < Piece
  include Stepable
  def initialize(color, board, position)
    super
    @representation = "\u2654"
    @representation[-1] = "\u265A" if color == :white 
    @directions = [[1,1], [-1,1], [1,-1], [-1,-1], [1,0], [0,1], [0,-1], [-1,0]]
  end
end

class NullPiece < Piece
  include Singleton
  def initialize()
    @color = ''
    @representation = "\u2610"
  end
end