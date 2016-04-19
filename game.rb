require_relative "board"
require_relative "display"

class Game
  attr_reader :board, :current_player, :display
  def initialize
    @board = Board.new
    @board.populate
    @current_player = :white
    @display = Display.new(self)
  end

  def play
    until @board.checkmate?(current_player)
      @display.render
      @display.get_input
    end
    @display.render
    puts "Checkmate. #{@current_player} loses."
  end

  def switch_player!
    @current_player = current_player == :white ? :black : :white
  end

  def handle_input(start_pos, ending_position)
    if board.color_at(start_pos) == current_player
      board.move(start_pos, ending_position)
      switch_player!
    else
      raise InvalidMove.new("Invalid Move")
    end

  end

  def prompt
    puts "Please enter move:"
    input = gets.chomp
  end
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new.play
end
