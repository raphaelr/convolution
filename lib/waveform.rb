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
			@image.convert($screen)
			@rect = [0, 0, @width, @height]
			
			@background = Color[:white]
			@grid = Color[:silver]
			@point = Color[:blue]
			@active = Color[:red]
			
			@amplitudes = Array.new(@samples, 0)
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
		
		def draw(target)
			@image.fill(@background)
			@image.draw_line([0, @height/2], [@width, @height/2], @grid)
			(0...@samples).each do |i|
				@image.draw_line([@hspace/2 + i*@hspace, 0], [@hspace/2 + i*@hspace, @height], @grid)
				
				sample_color = @controllable && @focus && i == @selected_sample ? @active : @point
				y = (@peak*@height/2 + @height/2 * @amplitudes[i] - @boxheight/2) / @peak
				y = [[y, @height + @boxheight].min, -@boxheight].max
				p1 = [@hspace/2 + i*@hspace - @boxwidth/2, @image.h - y]
				p2 = [@hspace/2 + i*@hspace + @boxwidth/2, @image.h - y - @boxheight]
				@image.draw_box_s(p1, p2, sample_color)
			end
			@image.blit(target, @rect)
		end
		
		def update
		end
	end
end
