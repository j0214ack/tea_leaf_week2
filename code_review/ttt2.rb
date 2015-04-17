require 'pry'

class Game
  attr_reader :user, :computer, :board

  WINNING_LINES = [[1,2,3], [4,5,6], [7,8,9], [1,4,7], [2,5,8], [3,6,9],
                   [1,5,9], [3,5,7] ]

  def initialize
    reset
  end

  def reset
    @user = Human.new("Yulin", "O")
    @computer = Computer.new("Computer", "X")
    @board = Board.new
    @current_player = @user
  end

  def alternate_player
    if @current_player == user
      @current_player = computer
    else
      @current_player = user 
    end
  end

  def run
    begin 
      while true
        board.draw 
        @current_player.put_piece_on(board)

        if @current_player.win?
          message = "#{@current_player.name} won!"
          break

        elsif board.positions_of_empty_grids.size == 0
          message = "It's a tie!"
          break
        end

        alternate_player
      end

      board.draw 
      puts message 
      message = ''

      begin
        puts "Play again? (Y/N)"
        continue = gets.chomp.downcase
      end until ['y', 'n'].include? continue
      reset
    end until continue == 'n'
  end
end

class Player
  attr_reader :grids_taken_over, :name

  def initialize(name, piece)
    @name = name
    @grids_taken_over = []
    @piece = piece 
  end

  def win?
    Game::WINNING_LINES.each do |positions|
      return true if (positions - grids_taken_over).empty?
    end

    return false
  end
end

class Human < Player
  def put_piece_on(board)
    while true
      print "Choose a position (from 1 to 9) to place a piece: "
      choice = gets.chomp.to_i

      if (1..9).to_a.include?(choice) && board[choice] == ' ' 
        @grids_taken_over << choice 
        board[choice] = @piece 
        break
      else
        puts "Error: you must enter a position (from 1 to 9) of an empty grid."
      end
    end        
  end
end

class Computer < Player 
  def put_piece_on(board)
    position = board.positions_of_empty_grids.sample
    @grids_taken_over << position
    board[@grids_taken_over.last] = @piece 
  end
end

class Board
  attr_accessor :board 

  def initialize
    self.board = {}
    (1..9).each { |position| self.board[position] = ' ' }   
  end

  def positions_of_empty_grids
    board.select { |pos,piece| piece == ' ' }.keys
  end

  def draw
    system 'clear'
    puts " #{board[1]} | #{board[2]} | #{board[3]} "
    puts "---+---+---"
    puts " #{board[4]} | #{board[5]} | #{board[6]}"
    puts "---+---+---"
    puts " #{board[7]} | #{board[8]} | #{board[9]}"    
  end

  def [](position)
    @board[position]
  end

  def []=(position, piece)
    @board[position] = piece 
  end
end

game = Game.new
game.run 

