# Rock, paper scissors with OOP

class Choice
  attr_accessor :type

  # default setting of choice_types
  @@choice_types = %w(Scissors Paper Rock)

  def self.set_choice_types(choice_types)
    raise "Too few choice type!" if choice_types.size < 3
    @@choice_types.clear
    @@choice_types = choice_types
  end

  def self.all_types
    @@choice_types
  end

  def initialize(choice = nil)
    if choice.nil?
      @type = @@choice_types.sample
    elsif choice.between?(0,@@choice_types.size - 1)
      @type = @@choice_types[choice]
    else
      raise "Not a valid type of choice!"
    end
  end

  def >(other_choice)
    choice_order = @@choice_types.index(self.type)
    other_choice_order = @@choice_types.index(other_choice.type)
    if (choice_order + 1 == other_choice_order) ||
       (@@choice_types.size - 1 == choice_order && other_choice_order == 0)
      true
    else
      false
    end
  end

  def ==(other_choice)
    type == other_choice.type
  end

  def ties?(other_choice)
    !(self > other_choice) && !(other_choice > self)
  end

  def <=>(other_choice)
    if (self.ties? other_choice)
      0
    elsif self > other_choice
      1
    else
      -1
    end
  end

  def to_s
    type
  end
end

class Game
  attr_accessor :winner, :players

  def initialize
    @players = [] # an array of players
    @winner = nil
  end

  def run
    system "clear"
    puts "Welcome to #{Choice.all_types.join(", ")}!"
    puts 
    puts "Do you want to customize your own game?(y/n)"
    if gets.chomp.downcase == 'y'
      system "clear"
      customize_game
    else
      system "clear"
      set_all_players(1,1)
    end

    begin
      round
      puts 
      puts "Do you want to play again?(y/n)"
    end while gets.chomp.downcase == 'y'
  end

  private

  def customize_game
    customize_choices
    customize_players
  end

  def round
    players.each do |player|
      system "clear"
      puts "#{player.name}, please make a choice!"
      puts
      player.make_choice!
    end
    show_result(decide_winners(players))
  end

  def customize_choices
    choices = []
    puts "You can customize your own game by inputing 3 or more choices."
    puts
    puts "Winning rules are decided by input order:"
    puts "=> 1st wins 2nd, the 2nd wins 3rd,...etc. And the last one wins the 1st one"
    puts
    puts "Please start entering: (enter DONE when finished)"
    loop do
      choice = gets.chomp.strip
      if choices.include? choice
        puts "You already have this type of choice, please enter another one."
        next
      end
      if choice == "DONE"
        if choices.size < 3
          puts "Too few choices! Please enter #{3 - choices.size} more!"
          next
        else
          break
        end
      end
      choices << choice
    end
    Choice.set_choice_types(choices)
  end

  def customize_players
    begin
      begin
        puts "How many human players?"
        human_players = gets.chomp
      end until human_players.match /^\d+$/
      begin
        puts "How many computer players?"
        computer_players = gets.chomp
      end until computer_players.match /^\d+$/
    end until ((human_players.to_i + computer_players.to_i >= 2) ||
               (puts "There must be at least 2 players to play!"))
    set_all_players(human_players.to_i, computer_players.to_i)
  end

  def set_human_players(num = 1)
    num.times do |n|
      puts "What is the player#{n+1}'s name?"
      players << Human.new(gets.chomp.strip)
    end
  end

  def set_computer_players(num = 1)
    num.times do |i|
      players << Computer.new("Computer#{i+1}")
    end
  end

  def set_all_players(human_players, computer_players)
    set_human_players(human_players)
    set_computer_players(computer_players)
  end

  def show_result(winners)
    players.each do |player|
      puts "#{player.name} chose #{player.choice}!"
    end
    if winners == nil
      puts "It's a tie!"
    else
      puts "#{winners.map{|w| w.name}.join(', ')} won!"
    end
  end

  def decide_winners(players)
    if players.size > 2
      all_choice = players.map{|p| p.choice}.flatten
      result = nil if all_choice.size == 1 || all_choice >= 3
      if all_choice[0] > all_choice[1]
        result = players.select {|player| player.choice == all_choice[0]}
      else
        result = players.select {|player| player.choice == all_choice[1]}
      end
    elsif players.size == 2
      case players[0].choice <=> players[1].choice
      when 1
        result = [players[0]]
      when -1
        result = [players[1]]
      when 0
        result = nil
      end
    else
      raise "Weird players size: #{players.size}"
    end
    result
  end
end

class Player
  attr_accessor :name, :choice

  def initialize(name)
    @name = name
    @choice = nil
  end

  def make_choice!
    raise "Method not implemented!"
  end
end

class Computer < Player
  def make_choice!
    puts "Computer: Wait a second..."
    sleep(1)
    self.choice = Choice.new   
  end
end

class Human < Player
  def make_choice!
    player_choice = nil
    loop do
      choices = ""
      Choice.all_types.each_with_index do |choice,index|
        choices += "#{index+1}) #{choice} "
      end
      puts choices
      player_choice = gets.chomp
      if (player_choice.match /^\d+/) && player_choice.to_i.between?(1,choices.size)
        break
      end
    end
    self.choice = Choice.new(player_choice.to_i - 1)
  end
end

Game.new.run
