class Board
  FLAGGED = 'F'
  UNCHECKED = '+'
  MINE = '*'

  include Enumerable
  attr_reader :board, :size

  def initialize(size, mine_count)
    @size = size
    @mine_count = mine_count
    @squares = Array.new(size) { Array.new(size) { UNCHECKED } }
    @board = Array.new(size) { Array.new(size) }
    @first_move = true
  end

  def to_s
    BoardPrinter.new(self).to_s
  end

  def each
    squares.each { |row| yield(row) }
  end

  def running?
    !lost? && !won?
  end

  def reveal(position)
    if first_move
      make_first_move(position)
    else
      make_normal_move(position)
    end
  end

  def flag(position)
    row, column = position
    squares[row][column] = toggle_flag(row, column)
  end

  def status
    if lost?
      "You lose"
    else
      "You win"
    end
  end

  private
  attr_reader :squares, :mine_count, :first_move

  def toggle_flag(row, column)
    if squares[row][column] == UNCHECKED
      FLAGGED
    elsif squares[row][column] == FLAGGED
      UNCHECKED
    end
  end

  def make_first_move(position)
    @first_move = false
    generate_board(position)
    make_normal_move(position)
  end

  def generate_board(position)
    place_mines(position)
    calculate_numbers
  end

  def set(position, value)
    row, column = position
    board[row][column] = value
  end

  def get(position)
    row, column = position
    board[row][column]
  end

  def get_square(position)
    row, column = position
    squares[row][column]
  end

  def set_square(position, value)
    row, column = position
    squares[row][column] = value
  end

  def place_mines(position)
    mine_count.times do
      mine = generate_mine(position)
      set(mine, MINE)
    end
  end

  def neighbors(position)
    row, column = position
    [
      [row-1, column-1], [row-1, column], [row-1, column+1], [row, column-1],
      [row, column+1], [row+1, column-1], [row+1, column], [row+1, column+1]
    ].select { |position| valid_position?(position) }
  end

  def generate_mine(safe_position)
    safe_positions = [safe_position] + neighbors(safe_position)
    get_mine_position(safe_positions)
  end

  def get_mine_position(safe_positions)
    position = 2.times.map { (0...size).to_a.sample }
    while safe_positions.include?(position) || get(position) == MINE
      position = 2.times.map { (0...size).to_a.sample }
    end
    position
  end

  def calculate_numbers
    (size ** 2).times do |count|
      calculate_position([count / size, count % size])
    end
  end

  def calculate_position(position)
    if get(position) != MINE
      set(position, count_mines(position).to_s)
    end
  end

  def count_mines(position)
    neighbors(position).count do |neighbor_position|
      get(neighbor_position) == MINE
    end
  end

  def valid_position?(position)
    row, column = position
    row >= 0 && column >= 0 && row < size && column < size
  end

  def lost?
    squares.any? { |row| row.include?(MINE) }
  end

  def won?
    left = squares.inject(0) do |sum, row|
      sum += row.count(UNCHECKED) + row.count(FLAGGED)
    end
    left == mine_count
  end

  def make_normal_move(position)
    if get(position) == "0"
      reveal_zero(position)
    elsif get_square(position) != FLAGGED
      set_square(position, get(position))
    end
  end

  def reveal_zero(position)
    set_square(position, "0")
    positions = neighbors(position).select do |position|
      [UNCHECKED, FLAGGED].include?(get_square(position))
    end
    positions.each { |position| make_normal_move(position) }
  end
end
