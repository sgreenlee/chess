require "byebug"

class Piece
  attr_reader :board, :color, :move_count, :position

  def initialize(position, board, color)
    @position = position
    @color = color
    @board = board
    @move_count = 0
  end

  def position=(pos)
    @position = pos
    @move_count += 1
  end

  def self.step_in_direction(direction, position)
    [direction[0] + position[0], direction[1] + position[1]]
  end

  def move_into_check?(ending_position)
    @board.dup.move!(position, ending_position).in_check?(color)
  end

  def valid_moves
    moves.delete_if { |move| move_into_check?(move) }
  end

  def to_s
    " #{(color == :black ? black_code : white_code)} "
  end
end


class SlidingPiece < Piece
  def moves
    moves = []

    move_dirs.each do |dir|
      # debugger
      pos = self.position
      pos = Piece.step_in_direction(dir, pos)

      while board.in_bounds?(pos) && board[pos].nil?
        moves << pos
        pos = Piece.step_in_direction(dir, pos)
      end

      if board[pos] && board[pos].color != self.color
        moves << pos
      end
    end
    moves
  end
end


class Bishop < SlidingPiece
  def black_code
    "\u2657"
  end

  def white_code
    "\u265D"
  end

  def move_dirs
    [[1, 1], [1, -1], [-1, -1], [-1, 1]]
  end
end


class Rook < SlidingPiece
  def black_code
    "\u2656"
  end

  def white_code
    "\u265C"
  end

  def move_dirs
    [[1, 0], [0, 1], [-1, 0], [0, -1]]
  end

end

class Queen < SlidingPiece
  def black_code
    "\u2655"
  end

  def white_code
    "\u265B"
  end

  def move_dirs
    [[1, 1], [1, -1], [-1, -1], [-1, 1], [1, 0], [0, 1], [-1, 0], [0, -1]]
  end
end


class SteppingPiece < Piece
  def moves
    moves = []

    move_dirs.each do |dir|
      pos = Piece.step_in_direction(dir, self.position)
      if board.in_bounds?(pos) && (board[pos].nil? || board[pos].color != self.color)
        moves << pos
      end

    end

    moves
  end

end

class King < SteppingPiece
  def black_code
    "\u2654"
  end

  def white_code
    "\u265A"
  end

  def intermediate_castling_position(ending_position)
    [position[0] , position[1] + ((ending_position[1] - position[1]) / 2)]
  end

  def castle_into_check?(ending_position)
    intermediate_position = intermediate_castling_position(ending_position)
    bdup = @board.dup
    return true if bdup.move!(position, intermediate_position).in_check?(color)
    bdup.move!(intermediate_position, ending_position).in_check?(color)
  end

  def move_dirs
    [[1, 1], [1, -1], [-1, -1], [-1, 1], [1, 0], [0, 1], [-1, 0], [0, -1]]
  end


end

class Knight < SteppingPiece

  def black_code
    "\u2658"
  end

  def white_code
    "\u265E"
  end

  def move_dirs
    [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]]
  end

end

class Pawn < Piece
  def black_code
    "\u2659"
  end

  def white_code
    "\u265F"
  end

  def moves
    forward_moves + diagonal_moves
  end

  def is_en_passant?(end_pos)
    start_row = color == :white ? 3 : 4
    end_row = color == :white ? 2 : 5

    move_direction = row_change
    other_piece = board[[position[0], end_pos[1]]]
    position[0] == start_row &&
      end_pos[0] == end_row &&
      (end_pos[1] - position[1]).abs == 1 &&
      board.empty?(end_pos) &&
      other_piece.is_a?(Pawn) &&
      other_piece.color != color &&
      other_piece.move_count == 1 &&
      board.last_move == [position[0], end_pos[1]]
  end

  def promoted?
    promo_row = color == :white ? 0 : 7
    position[0] == promo_row
  end

  private

  def row_change
    color == :white ? -1 : 1
  end

  def starting_row
    color == :white ? 6 : 1
  end

  def diagonal_moves
    moves = []
    [-1, 1].each do |diagonal|
      pos = Piece.step_in_direction([row_change, diagonal], position)
      moves << pos if board[pos] && board[pos].color != self.color
    end
    moves
  end

  def forward_moves
    moves = []
    forward = Piece.step_in_direction([row_change, 0], position)
    moves << forward if board[forward].nil?

    if position[0] == starting_row
      pos = Piece.step_in_direction([row_change * 2, 0], position)
      moves << pos if board[pos].nil?
    end
    moves
  end
end
