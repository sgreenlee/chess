class Board

  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def populate

  end

  def rows
    @grid
  end

  def move(start, end_pos)
    piece = self[start]
    raise InvalidMove if piece.nil?
    raise InvalidMove unless piece.moves.include?(end_pos)

    self[end_pos] = piece
    self[start] = nil
    piece.position = end_pos
  end

  def [](pos)
    row, col = *pos
    grid[row] && grid[row][col]
  end

  def []=(pos, value)
    row, col = *pos
    grid[row] && (grid[row][col] = value)
  end

  def in_bounds?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end
end
