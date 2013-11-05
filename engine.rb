require_relative 'exceptions'

class Engine

	def initialize(cards, impl)
		#impl is hash from int to card object
		@pool = cards
		@current = :one
		@frontend = impl
		@tableaus = {:one => [], :two => []}
		@restrictions = []
		@turn = 1

		@pool.each { |id, card| card.setup(state) }
	end

	def run
		@frontend.update(state)
		while @pool
			begin
				card = @frontend.get_move(@current)
				draft(card, @current)
				@frontend.update(state)
			rescue PlayError => e
				@frontend.message(e.message)
			rescue Win
				@frontend.win(@current)
			else
				end_turn
			end
		end		
	end

	def draft(card, player)
		raise PlayError.new "That card has already been drafted!" unless @pool[card]

		raise PlayError.new "That card cannot be drafted right now!" unless draftable(@pool[card])
		
		@tableaus[@current] << @pool.delete(card)
		@frontend.update(state)
		@tableaus[@current][-1].execute(state, @frontend)
	end

	def draftable(card)
		passed = true
			@restrictions.each { |r|
			begin
				r.call(card, state)
			rescue Restriction => r
				@frontend.message(r.message)
				passed = false
			end
			}
		passed
	end

	def state
		{
			:player => @current,
			:tableaus => @tableaus,
			:pool => @pool,
			:restrictions => @restrictions,
			:turn => @turn,
		}
	end
	
	def end_turn
		@current = @current == :one ? :two : :one
		@turn += 1
	end
	
end
