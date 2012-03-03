module Convolution
	class Waveform
		include Rubygame
		include EventHandler::HasEventHandler
		include Sprites::Sprite
		
		attr_accessor :name, :focus, :controllable, :ystep
		attr_accessor :peak
		attr_accessor :amplitudes
		
		attr_accessor :background, :grid, :point, :active
		
		def initialize(options = {})
			super()
			
			@name = options[:name] || "q"
			@samples = options[:samples] || 10
			@peak = options[:peak] || 1.0
			@ystep = options[:ystep] || @peak / @samples
			@hspace = options[:hspace] || 10
			@boxwidth = options[:boxwidth] || @hspace/2 - 1
			@boxheight = options[:boxheight] || 5
			@width = options[:width] || @hspace*@samples
			@height = options[:height] || 30*@boxheight
			@height += 2*@boxheight
			
			@focus = false
			@controllable = true
			@selected_sample = 0
			
			@image = Surface.new([@width, @height], 24, [HWSURFACE])
			@rect = Rect.new([0, 0, @width, @height])
			
			@background = options[:background] || Color[:white]
			@grid = options[:grid] || Color[:silver]
			@point = options[:point] || Color[:blue]
			@active = options[:active] || Color[:red]
			
			@amplitudes = Array.new(@samples, 0)
			@legend = WaveformLegend.new(self, options)
			make_magic_hooks(:left => :move_left, :right => :move_right, :up => :move_up, :down => :move_down)
			make_magic_hooks(:mouse_left => :recheck_focus, :mouse_right => :load_equation) if @controllable
		end
		
		def move_left
			@selected_sample = [0, @selected_sample-1].max if @controllable && @focus
		end
		
		def move_right
			@selected_sample = [@selected_sample+1, @samples-1].min if @controllable && @focus
		end
		
		def move_up
			@amplitudes[@selected_sample] += @ystep if @controllable && @focus
		end
		
		def move_down
			@amplitudes[@selected_sample] -= @ystep if @controllable && @focus
		end
		
		def recheck_focus(ev)
			@focus = point_in_rect(ev.pos)
		end
		
		def load_equation(ev)
			return unless controllable && point_in_rect(ev.pos)
			print "#{@name}[n] = "
			equ = gets
			
			begin
				fn = ExMath.get_binding.eval("lambda { |n| #{equ} }")
				(0...@samples).each { |n| @amplitudes[n] = fn[n] }
			rescue => e
				puts e
			end
		end
		
		def point_in_rect(pos)
			pos[0].between?(@rect[0], @rect[0] + @width) && pos[1].between?(@rect[1], @rect[1] + @height)
		end
		
		def image_x(x)
			@hspace/2 + x*@hspace
		end
		
		def image_y(y)
			@image.h - @height/2 - @height/2 * y/(@peak+0.1)
		end
		
		def draw(*args)
			@legend.draw(*args)
			super(*args)
		end
		
		def update
			@image.fill(@background)
			@image.draw_line([0, image_y(0)], [@width, image_y(0)], @grid)
			(0...@samples).each do |i|
				@image.draw_line([image_x(i), 0], [image_x(i), @height], @grid)
				
				sample_color = @controllable && @focus && i == @selected_sample ? @active : @point
				p1 = [image_x(i) - @boxwidth/2, image_y(@amplitudes[i]) + @boxheight/2]
				p2 = [image_x(i) + @boxwidth/2, image_y(@amplitudes[i]) - @boxheight/2]
				@image.draw_box_s(p1, p2, sample_color)
			end
			@legend.update
		end
	end
end
