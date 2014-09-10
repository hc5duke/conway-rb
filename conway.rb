#!/usr/bin/env ruby

class Conway
  attr_accessor :next_board, :current_board

  ROWS = 15
  COLS = 15
  def initialize
    self.next_board = ROWS.times.map{ COLS.times.map{ false } }
    self.current_board = ROWS.times.map{ COLS.times.map{ false } }
    setup(:blinker)
    play
  end

  def setup(board_name)
    case board_name
    when :blinker
      self.current_board[2][1] = true
      self.current_board[2][2] = true
      self.current_board[2][3] = true
    when :rand
      self.current_board = ROWS.times.map{
        COLS.times.map{
          (rand > 0.3)
        }
      }
    end
    print "\n" * ROWS
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
      (2..4) === count :
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
    puts "╔" + COLS.times.map{"═"}.join("═") + "╗"
    self.current_board.each do |line|
      line = line.map do |square|
        square ? "█" : " "
      end.join(" ")
      puts "║" + line + "║"
    end
    puts "╚" + COLS.times.map{"═"}.join("═") + "╝"
  end
end

Conway.new
