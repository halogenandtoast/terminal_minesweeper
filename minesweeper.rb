require 'term/ansicolor'
require './board_printer'
require './board'

class Minesweeper
  def initialize(board)
    @board = board
  end

  def play
    while board.running?
      display_board
      handle_move get_move
    end
    display_final_results
  end

  private
  attr_reader :board

  def display_board
    system("clear")
    puts board.to_s
  end

  def display_final_results
    display_board
    puts board.status
  end

  def get_move
    print "> "
    move = gets.chomp.split(" ")
    puts
    move
  end

  def handle_move(move)
    if move.length == 2
      board.reveal(move.map { |i| i.to_i - 1})
    elsif move.length == 3 && move[0] == "f"
      board.flag(move.drop(1).map { |i| i.to_i - 1 })
    end
  end
end

board = Board.new(8, 10)
minesweeper = Minesweeper.new(board)
minesweeper.play
