require_relative "cursorable"
require 'colorize'

class Display
  include Cursorable

  def initialize(board)
    @board = board
    @cursor_pos = [0, 0]
  end


  def build_row(row, i)
    row.map.with_index do |piece, j|
      color_options = color_tile(i, j)
      (piece || "   ").colorize(color_options) # TODO: fix this 
    end
  end

  def build_grid
    @board.rows.map.with_index do |row, i|
      build_row(row, i)
    end
  end



  def color_tile(row, col)

    if [row, col] == @cursor_pos
      bg = :green
    elsif (row + col) % 2 == 0
      bg = :white
    elsif (row + col) % 2 != 0
      bg = :black
    end
    { background: bg, color: :white }
  end

  def render
    system("clear")
    build_grid.each { |row| puts row.join() }
  end
end
