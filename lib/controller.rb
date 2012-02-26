module Convolution
	class Controller
		attr_reader :input, :response, :output
		attr_reader :mode
		
		MODES = [:convolution, :correlation]
		def mode=(new_mode)
			raise ArgumentError, "mode must be one of #{MODES.join(", ")}" unless MODES.include? new_mode
			@mode = new_mode
		end
		
		def initialize(samples, response_impulses, peak)
			@samples = samples
			@response_impulses = response_impulses
			@peak = peak
			@mode = :convolution
			
			@input = (0...@samples).collect { |x| @peak*Math.sin(ExMath.period_f * x) }
			@response = Array.new(samples, 0)
			@output = Array.new(samples+response_impulses, 0)
		end
		
		def update
			@output.fill(0)
			(0...@samples).each do |i|
				(0...@response_impulses).each do |r|
					response_index = case @mode
						when :convolution then r
						when :correlation then @response_impulses - r - 1
					end
					@output[i + r] += @input[i] * @response[response_index]
				end
			end
		end
	end
end
