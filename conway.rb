#!/usr/bin/env ruby

class Conway
  attr_accessor :next_board, :current_board

  ROWS = 20
  COLS = 20
  def initialize
    self.next_board = ROWS.times.map{ COLS.times.map{ false } }
    self.current_board = ROWS.times.map{ COLS.times.map{ false } }
    setup(:pulsar)
    play
  end

  def setup(board_name)
    alives = []
    case board_name

    # Oscillators
    when :blinker
      alives = [
        [2, 1],
        [2, 2],
        [2, 3],
      ]
    when :toad
      alives = [
        [2, 2],
        [2, 3],
        [2, 4],
        [3, 1],
        [3, 2],
        [3, 3],
      ]
    when :beacon
      alives = [
        [1, 1],
        [1, 2],
        [2, 1],
        [3, 4],
        [4, 3],
        [4, 4],
      ]
    when :pulsar
      [2,7,9,14].each{|num1|
        [4,5,6,10,11,12].each{|num2|
          alives.push([num1, num2], [num2, num1])
        }
      }

    # Randomized
    when :rand
      ROWS.times.each do |row|
        COLS.times.each do |col|
          alives[row][col] = true if rand > 0.3
        end
      end
    end
    alives.each do |row, col|
      self.current_board[row][col] = true
    end
    print "\n" * (ROWS + 2)
  end

  def play
    print_board
    loop do
      sleep 0.25
      step
    end
  end

  def step
    self.current_board.each_with_index do |line, row|
      line.each_with_index do |square, col|
        calculate(row, col)
      end
    end

    self.current_board = self.next_board
    self.next_board = ROWS.times.map{ COLS.times.map{ false } }
    print_board
  end

  def calculate(row, col)
    count = live_neighbors(row, col)
    #Any live cell with fewer than two live neighbours dies, as if caused by under-population.
    #Any live cell with two or three live neighbours lives on to the next generation.
    #Any live cell with more than three live neighbours dies, as if by overcrowding.
    #Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
    self.next_board[row][col] = self.current_board[row][col] ?
      (2..3) === count :
      3 === count
  end

  def live_neighbors(row, col)
    count = 0
    (-1..1).each do |rowdiff|
      (-1..1).each do |coldiff|
        begin
          next if (rowdiff == 0 && coldiff == 0) || # center
            row + rowdiff < 0        || # left edge
            row + rowdiff > ROWS - 1 || # right edge
            col + coldiff < 0        || # top edge
            col + coldiff > COLS - 1    # bottom edge
          count += 1 if self.current_board[row + rowdiff][col + coldiff]
        rescue
          puts "wtf"
          puts([row + rowdiff, col + coldiff].inspect)
          puts(self.current_board[row + rowdiff].nil?)
        end
      end
    end
    count
  end

  def print_board
    print "\033[#{ROWS + 2}A"
    puts "╔" + (COLS+1).times.map{"═"}.join("═") + "╗"
    self.current_board.each do |line|
      line = line.map do |square|
        square ? "█" : " "
      end.join(" ")
      puts "║ " + line + " ║"
    end
    puts "╚" + (COLS+1).times.map{"═"}.join("═") + "╝"
  end
end

Conway.new
