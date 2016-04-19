require_relative "cursorable"
require 'colorize'

class Display
  include Cursorable

  def initialize(game)
    @game = game
    @board = game.board
    @selected = false
    @selected_position = nil
    @cursor_pos = [0, 0]
  end

  def handle_select
    if @selected
      begin
        @game.handle_input(@selected_position, @cursor_pos)
      rescue InvalidMove
        puts "Sorry, that's an invalid move."
        sleep(1)
      ensure
        @selected = false
        @selected_position = nil
      end
    else
      @selected = true
      @selected_position = @cursor_pos
    end

  end


  def build_row(row, i)
    row.map.with_index do |piece, j|
      color_options = color_tile(i, j)
      if piece.is_a?(King) && @board.in_check?(piece.color)
        color_options[:background] = :red
      end
      (piece||"   ").to_s.colorize(color_options) 
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
    elsif [row, col] == @selected_position
      bg = :yellow
    elsif (row + col) % 2 == 0
      bg = :blue
    elsif (row + col) % 2 != 0
      bg = :black
    end
    { background: bg, color: :white }
  end

  def render
    system("clear")
    build_grid.each { |row| puts row.join() }
    nil
  end
end
