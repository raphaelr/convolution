module Convolution
	class WaveformLegend
		include Rubygame
		include Sprites::Sprite
		
		attr_reader :parent
		attr_accessor :font
		
		def initialize(parent, options = {})
			@parent = parent
			@font = options[:font]
			@labels = options[:labels] || Color[:black]
			@image = Surface.new([@parent.image.width, @parent.image.height], 32, [HWSURFACE])
		end
		
		def y_labels
			[0, @parent.peak, -@parent.peak]
		end
		
		def float_s(f)
			((f*100).truncate / 100.0).to_s
		end
		
		def update
			@image.fill(@parent.background)
			@rect = @parent.rect.dup
			@rect.x -= y_labels.collect { |y| @font.size_text(float_s(y))[0] }.max
			
			y_labels.each do |y|
				text = @font.render(float_s(y), true, @labels)
				text.blit(@image, [0, @parent.image_y(y) - text.height/2])
			end
		end
	end
end
