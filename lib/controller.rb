module Convolution
	class Controller
		attr_reader :input, :response, :output
		
		def initialize(samples, response_impulses, peak)
			@samples = samples
			@response_impulses = response_impulses
			@peak = peak
			
			@input = (0...@samples).collect { |x| @peak*Math.sin(ExMath.period_f * x) }
			@response = Array.new(samples, 0)
			@output = Array.new(samples+response_impulses, 0)
		end
		
		def update
			@output.fill(0)
			(0...@samples).each do |i|
				(0...@response_impulses).each do |r|
					@output[i + r] += @input[i] * @response[r]
				end
			end
		end
	end
end
