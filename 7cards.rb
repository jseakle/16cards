class Card

	def self.deck
		[CardOne.new, CardTwo.new, CardThree.new, CardFour.new, CardFive.new, CardSix.new, CardSeven.new]
	end

	def initialize
		@sets = {
			:red => [:red1, :red2, :red3],
			:blue => [:blue1, :blue2, :blue3]
		}
	end

	def setup(state)

	end

	def colors
		{}
	end

	def execute(state, frontend)

	end

	def my_tableau(state)
		Hash[state[:tableaus][state[:player].map {|c| [c.id, c]}]
	end

	def their_tableau(state)
		Hash[state[:tableaus][state[:player] == :one ? :two : :one].map {|c| [c.id, c]}]
	end

	def my_colors(state)
		ret = []
		my_tableau(state).each {|id, card|
			ret += card.colors
		end
		return ret
	end

	def their_colors(state)
		ret = []
		my_tableau(state).each {|id, card|
			ret += card.colors
		end
		return ret
	end


	def complete_set(colors)
		sets = @sets
		colors.each {|set, color|
			sets[set].delete(color)
			if sets[set].empty?
				return true
			end
		}
		false
	end

	def color_merge(one, two)
		ret = one
		two.each {|set, color|
			ret[set] << color
		}
		return ret
	end

end

class CardOne < Card

	def id
		1
	end

	def colors
		{red: [:red1], blue: [:blue3]}
	end

	def setup(state)
		state[:restrictions] << ->(card, future_state) {
			if card == self
				raise Restriction.new "You have colors, so you can only draft 1 if you will win." unless my_colors(future_state).empty? or complete_set(color_merge(my_colors(future_state), colors))

			end
		}
	end
end

class CardTwo < Card
	def id
		2
	end

	def colors
		{ :red => [:red2] }
	end

	def execute(state, frontend)
		choice = frontend.prompt("Choose a card to ban.", state[:pool].keys)
		state[:restrictions] << ->(card, future_state) {
			raise Restriction.new "That card is banned!" if card.id = choice and future_state[:turn] == state[:turn] + 1
		}
	end
end

class CardThree < Card
	def id
		3
	end
	
	def setup(state)
		state[:restrictions] << ->(card, future_state) {
			if card == self
				raise Restriction.new "Must be drafted after 6." if future_state[:pool].key? 6
			end
	end

	def colors 
		{
			:red => [:red3],
			:blue => [:blue1],
		}
	end

	def execute(state, frontend)
		state[:restrictions] << ->(card, future_state) {
			if future_state[:turn] == state[:turn] + 1
				if card.id > their_tableau.last.id
					raise Restriction.new "You must draft a smaller number than your previous."
				end
			end
		}
	end
end

class CardFour < Card
	def id
		4
	end

	def colors 
		{
			red: [:red3],
			blue: [:blue2],
		}
	end
	
	def execute(state, frontend)
		state[:restrictions] << ->(card, future_state) {
			if [1,3].include? card.id
				if future_state[:turn] <= state[:turn] + 2
					raise "3 and 1 cannot be drafted this turn cycle."
				end
			end
		}
	end
end

class CardFive < Card
	
	def id
		5
	end
	
	def execute(state, frontend)
	end
	
end

class CardSix < Card
	
	def id
		6
	end
	
	def execute(state, frontend)
	end
	
end

class CardSeven < Card
	
	def id
		7
	end
	
	def execute(state, frontend)
	end
	
end
