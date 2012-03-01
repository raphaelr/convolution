module Convolution
	module ExMath; end
	class << ExMath
		include Math
		
		attr_accessor :samples
		attr_accessor :response_impulses
		attr_accessor :peak
		
		def get_binding
			binding
		end
		
		def period_f
			2*PI/samples
		end
		
		def sinc(t)
			y = sin(PI*t)/PI/t
			y.nan? ? 1.0 : y
		end
		
		def square(t)
			s = sin(t)
			s == 0 ? 1 : s / s.abs
		end
		
		def cutoff(limit, t, x)
			t > limit ? 0 : x
		end
		
		def noise
			2*peak*rand-peak/2
		end
	end
end
