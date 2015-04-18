require 'pry'

class Player
  attr_accessor :hand, :money, :bets, :name, :leaving
  
  def initialize
    puts "What's your name?"
    name = gets.chomp.strip

    puts "How much money do you have?"
    begin
      money = gets.chomp
    end until money.match /^\d+$/

    @hand = Hand.new
    @bets = 0
    @money = money.to_i
    @name = name
    @leaving = false
  end

  def hit_or_stand
    begin
      puts "Do you wish to 1) hit or, 2) stand?"
      choice = gets.chomp
    end until %w(1 2).include? choice
    choice == '1' ? 'h' : 's'
  end

  def bet(amount)
    self.money -= amount
    self.bets = amount
  end

  def return_bet
    puts "#{name} made a push with dealer. #{name} gets #{bets} dollars back."
    self.money += bets
    self.bets = 0
  end

  def win
    puts "#{name} won! #{name} gets #{bets * 2} dollars back."
    self.money += bets * 2
  end
end

class Dealer
  attr_accessor :hand

  def initialzie
    @hand = Hand.new
  end

  def hit_or_stand
    hand.value < 17 ? 'h' : 's'
  end

  def say(sentence)
    puts "=> #{sentence}"
  end
end

class Card
  SUITS = {s: "♠", h: "♥", d: "♦", c: "♣"}
  FACES = %w(A 2 3 4 5 6 7 8 9 T J Q K)
  attr_accessor :suit, :face

  def initialize(card_info)
    @suit = card_info[0]
    @face = card_info[1]
  end

  def to_s
    "🂠 #{SUITS[suit]}#{face}"
  end

  def to_points
    case face
    when 'J', 'Q', 'K'
      10
    when 'A'
      1
    else
      FACES.index(face) + 1
    end
  end
end

class Deck
  attr_accessor :cards, :deck_num

  def new_deck
    a_deck = Card::SUITS.keys.product(Card::FACES).map do |card|
      Card.new(card)
    end
    a_deck *= deck_num
    a_deck.shuffle
  end

  def initialize(deck_num)
    @deck_num = deck_num
    @cards = new_deck
  end

  def deal_a_card
    cards.pop
  end

  def shuffle!
    cards.shuffle!
  end

  def reset!
    self.cards = new_deck
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def add_a_card(card)
    self.cards << card
  end

  def show(hide_fisrt_card = true)
    cards_strings = cards.map{ |card| card.to_s }
    cards_strings[0] = "🂠 ??" if hide_fisrt_card
    cards_strings.join(" | ")
  end

  def clear
    cards.clear
  end

  def <<(card)
    add_a_card(card)
  end

  def blackjack?
    cards.size == 2 && total_points == 21 
  end

  def total_points
    result = 0
    aces = 0
    cards.each do |card|
      result += card.points
      aces += 1 if card.points = 1
    end
    result += 10 if (aces != 0 && (result + 10 <= 21))
    result 
  end

  def [](num)
    cards[num]
  end
end

class GameTable
  attr_accessor :dealer, :players, :deck
  MAXIMUM_PLAYERS = 6

  def initialize(deck_num = 4)
    @dealer = Dealer.new
    @players = []
    @deck = Deck.new(deck_num)
  end

  def reset_table!
    deck.reset!
    dealer.hand.clear
    players.clear
  end

  def play
    loop do
      system "clear"
      dealer.say "Welcome to the Great Casino, how many players are going play? Max is #{MAXIMUM_PLAYERS}"
      begin
        players_num = gets.chomp
      end until players_num.match(/^\d$/) && players_num.to_i <= MAXIMUM_PLAYERS

      players_num.to_i.times do |i|
        puts 
        dealer.say "I've got questions for player#{i + 1}"
        players << Player.new 
      end

      begin
        start_a_round
      end until players.empty?

      dealer.say "All players are gone."
      dealer.say "Do you want to start a new table? (y/n)"
      if gets.chomp.downcase == 'y'
        reset_table
      else
        break
      end
    end
  end

  def start_a_round
    binding.pry
    dealer.hand.clear
    players.each do |player| 
      player.hand.clear
      dealer.say "#{player.name}, how much do you want to bet? Bet 0 to leave this table."
      begin
        amount = gets.chomp
      end until amount.match /^\d+$/ && amount.to_i.between?(0, money)
      if amount.to_i == 0
        player.leaving = true
      else
        player.bet(amount.to_i)
      end
    end
    players.reject!{ |player| player.leaving }

    if players.size > 0
      2.times do
        dealer.hand << deck.deal_a_card
        players.each{ |player| player.hand << deck.deal_a_card }
      end

      draw_table

      someone_has_blackjack = false
      if dealer.hand.blackjack?
        players.each { |player| player.return_bet if player.hand.blackjack? }
        someone_has_blackjack = true
      else
        players.each do |player|
          player.win if player.blackjack? 
          someone_has_blackjack = true
        end
      end

      if someone_has_blackjack
        draw_table(false)
        dealer.say "Some one has black jack!"
      else
        # players' turn
        players.each do |player|
          until make_choice(player) == 's' || player.hand.busted? 
            draw_table
          end
        end # players.each

        # dealer's turn
        if players.reject{ |player| player.hand.busted? }.empty?
          dealer.say "Everyone is busted! Well done, let's go to next round."
        else
          until make_choice(dealer) == 's' || dealer.hand.busted?
            draw_table(false)
          end
        end
      end

      players.reject{ |player| player.hand.busted? }.each do
        if dealer.hand.busted?
          player.win
        else
          player.win if dealer.hand.total_points < player.hand.total_points
          player.return_bet if dealer.hand.total_points == player.hand.total_points
        end
      end

      players.reject! do |player|
        bankrupt = (player.money == 0)
        dealer.say "Sorry, #{player.name}. You don't have money anymore. Get out of here!" if bankrupt
        bankrupt
      end
    end
  end

  def make_choice(player)
    choice = player.hit_or_stand
    case choice
    when 'h'
      player.hand << deck.deal_a_card
      'h'
    when 's'
      's'
    end # case
  end

  def draw_table(hide_first_dealer_card)
    system "clear"
    puts "  Dealer"
    puts "  hands: #{dealer.hand.show(hide_first_dealer_card)}"
    players.each do |player|
      puts 
      puts "  Name: #{player.name} Money: $#{player.money} Bet: $#{player.bets}"
      puts "  Hands: #{player.hand.show}  Total: #{player.hand.total_points}"
    end
  end

end

GameTable.new.play
