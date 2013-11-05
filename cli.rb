require_relative 'engine'
require_relative '7cards'
require_relative 'exceptions'

class CLI

	def initialize
		@cards = Card.deck
	end

	def run
		e = Engine.new(@cards, self)
		e.run
	end
	
	def update(state)
		
		p state[:pool].map {|id, c| id}

		puts "Player one has #{state[:tableaus][:one].map { |card| card.id} }"
		puts "Player two has #{state[:tableaus][:two].map { |card| card.id} }"

	end

	def get_move(player)
		puts "Player #{player.to_s}, please draft a card."
		[(print '> '), gets.chomp.to_i][1]
	end

	def win(player)
		puts "Player #{player.to_s} wins!"
		exit
	end

	def message(msg)
		puts msg
	end

	def prompt(msg, choices)
		choice = nil
		until choices.include? choice
			choice = [(print msg + "\n#{choices}> "), gets.chomp][1] 
		end
		choice
	end
	

end

CLI.new.run
