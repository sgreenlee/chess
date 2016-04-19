require_relative "pieces"

class InvalidMove < StandardError
end

class InvalidPromotionOption < StandardError
end

class Board
  attr_reader :last_move

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


  def move(start_pos, end_pos)
    piece = self[start_pos]

    if is_castling?(piece, start_pos, end_pos) && can_castle?(piece, end_pos)
      return castle(piece, end_pos)
    end

    if piece.is_a?(Pawn) && piece.is_en_passant?(end_pos)
      return en_passant(piece, end_pos)
    end

    unless piece && piece.valid_moves.include?(end_pos)
      raise InvalidMove.new("That's an invalid move. Sorry.")
    end

    self[end_pos] = piece
    self[start_pos] = nil
    piece.position = end_pos

    if piece.is_a?(Pawn) && piece.promoted?
      promote_piece(piece)
    end

    @last_move = end_pos
    self
  end

  def promote_piece(piece)
    choice = get_promotion_input
    case choice
    when "queen"
      self[piece.position] = Queen.new(piece.position, self, piece.color)
    when "rook"
      self[piece.position] = Rook.new(piece.position, self, piece.color)
    when "bishop"
      self[piece.position] = Bishop.new(piece.position, self, piece.color)
    when "knight"
      self[piece.position] = Knight.new(piece.position, self, piece.color)
    end
  rescue InvalidPromotionOption
    puts "That's not a valid choice. Choose again."
    retry
  end

  def get_promotion_input
    puts "What piece do you want in exchange for the pawn? (Queen, Rook, Knight or Bishop)"
    input = gets.chomp.downcase
    options = %w{ queen knight rook bishop }
    raise InvalidPromotionOption unless options.include?(input)
    input
  end

  def en_passant(piece, end_pos)
    self[end_pos] = piece
    self[piece.position] = nil
    self[[piece.position[0], end_pos[1]]] = nil
    piece.position = end_pos
    return self
  end

  def is_castling?(piece, start_pos, end_pos)
    return false unless piece.is_a?(King)

    home_row = piece.color == :white ? 7 : 0

    start_pos == [home_row, 4] &&
      (end_pos == [home_row, 2] || end_pos == [home_row, 6])

  end

  def can_castle?(piece, end_pos)
    return false unless piece.is_a?(King) && piece.move_count == 0

    rook_start, rook_end = castle_rook_positions(end_pos)
    rook = self[rook_start]

    return false unless rook.is_a?(Rook) && rook.move_count == 0

    return false if piece.castle_into_check?(end_pos)

    rook.valid_moves.include?(rook_end)
  end

  def castle_rook_positions(end_pos)
    case end_pos
    when [0, 6]
      rook_start = [0, 7]
      rook_end = [0, 5]
    when [0, 2]
      rook_start = [0, 0]
      rook_end = [0, 3]
    when [7, 6]
      rook_start = [7, 7]
      rook_end = [7,5]
    when [7, 2]
      rook_start = [7, 0]
      rook_end = [7, 3]
    end

    [rook_start, rook_end]
  end

  def castle(piece, end_pos)
    start_pos = piece.position
    self[end_pos] = piece
    self[start_pos] = nil
    piece.position = end_pos
    self

    rook_start, rook_end = castle_rook_positions(end_pos)

    rook = self[rook_start]
    self[rook_start] = nil
    self[rook_end] = rook
    rook.position = rook_end
    return self
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

  def empty?(pos)
    self[pos].nil?
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
