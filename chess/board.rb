class NoPieceThereError < StandardError
end

class IntoCheck < StandardError
end

require_relative 'piece'
class Board
  attr_accessor :grid
  def initialize(dup = false)
    @grid = Array.new(8) {Array.new(8) {NullPiece.instance}}
    setup_board unless dup
  end
  
  def setup_board
    #player1 setup
    base_piece(:white)
    #player 2 setup
    base_piece(:black, 7,-1)
  end

  def base_piece(color, index = 0, adjust = 1)
    grid[index + adjust].map!.with_index {|ele,idx | Pawn.new(color, self, [index + adjust, idx])}
    #rooks
    grid[index][0] = Rook.new(color, self, [index, 0])
    grid[index][7] = Rook.new(color, self, [index, 7])
    #knights
    grid[index][1] = Knight.new(color, self, [index, 1])
    grid[index][6] = Knight.new(color, self, [index, 6])
    #bishop
    grid[index][2] = Bishop.new(color, self, [index, 2])
    grid[index][5] = Bishop.new(color, self, [index, 5])
    #queen
    grid[index][3] = Queen.new(color, self, [index, 3])
    #king
    grid[index][4] = King.new(color, self, [index, 4])
  end

  def move_piece(color, start_pos, end_pos)
    begin
      if valid_pos?(self[start_pos].color, end_pos) && self[start_pos] && self[start_pos].color == color && self[start_pos].moves.include?(end_pos)
        raise IntoCheck.new 'You cannot move into check' if !self[start_pos].valid_moves.include?(end_pos)
        add_piece(self[start_pos], end_pos)
        self[start_pos] = NullPiece.instance
        true
      else 
        raise NoPieceThereError.new 'Not a valid move you dirty idiot'
      end
    rescue => e
      raise e
    end
  end

  def move_piece!(color, start_pos, end_pos)
    begin
      if valid_pos?(self[start_pos].color, end_pos) && self[start_pos] && self[start_pos].color == color && self[start_pos].moves.include?(end_pos)
        add_piece(self[start_pos], end_pos)
        self[start_pos] = NullPiece.instance
        true
      else 
        raise NoPieceThereError.new 'Not a valid move you dirty idiot'
      end
    rescue => e
      puts e
    end
  end


  def valid_pos?(start_color, end_pos)
    #we changing this when doing piece stuff but its vague now
    if end_pos[0] >=0 && end_pos[0] < 8 && end_pos[1] >=0 && end_pos[1] < 8 && start_color != self[end_pos].color
      return true
    end
  end

  def add_piece(piece, pos)
    self[pos] = piece
    piece.pos = pos
  end

  def []= (pos, value) 
    grid[pos[0]][pos[1]] = value
  end

  def [](pos)
    grid[pos[0]][pos[1]]
  end

  def in_check?(color)
    #find king
    color == :white ? oppose_col = :black : oppose_col = :white
    king = nil
    opponents = get_pieces(oppose_col)
    grid.each do |sub| 
      sub.each  do |piece| 
        if piece.is_a?(King) && piece.color == color
          king = piece
        end
      end
    end
    opponents.each {|piece| return true if piece.moves.include?(king.pos)}
    
    false
  end

  def get_pieces(color)
    all_pieces = []
    grid.each do |sub| 
      sub.each  do |piece| 
        all_pieces << piece if piece.color == color
      end
    end
    all_pieces
  end


  def checkmate?(color)
    if in_check?(color)
      get_pieces(color).all? {|piece| piece.valid_moves.empty?}
    else
      false
    end
  end



  def dup
    new_board = Board.new(true)
    self.grid.each_with_index do |sub, idx1|
      sub.each_with_index do |piece,idx2|
        if !piece.is_a?(NullPiece)
          class_piece = piece.class
          new_board[[idx1,idx2]] = class_piece.new(piece.color, new_board, piece.pos)
        end
      end
    end
    new_board
  end

end

