class Player
  attr_accessor :choice
  attr_reader :name

  def initialize (n)
    @name = n
  end

  def to_s
    "#{ name } chose #{ choice.capitalize }"
  end
end

class Human < Player
  system "clear"
  attr_accessor :name

  def set_name
    puts "Let\'s play Rock-Paper-Scissors!"
    puts "What\'s your name?"
    self.name = gets.chomp
  end

  def pick_item
    begin
      system "clear"
      puts "Please type: rock, paper or scissors"
      self.choice = gets.chomp.downcase
    end until RockPaperScissors::ITEMS.include?(choice)
  end
end

class Computer < Player
  def pick_item
    self.choice = RockPaperScissors::ITEMS.sample
  end
end


class RockPaperScissors
  ITEMS = [ "rock", "paper", "scissors" ]

  attr_reader :player, :computer

  def initialize
    @player = Human.new(' ')
    @computer = Computer.new('Computer')
  end

  def compare_items

    scenario = {
      rock: {
        rock:     "Tied!",
        paper:    "Paper smothers Rock! #{ computer.name } wins!",
        scissors: "Rock crushes Scissors! #{ player.name } wins!"
      },
      paper: {
        rock:     "Paper smothers Rock! #{ player.name } wins!",
        paper:    "Tied!",
        scissors: "Scissors cut Paper! #{ computer.name } wins!"
      },
      scissors: {
        rock:     "Rock crushes Scissors! #{ computer.name } wins!",
        paper:    "Scissors cut Paper! #{ player.name } wins!",
        scissors: "Tied!"
      }
    }

    system "clear"    
    puts player
    puts computer
    puts "\n"
    puts scenario[player.choice.to_sym][computer.choice.to_sym]
  end

  def play
    player.set_name

    loop do
      player.pick_item
      computer.pick_item
      compare_items
      begin
        puts "\n"
        puts "Play again? [y/n]"
        play_again = gets.chomp.downcase
      end until play_again.eql?("y") || play_again.eql?("n")
      break if play_again != "y"
    end

    system "clear" 
    puts "Thanks for playing!"
  end
end

game = RockPaperScissors.new.play

