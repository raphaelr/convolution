module Convolution
	class App
		include Rubygame
		include EventHandler::HasEventHandler
		
		SAMPLES = 100
		RESPONSE_IMPULSES = 30
		PEAK = 2.0
		WAVEFORM_OPTIONS = { :peak => PEAK, :ystep => 0.1 }
		DATA_DIR = File.join(File.dirname(__FILE__), "..", "data")
		
		SECOND_SIGNAL_TEXT = { :convolution => ["Impulse", "Response:"], :correlation => ["Target", "Signal:"] }
		
		def self.run
			new.run
		end
		
		def initialize
			TTF.setup
			Rubygame.enable_key_repeat
			@font = TTF.new(File.join(DATA_DIR, "font.ttf"), 24)
			
			@queue = EventQueue.new
			@queue.enable_new_style_events
			
			@clock = Clock.new
			@clock.target_framerate = 60
			@clock.calibrate
			
			@handlers = [self]
			@sprites = Sprites::Group.new
			
			@screen = Screen.new([1430, 575], 24, [HWSURFACE, DOUBLEBUF])
			@screen.title = "Convolution / Impulse Response"
			
			@running = true
			make_magic_hooks(:escape => :quit, Events::QuitRequested => :quit, :tab => :switch_focus, :space => :switch_mode)
			
			@input = Waveform.new(WAVEFORM_OPTIONS.merge(:samples => SAMPLES, :name => "f" ))
			@input.rect = [120, 0]
			@response = Waveform.new(WAVEFORM_OPTIONS.merge(:samples => RESPONSE_IMPULSES, :name => "h"))
			@response.rect = [120, 200]
			@output = Waveform.new(WAVEFORM_OPTIONS.merge(:samples => SAMPLES + RESPONSE_IMPULSES))
			@output.controllable = false
			@output.rect = [120, 400]
			@handlers << @input << @response << @output
			@sprites << @input << @response << @output
			
			@sprites << Text.new(@font, "Input:", [5, @input.image.height/2 - @font.height/2])
			@sprites << Text.new(@font, "Output:", [5, @output.rect[1] + @output.image.height/2 - @font.height/2])
			
			@input.focus = true
			
			ExMath.samples = SAMPLES
			ExMath.response_impulses = RESPONSE_IMPULSES
			ExMath.peak = PEAK
			@controller = Controller.new(SAMPLES, RESPONSE_IMPULSES, PEAK)
			@input.amplitudes = @controller.input
			@response.amplitudes = @controller.response
			@output.amplitudes = @controller.output
			update_signal_text
		end
		
		def update_signal_text
			@sprites.delete(*@signal_texts || [])
			@signal_texts = [
				Text.new(@font, SECOND_SIGNAL_TEXT[@controller.mode][0], [20, @response.rect[1] + @response.image.height/3 - @font.height/2]),
				Text.new(@font, SECOND_SIGNAL_TEXT[@controller.mode][1], [20, @response.rect[1] + 2*@response.image.height/3 - @font.height/2])
			]
			@sprites.push(*@signal_texts)
		end
		
		def quit
			@running = false
		end
		
		def switch_focus
			tmp = @response.focus
			tmp = true unless @input.focus
			@response.focus = @input.focus
			@input.focus = tmp
		end
		
		def switch_mode(ev)
			@controller.mode = @controller.mode == :convolution ? :correlation : :convolution
			update_signal_text
		end
		
		def run
			while @running
				@queue.fetch_sdl_events
				@queue.each { |e| @handlers.each { |h| h.handle(e) } }
				
				@screen.fill(Color[:white])
				@controller.update
				@sprites.draw(@screen)
				@screen.draw_line([0, 175], [@screen.width, 175], Color[:black])
				@screen.draw_line([0, 375], [@screen.width, 375], Color[:black])
				@screen.flip
				@clock.tick
			end
		end
	end
end
