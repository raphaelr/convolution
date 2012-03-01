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
			@response = Array.new(response_impulses, 0)
			@output = Array.new(samples+response_impulses, 0)
		end
		
		def update
			resp = @response
			resp = resp.reverse if @mode == :correlation
			
			@output.fill(0)
			(0...@samples).each do |i|
				(0...@response_impulses).each do |r|
					@output[i + r] += @input[i] * resp[r]
				end
			end
		end
	end
end
