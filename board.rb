require_relative "pieces"

class InvalidMove < StandardError
end

class Board

  def initialize(grid = nil)
    grid ||= Array.new(8) { Array.new(8) }
    @grid = grid
    # populate
  end

  def populate
    [[1, :black], [6, :white]].each do |row , color|
      8.times do |col|
        self[[row, col]] = Pawn.new([row, col], self, color)
      end
    end

    [[0, :black], [7, :white]].each do |row, color|
      self[[row, 0]] = Rook.new([row, 0], self, color)
      self[[row, 7]] = Rook.new([row, 7], self, color)
      self[[row, 1]] = Knight.new([row, 1], self, color)
      self[[row, 6]] = Knight.new([row, 6], self, color)
      self[[row, 5]] = Bishop.new([row, 5], self, color)
      self[[row, 2]] = Bishop.new([row, 2], self, color)
      self[[row, 3]] = Queen.new([row, 3], self, color)
      self[[row, 4]] = King.new([row, 4], self, color)
    end
  end

  def rows
    @grid
  end

  def color_at(pos)
    self[pos].nil? ? nil : self[pos].color
  end

  def dup
    duped_board = Board.new
    rows.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col|
        unless piece.nil?
          pos = [row_idx, col]
          duped_board[pos] = piece.class.new(pos, duped_board, piece.color)
        end
      end
    end
    duped_board
  end


  def move(start, end_pos)
    piece = self[start]

    unless piece && piece.valid_moves.include?(end_pos)
      raise InvalidMove.new("That's an invalid move. Sorry.")
    end

    self[end_pos] = piece
    self[start] = nil
    piece.position = end_pos
    self
  end

  def move!(start, end_pos)
    piece = self[start]
    raise InvalidMove if piece.nil?
    raise InvalidMove unless piece.moves.include?(end_pos)

    self[end_pos] = piece
    self[start] = nil
    piece.position = end_pos
    self
  end

  def [](pos)
    row, col = pos
    @grid[row] && @grid[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @grid[row] && (@grid[row][col] = value)
  end

  def in_bounds?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def in_check?(color)
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
