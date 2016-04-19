require_relative "pieces"

class Board

  def initialize(grid = nil)
    grid ||= Array.new(8) { Array.new(8) }
    @grid = grid
    # populate
  end

  def populate

    # populate black pieces
    rows[1].each_index do |col|
      Pawn.new([1, col], self, :black)
    end

    Rook.new([0,0], self, :black)
    Rook.new([0,7], self, :black)
    Knight.new([0,1], self, :black)
    Knight.new([0,6], self, :black)
    Bishop.new([0,5], self, :black)
    Bishop.new([0,2], self, :black)
    Queen.new([0,3], self, :black)
    King.new([0,4], self, :black)

    # populate white pieces
    rows[6].each_index do |col|
      Pawn.new([6, col], self, :white)
    end

    Rook.new([7,0], self, :white)
    Rook.new([7,7], self, :white)
    Knight.new([7,1], self, :white)
    Knight.new([7,6], self, :white)
    Bishop.new([7,5], self, :white)
    Bishop.new([7,2], self, :white)
    Queen.new([7,3], self, :white)
    King.new([7,4], self, :white)
  end

  def rows
    @grid
  end

  def dup
    duped_board = Board.new
    rows.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col|
        piece.dup.add_to_board(duped_board) unless piece.nil?
      end
    end
    duped_board
  end

  def move(start, end_pos)
    piece = self[start]
    raise InvalidMove if piece.nil?
    raise InvalidMove unless piece.moves.include?(end_pos)

    self[end_pos] = piece
    self[start] = nil
    piece.position = end_pos
    self
  end

  def [](pos)
    row, col = *pos
    @grid[row] && @grid[row][col]
  end

  def []=(pos, value)
    row, col = *pos
    @grid[row] && (@grid[row][col] = value)
  end

  def in_bounds?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def in_check?(color)
    # find kings position
    king_pos = find_king(color)
    enemy_pieces(color).any? { |piece| piece.moves.include?(king_pos) }
  end

  def find_king(color)
    rows.each_with_index do |row, row_idx|
       col = row.index { |piece| piece.is_a?(King) && piece.color == color }
       return [row_idx, col] unless col.nil?
    end
    nil
  end

  def enemy_pieces(color)
    pieces = []
    rows.each do |row|
      row.each { |t| pieces << t unless t.nil? || t.color == color }
    end
    pieces
  end

  def friendly_pieces(color)
    pieces = []
    rows.each do |row|
      row.each { |t| pieces << t unless t.nil? || t.color != color }
    end
    pieces
  end

  def checkmate?(color)
    in_check?(color) && friendly_pieces(color).all? {|pi| pi.valid_moves.empty? }
  end
end
