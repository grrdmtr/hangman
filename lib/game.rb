require "pry-byebug"
require "json"

class Game
  attr_accessor :word, :result, :incorrect, :attempt

  def initialize(word = get_word(), result = Array.new(word.length) {' _ '}, incorrect = [' '], attempt = 12)
    @word = word
    @result = result
    @incorrect = incorrect
    @attempt = attempt
  end
  
  def to_json
    JSON.dump ({
      :word => @word,
      :result => @result,
      :incorrect => @incorrect,
      :attempt => @attempt
    })
  end

  def self.from_json()
    data = JSON.load(File.read("../game_save.json"))
    game = Game.new(
      data['word'],
      data['result'],
      data['incorrect'],
      data['attempt']
    )
  end

  def get_word
    dictionary = []
    File.open("../5desk.txt", "r") do |file|
      file.readlines.each do |line|
        if line.strip.length.between?(5, 12)
          dictionary.push(line.strip)
        end
      end
    end
    p dictionary.sample.upcase
  end

  def start_new_game
    puts "PRESS 1 FOR NEW GAME
PRESS 2 TO LOAD SAVED GAME
PRESS 3 TO EXIT"
    answer = gets.chomp.to_i

    until answer.between?(1,3)
      answer = gets.chomp.to_i
    end

    if answer == 1
      game_loop()
    elsif answer == 2
      game = Game.from_json
      game.game_loop
    elsif answer == 3
      exit
    end
  end

  def game_loop
    until @attempt == 0
      if @attempt != 12
        puts "
        You have #{@attempt} more attempts
        "
      elsif @attempt == 0
        puts "Game OVER!" 
      end
      
      puts 'Enter your guess:
      '
      guess = make_guess()
      check_answer(@word, guess)
      display_result()
    end
  end

  def make_guess
    answer = gets.chomp.upcase
  end

  def display_result
    if @result.join == @word
      puts @result.join
      puts 'Congratulations!'
      start_new_game()
    else
      puts @result.join(' ')
      puts "incorrect letters: #{@incorrect.join(' | ')}"
      @attempt -= 1
      save_game?()
    end
  end

  def save_game?
    puts "Do you want to save game? Y - yes, N - no"
    answer = gets.chomp.upcase

    if answer == 'Y'
      File.open("../game_save.json", "w") { |file| file.write(to_json()) }
      
      puts "Do you want to continue? Y - yes, N - no"
      answer = gets.chomp.upcase
      if answer != 'Y'
        start_new_game()
      end
    end
  end

  def check_answer(word, guess)
    word.split('').each_with_index do |letter, i|
      guess.split('').each do |l|  
        if letter == l
          @result[i] = letter
        elsif !(word.include?(l))
          @incorrect.push(l)
          @incorrect = @incorrect.uniq
        end
      end
    end
  end

end

game = Game.new
game.start_new_game
