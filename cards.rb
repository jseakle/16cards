class Card

	def setup(state)

	end

	def execute(state, frontend)

	end
end

class CardOne < Card

	def id
		1
	end

	def execute(state, frontend)
		if state[:tableaus][state[:player]].select {|c| c.id == 2}.any?
			raise Win.new "Collected one and two!"
		end
		state[:restrictions] << ->(card, future_state) {  
			if future_state[:turn] == state[:turn] + 1 and card.id == 3
				raise Restriction.new "Can't draft 3 after 1"
			end
		}
		frontend.message("Now you just need 2 to win!")
	end

end

class CardTwo < Card
	
	def setup(state)
		state[:restrictions] << ->(card, future_state) {
			if future_state[:turn] == 1 and card.id == id
				raise Restriction.new "Can't draft 2 on the first turn"
			end
		}
	end
	
	def id
		2
	end

end

class CardThree < Card
	
	def id
		3
	end
	
	def execute(state, frontend)
		choice = frontend.prompt("Do you want to win? ")
		raise Win.new "A wise decision." if choice.downcase.start_with? 'y'
		
	end
	
end

