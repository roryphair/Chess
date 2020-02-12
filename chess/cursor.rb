require "io/console"

KEYMAP = {
  " " => :space,
  "h" => :left,
  "j" => :down,
  "k" => :up,
  "l" => :right,
  "w" => :up,
  "a" => :left,
  "s" => :down,
  "d" => :right,
  "\t" => :tab,
  "\r" => :return,
  "\n" => :newline,
  "\e" => :escape,
  "\e[A" => :up,
  "\e[B" => :down,
  "\e[C" => :right,
  "\e[D" => :left,
  "\177" => :backspace,
  "\004" => :delete,
  "\u0003" => :ctrl_c,
}

MOVES = {
  left: [0, -1],
  right: [0, 1],
  up: [-1, 0],
  down: [1, 0]
}

class Cursor

  attr_reader :cursor_pos, :board, :highlighted_moves
  attr_accessor :select, :end_message

  def initialize(cursor_pos, board)
    @cursor_pos = cursor_pos
    @board = board
    @highlighted_moves = []
    @select = false
    @end_message = ''
  end

  def get_input(color)
    until @select
      loop_over = false
      until loop_over
        render
        puts color.to_s + ' pick piece, press space to pick'
        begin
          key = KEYMAP[read_char]
        rescue 
          retry
        end
        loop_over = handle_key(key, color)
      end
    end
    make_highlight_moves()
  end


  def get_piece_move(color)
    begin
      render
      p 'select a move, enter no to go back'
      highlighted_moves.each_with_index {|ele, idx| print("#{idx} :  #{ele}  ")}
      input = gets.chomp
      if input == 'no'
        @highlighted_moves = []
        @select = false
        return false
      else 
        @select = false
        board.move_piece(color, cursor_pos, highlighted_moves[input.to_i])
        @highlighted_moves = []
      end
    rescue
      p 'not a valid, try again'
      retry
    end
  end

  def select_piece(color)
    if @board[cursor_pos].color == color
      @select = true
      return true
    end
    false
  end


  private

  def read_char
    STDIN.echo = false # stops the console from printing return values

    STDIN.raw! # in raw mode data is given as is to the program--the system
                 # doesn't preprocess special characters such as control-c

    input = STDIN.getc.chr # STDIN.getc reads a one-character string as a
                             # numeric keycode. chr returns a string of the
                             # character represented by the keycode.
                             # (e.g. 65.chr => "A")

    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil # read_nonblock(maxlen) reads
                                                   # at most maxlen bytes from a
                                                   # data stream; it's nonblocking,
                                                   # meaning the method executes
                                                   # asynchronously; it raises an
                                                   # error if no data is available,
                                                   # hence the need for rescue

      input << STDIN.read_nonblock(2) rescue nil
    end

    STDIN.echo = true # the console prints return values again
    STDIN.cooked! # the opposite of raw mode :)

    return input
  end

  def handle_key(key, color)
    if key == :space
      return select_piece(color)
    elsif key == :escape
      end_game
    end
    if !MOVES.include?(key)
      puts 'not valid move kiddo'
      return false 
    end
    update_pos(MOVES[key])
    inside = cursor_pos[0] < 8 && cursor_pos[0] >=0 && cursor_pos[1] < 8 && cursor_pos[1] >=0
     if !inside
      puts 'outside of board, buddy'
      return_pos(MOVES[key])
     end

    inside
  end

  def update_pos(diff)
    cursor_pos[0] += diff[0]
    cursor_pos[1] += diff[1]
    cursor_pos
  end

  def return_pos(diff)
    cursor_pos[0] -= diff[0]
    cursor_pos[1] -= diff[1]
    cursor_pos
  end

  def render(endtext = '')
    system("clear")
    puts
    print('      ')
    (0...8).each {|ele| print(ele.to_s + '  ')}
    puts
    puts
    board.grid.each_with_index do |row,idx1|
      print(" #{idx1}   ")
      row.each_with_index do |piece,idx2|
        if cursor_pos == [idx1,idx2]  
          print(piece.to_s.colorize(:background => :yellow))
        elsif board[cursor_pos] != NullPiece.instance && highlighted_moves.include?([idx1,idx2])
          print(piece.to_s.colorize(:background => :green))
        else
          print(piece.to_s)
        end
      end
      puts
    end
    if board.in_check?(:white)
      puts 'WARNING WHITE IS IN CHECK'
    elsif board.in_check?(:black)
      puts 'WARNING BLACK IS IN CHECK'
    end
    puts endtext
    puts
  end

  def make_highlight_moves()
     @highlighted_moves = board[cursor_pos].valid_moves
  end

  def end_game
    abort
  end
end