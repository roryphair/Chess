require_relative 'cursor'
require 'colorize'
class Display
  attr_reader :board, :cursor
  def initialize(board)
    @board = board
    @cursor = Cursor.new([0,0], @board)
  end

   def render
    puts
    print('      ')
    (0...8).each {|ele| print(ele.to_s + '  ')}
    puts
    puts
    board.grid.each_with_index do |row,idx1|
      print(" #{idx1}   ")
      row.each_with_index do |piece,idx2|
        if cursor.cursor_pos == [idx1,idx2]  
          print(piece.to_s.colorize(:background => :yellow))
        elsif board[cursor.cursor_pos] != NullPiece.instance && cursor.highlighted_moves.include?([idx1,idx2])
          print(piece.to_s.colorize(:background => :green))
        else
          print(piece.to_s)
        end
      end
      puts
    end
    puts
    if board.in_check?(:white)
      puts 'WARNING WHITE IS IN CHECK'
    elsif board.in_check?(:black)
      puts 'WARNING BLACK IS IN CHECK'
    end
  end

end
