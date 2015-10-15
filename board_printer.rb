class BoardPrinter
  COLORS = %w(white blue green red none magenta cyan yellow reset)

  include Term::ANSIColor

  def initialize(board)
    @board = board
  end

  def to_s
    display_header + display_rows.join("\n")
  end

  private
  attr_reader :board

  def display_header
    "  " + (1..size).to_a.join(" ") + "\n"
  end

  def display_rows
    board.each_with_index.map do |row, index|
      (index + 1).to_s + " " + display_row(row)
    end
  end

  def display_row(row)
    row.map { |square| colorize(square) }.join(" ")
  end

  def size
    board.size
  end

  def colorize(square)
    if square =~ /\d/
      colorize_number(square.to_i)
    else
      colorize_special(square)
    end
  end

  def colorize_number(number)
    if number == 4
      dark(magenta(number.to_s))
    else
      send(COLORS[number], number.to_s)
    end
  end

  def colorize_special(square)
    case square
    when "F" then bold(red(square))
    when "*" then black(on_intense_red(square))
    else white(square)
    end
  end
end
