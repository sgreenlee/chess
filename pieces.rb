require "byebug"

class Piece
  attr_reader :board, :color
  attr_accessor :position

  def initialize(position, board, color)
    @position = position
    @color = color
    @board = board
    board[position] = self
  end

  def self.step_in_direction(direction, position)
    [direction[0] + position[0], direction[1] + position[1]]
  end

  def add_to_board(board)
    @board = board
    board[position] = self
  end

  def move_into_check?(ending_position)
    @board.dup.move(position, ending_position).in_check?(color)
  end

  def valid_moves
    moves.delete_if { |move| move_into_check?(move) }
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

  # def initialize(position, board, color)
  #   @board = board
  #   @position = position
  #   @color = color
  # end

  def move_dirs
    [[1, 1], [1, -1], [-1, -1], [-1, 1]]
  end

  def to_s
    " #{(color == :white ? "\u2657" : "\u265D").encode('utf-8')} "
  end
end

class Rook < SlidingPiece

  def move_dirs
    [[1, 0], [0, 1], [-1, 0], [0, -1]]
  end

  def to_s
    " #{(color == :white ? "\u2656" : "\u265C").encode('utf-8')} "
  end
end

class Queen < SlidingPiece

  def move_dirs
    [[1, 1], [1, -1], [-1, -1], [-1, 1], [1, 0], [0, 1], [-1, 0], [0, -1]]
  end

  def to_s
    " #{(color == :white ? "\u2655" : "\u265B").encode('utf-8')} "
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

  def move_dirs
    [[1, 1], [1, -1], [-1, -1], [-1, 1], [1, 0], [0, 1], [-1, 0], [0, -1]]
  end

  def to_s
    " #{(color == :white ? "\u2654" : "\u265A").encode('utf-8')} "
  end
end

class Knight < SteppingPiece

  def move_dirs
    [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]]
  end

  def to_s
    " #{(color == :white ? "\u2658" : "\u265E").encode('utf-8')} "
  end
end

class Pawn < Piece

  def moves
    moves = []
    row_change = color == :white ? -1 : 1

    forward = Piece.step_in_direction([row_change, 0], position)
    moves << forward if board[forward].nil?

    [-1, 1].each do |diagonal|
      pos = Piece.step_in_direction([row_change, diagonal], position)
      moves << pos if board[pos] && board[pos].color != self.color
    end

    if color == :white and position[0] == 6
      pos = Piece.step_in_direction([-2, 0], position)
      moves << pos if board[pos].nil?
    end

    if color == :black and position[0] == 1
      pos = Piece.step_in_direction([2, 0], position)
      moves << pos if board[pos].nil?
    end
    moves
  end

  def to_s
    " #{(color == :white ? "\u2659" : "\u265F").encode('utf-8')} "
  end

end
