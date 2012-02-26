module Convolution
	class Text
		include Rubygame
		include Sprites::Sprite
		
		def initialize(font, text, rect)
			super()
			@image = font.render(text, true, Color[:black])
			@rect = rect
		end
		
		def draw(target)
			@image.blit(target, @rect)
		end
		
		def update
		end
	end
end
