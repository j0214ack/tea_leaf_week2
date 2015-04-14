require 'pry'

class Player
  attr_accessor :marker, :name

  def initialize(marker,name)
    @marker = marker
    @name = name
  end

  def select_a_slot(board,opponent)
    raise "Method not defined"
  end

  def to_s
    @name
  end
end

class Human < Player
  def select_a_slot(board,opponent)
    begin
      puts "Hello, #{@name}! Your marker is #{@marker}"
      puts "Please mark an empty slot#{board.empty_slots_nums.map{|n| n+1}.inspect}: "
      player_choice = gets.chomp
    end until valid_choice?(player_choice,board)
    player_choice.to_i - 1
  end

  private

  def valid_choice?(choice,board)
    return false if choice.match(/[1-9]/).nil?
    slot_num = choice.to_i - 1
    return board.empty_slots_nums.include? slot_num
  end
end

class Computer < Player
  def select_a_slot(board,opponent)
    priorities = {}
    board.empty_slots_nums.each do |slot_num|
      priorities[slot_num] = assign_priority(slot_num,board,opponent)
    end
    puts "#{name} is thinking..."
    sleep(2)
    priorities.max_by{|k,v| v}[0]
  end

  private

  def assign_priority(slot_num,board,opponent)
    weight = 0
    all_rows = board.all_rows
    rows_have_the_slot = all_rows.select{|row| row.include? slot_num}.map{|row| Row.new(row, board)}
    non_blocked_player_rows = 0
    non_blocked_computer_rows = 0
    empty_rows = 0
    
    rows_have_the_slot.each do |row|
      two_in_a_row = row.two_in_a_row
      # 1. make himself complete three-in-a-row
      if two_in_a_row == self.marker
        weight += 100000

      # 2. block player's two-in-a-row
      elsif two_in_a_row == opponent.marker
        weight += 10000

      else
        # check if the row is a non-blocked row
        if row.empty?
          empty_rows += 1
        elsif row.non_blocked_marker == self.marker
          non_blocked_computer_rows += 1
        elsif row.non_blocked_marker == opponent.marker
          non_blocked_player_rows += 1
        end
      end
    end # end of rows_that_have_the_slot

    # 3. prevent player's future double two-in-a-row
    # 4. make his own double two-in-a-row
    if non_blocked_player_rows >= 2
      weight += 1000
    elsif non_blocked_computer_rows >= 2
      weight += 100
    end

    # 5. non-blocked computer rows' slot (10 points)
    weight += non_blocked_computer_rows * 10
    # 6. if the row is totally empty (5 points)
    weight += empty_rows * 5
    # 7. middle over corners over sides (2,1,0)
    if slot_num == 4 # middle
      weight += 2
    elsif [0,2,6,8].include? slot_num
      weight += 1
    end
    weight
  end
end

class Slot
  attr_reader :value

  def initialize(value = ' ')
    @value = value
  end

  def ==(other_slot)
    value == other_slot.value
  end

  def hash
    value.ord
  end

  def eql?(other_slot)
    self == (other_slot)
  end

  def empty?
    value == ' '
  end

  def fill!(marker)
    @value = marker
    nil
  end

  def marker
    value
  end

  def to_s
    value
  end
end

class Row
  attr_accessor :slots

  def initialize(slot_nums,board)
    @slots = slot_nums.map{|position| board.slots[position]}
  end

  def empty?
    result = true
    slots.each do |slot|
      result = false unless slot.empty?
    end
    result
  end

  def three_in_a_row
    result = nil
    filled_slots = slots.dup.reject{|slot| slot.empty?}
    if filled_slots.size == 3 && filled_slots.uniq.size == 1
      result = filled_slots[0].marker
    end
    result
  end

  def non_blocked_marker
    result = nil
    result = slots.reject{|slot| slot.empty?}[0].marker if slots.count(Slot.new(' ')) == 2
  end

  def two_in_a_row
    result = nil
    filled_slots = slots.dup.reject{|slot| slot.empty?}
    if filled_slots.size == 2 && filled_slots.uniq.size == 1
      result = filled_slots[0].marker
    end
    result
  end
end

class TicTacToeBoard
  attr_accessor :slots, :all_rows

  def initialize
    @slots = []
    9.times do |i|
      @slots << Slot.new(' ')     
    end
    @all_rows = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
  end

  def draw
    puts 
    puts " #{@slots[0]} | #{@slots[1]} | #{@slots[2]} "
    puts "-----------"
    puts " #{@slots[3]} | #{@slots[4]} | #{@slots[5]} "
    puts "-----------"
    puts " #{@slots[6]} | #{@slots[7]} | #{@slots[8]} "
    puts 
  end

  def marker_at(slot_num)
    slots[slot_num].marker
  end

  def all_slot_marked?
    empty_slots_nums.size == 0
  end


  def empty_slots_nums
    Array(0..8).select{|i| slots[i].empty?}
  end

  def empty_slot?(slot_num)
    slots[slot_num].empty?
  end

  def fill_slot!(slot_num,marker)
    slots[slot_num].fill!(marker)
    nil
  end
end

class Game

  def initialize
    @players = []
    @board = TicTacToeBoard.new
    @current_player = nil
    @idle_player = nil
    @winner = nil
  end

  def run
    system "clear"
    puts "Welcome to Tic Tac Toe!"
    puts

    begin
      initialize
      set_players

      @current_player = @players[0]
      @idle_player = @players[1]

      begin
        system "clear"
        @board.draw
        player_choice = @current_player.select_a_slot(@board,@idle_player)
        @board.fill_slot!(player_choice, @current_player.marker)
        check_winner(player_choice, @current_player)
        switch_turn
        # Todo here
      end until @winner || @board.all_slot_marked?

      system "clear"
      @board.draw
      show_result

      puts "Play again?(y/n)"
    end while gets.chomp.downcase == 'y'
  end

  private

  def show_result
    if @winner
      puts "#{@winner} won!"
    else
      puts "It's a tie"
    end
  end

  def switch_turn
    temp = @current_player
    @current_player = @idle_player
    @idle_player = temp
    nil
  end

  def check_winner(slot_num, player)
    @board.all_rows.select{|row| row.include? slot_num}.each do |row|
      @winner = player if Row.new(row, @board).three_in_a_row == player.marker 
    end
    nil
  end

  def set_players
    begin
      puts "Who is player1 ?"
      puts "1) Human 2) Computer"
      player1 = gets.chomp
    end until %w(1 2)
    begin
      puts "Who is player2 ?"
      puts "1) Human 2) Computer"
      player2 = gets.chomp
    end until %w(1 2)

    player1 == '1' ? @players << Human.new('o','player1') : @players << Computer.new('o','player1')
    player2 == '1' ? @players << Human.new('x','player2') : @players << Computer.new('x','player2')
    nil
  end
end

Game.new.run
