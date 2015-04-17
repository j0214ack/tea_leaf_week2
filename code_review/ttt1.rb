class Square  
  def initialize(marker)
    @marker = marker
  end  

  def select_symbol(symbol)       
    @marker.mark = Marker::MARK[symbol]
  end

  def clear
    @marker.mark = Marker::MARK[:empty]
  end

  def is_marked?
    (self.display.empty?) ? false : true
  end

  def display
    @marker.to_s
  end
end

class Marker
  MARK = {empty:"",O:"O",X:"X"}.freeze
  attr_accessor :mark

  def initialize()
    @mark = MARK[:empty]
  end

  def to_s
    self.mark
  end
end

class Player     
  ROLE = {computer:"computer", human:"human"}.freeze
  attr_reader :name,:role,:icon,:picked_squares

  def initialize(n,r)              
    @name = n
    @role = ROLE[r]  
    @picked_squares = {}
  end

  def pick_square(empty_squares)             
    if self.role == Player::ROLE[:human] 
      puts "#{self.name} ::"     
      printf "select one square: #{empty_squares.keys} "        
      while true        
        i = gets.chomp.to_i
        if empty_squares.keys.include? i
          square = empty_squares[i]
          square.select_symbol(:O)
          @picked_squares[i] = square       
          break
        end
      end
    else # role == Player::ROLE[:computer]        
      square_key = empty_squares.keys.sample      
      square = empty_squares[square_key]
      square.select_symbol(:X)
      @picked_squares[square_key] = square      
    end
  end
end

class Board   
  def initialize(board_size)
    @board_size = board_size
    @winning_lines =[[1,2,3], [4,5,6], [7,8,9], [1,4,7], [2,5,8], [3,6,9], [3,5,7], [1,5,9]]    
    @squares = create_squares
    @players = create_players
  end

  def start_new_game
    system "clear"
    puts "Ok, let's go to play TicTacToe Game."
    puts "------------------------------------"        

    clear_squares     
    while !is_game_over?                 
      @players.each do |player|                 
        display_board 
        player.pick_square(empty_squares)                                  
        display_board 
        break if is_game_over?                 
      end            
    end  
    display_result 
  end

  def is_exit_or_play_again     
    printf "\nE)xit or Press any key to play again. "          
    gets.chomp.upcase == "E" ? true : false 
  end

  private

  def is_game_over?         
    ((empty_squares.count == 0) || !winner.empty?) ? true : false
  end 

  def empty_squares
    @squares.select { |k,v| v.display.empty? == true }
  end

  def winner
    @players.each do |player|      
      @winning_lines.each do |patten|        
        return "#{player.name}" if ((player.picked_squares.keys.sort) & patten.sort) == patten.sort         
      end      
    end 
    return ""
  end

  def display_result
    (!winner.empty?) ? (puts " The winner is '#{winner}'") : (puts " Draw Game.")  
  end

  def display_board 
      system "clear"
      puts   "   << TicTacToe >> #{@players[0].name} V.S #{@players[1].name}"
      puts   ""
      printf "    'O'        'X' \n"
      printf "    \\|/       --|-- \n"
      printf "    / \\  V.S   / \\ \n"
      puts   ""           
      printf "  %3s  |%3s  |%3s  \n",@squares[1].display,@squares[2].display,@squares[3].display
      puts   "  -----+-----+-----\n"
      printf "  %3s  |%3s  |%3s  \n",@squares[4].display,@squares[5].display,@squares[6].display
      puts   "  -----+-----+-----\n"
      printf "  %3s  |%3s  |%3s  \n",@squares[7].display,@squares[8].display,@squares[9].display      
      puts   
      ""                  
  end

  def clear_squares
    @squares.each { |i,s| s.clear }  
    @players.each { |player| player.picked_squares.clear }
  end

  def create_players
    system "clear"
    puts "------------------------------------"        
    puts "Welcome to TicTacToe Game ^_^y"
    puts "I am Daniel and nice to meet you."    
    r_array = []
    while true
      printf "Please tell me what's your name ? "
      name = gets.chomp       
      if !name.empty?
        puts "------------------------------------"                    
        r_array << Player.new(name,:human)        
        break
      end
    end   
    r_array << Player.new("Daniel",:computer)         
  end

  def create_squares  
    r_hash = {}
    (@board_size ** 2).times { |i| r_hash[i+1] = Square.new(Marker.new) }
    r_hash
  end
end

class Game
  attr_reader :my_board

  def initialize
    @my_board = Board.new(3)    
  end

  def play
    while true
      @my_board.start_new_game
      break if @my_board.is_exit_or_play_again
    end 
  end
end

# here we go ======>
Game.new.play
#==================>
