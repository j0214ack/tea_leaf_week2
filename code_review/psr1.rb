class Player
  attr_accessor :choice
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Human < Player
  def picks_hand
    begin
      puts "\nEnter \'r\' for rock, \'p\' for paper, or \'s\' for scissors."
      puts
      self.choice = gets.chomp.downcase
    end until Game::OPTIONS.keys.include?(choice)
  end
end

class Computer < Player
  def picks_hand
    self.choice = Game::OPTIONS.keys.sample
  end
end

class Game
  OPTIONS = { 'r' => 'rock', 'p' => 'paper', 's' => 'scissors' }

  attr_reader :player, :computer

  def initialize
    @player = Human.new('You')
    @computer = Computer.new('The computer')
  end

  def intro
    system 'clear'
    puts "\nPlay Rock-Paper-Scissors!"
    puts "\nRock breaks scissors, paper covers rock, and scissors cuts paper."
  end

  def message(winning_hand)
    case winning_hand
    when 'r'
      puts "\nRock breaks scissors!"
    when 'p'
      puts "\nPaper wraps rock!"
    when 's'
      puts "\nScissors cuts paper!"
    end
  end

  def compare
    if player.choice == computer.choice
      puts "\nYou tied! You both chose #{OPTIONS[(computer.choice)]}."
    elsif (player.choice == 'r' && computer.choice == 's') ||
          (player.choice == 's' && computer.choice == 'p') ||
          (player.choice == 'p' && computer.choice == 'r')
      puts "\nYou chose #{OPTIONS[(player.choice)]} and the" \
           " computer chose #{OPTIONS[(computer.choice)]}."
      message(player.choice)
      puts "\nYou won!"
    else
      puts "\nYou chose #{OPTIONS[(player.choice)]} and the" \
           " computer chose #{OPTIONS[(computer.choice)]}."
      message(computer.choice)
      puts "\nThe computer won!"
    end
  end

  def replay
    play_again_choice = 'n'

    while play_again_choice != 'y'
      puts "\nWould you like to play again? (Y/N)"
      puts

      play_again_choice = gets.chomp.downcase

      unless %w(y n).include?(play_again_choice)
        puts "\nError. Invalid entry. Please enter either 'y' or 'n'."
        next
      end

      if play_again_choice == 'y'
        Game.new.play
      elsif play_again_choice == 'n'
        puts "\nThanks for playing!"
        exit
      end
    end
  end

  def play
    intro
    player.picks_hand
    computer.picks_hand
    compare
    replay
  end
end

Game.new.play

