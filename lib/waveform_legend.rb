module Convolution
	class WaveformLegend
		include Rubygame
		include Sprites::Sprite
		
		def initialize(parent, options = {})
			@parent = parent
			update
		end
		
		def y_labels
			[0, @parent.peak, -@parent.peak]
		end
		
		def draw(target)
		end
		
		def update
			@image = Surface.new([@parent.image.width, @parent.image.height])
		end
	end
end
