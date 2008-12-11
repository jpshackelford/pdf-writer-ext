module PDF
  class Writer

    class TextBox
      
      attr_reader :outflow, :text
      
      def initialize(w, h, options = {})
        @x, @y = 0,0
        @w, @h = w, h        
        @options = options
        @inflow = ''
        @outflow = ''
      end
      
      def at( x, y)
        @x,@y = x,y
        return self
      end
      
      def inflow( text )
        @inflow = text
        return self
      end
      
      # Text which was not displayed in the textbox but which is held in reserve
      # for display in another textbox.
      def outflow        
        @outflow
      end
      
      alias text= inflow
      
      def render( pdf )        
        pdf.open_object do |textbox|
          pdf.save_state
          
          render_border( pdf )
          render_text( pdf )
          
          pdf.restore_state
          pdf.close_object
          pdf.add_object( textbox, page_placement )
        end
      end
      
      private
            
      def angle
        @options[:angle].to_i
      end
      
      def theta
        @theta ||= PDF::Math.deg2rad( angle )
      end
      
      def sin_theta
        @sin_theta ||= ::Math.sin( theta )
      end
    
      def cos_theta
        @cos_theta ||= ::Math.cos( theta )
      end
    
      def pad
        @options[:pad].to_f
      end
      
      def page_placement
        @options[:page_placement] || :this_page
      end
      
      def justification
        @options[:justification] || :left
      end
      
      def inset_origin( x, y )
        return x + cos_theta * pad - sin_theta * pad,
               y + cos_theta * pad + sin_theta * pad        
      end
      
      def top_left( origin_x, origin_y, h)
         return origin_x - sin_theta * h,
                origin_y + cos_theta * h
      end
      
      def render_border( pdf )        
        if @options[:border]        
          border = Border.new( @x, @y, @w, @h, angle, @options[:border])          
          border.render( pdf )
        end
      end
      
      def font_size( pdf )
        return @options[:font_size] || pdf.font_size  
      end
      
      def line_height( pdf )
        if @options[:leading] # leading instead of spacing
          h = @options[:leading]
        elsif @options[:spacing]
          h = @options[:spacing] * pdf.font_height( font_size( pdf ) )
        else
          h = pdf.font_height( font_size( pdf ) )
        end
        return h
      end
      
      def render_text( pdf )      
        
        # split text into line by line break
        lines = @inflow.to_s.split("\n")
        
        # size
        size = font_size( pdf )
        
        # line height & width
        line_h  = line_height( pdf )
        total_h = @h - (pad * 2)
        width   = @w - (pad * 2)
        
        # place the text box allow for padding
        x,y = inset_origin( @x, @y ) #         
        
        # find origin (bottom left) of first line.        
        line_x, line_y = top_left( x, y, (total_h - line_h) + 2) # +2 fudges alignment 
                                                                 # of text w/ graphics
        # 
        line_count = 0
        # Thanks to Brian Hartin who labored to get this down to few simple lines.
        while line_count * line_h <= total_h && lines.size > 0 do
          
          # keep track of lines so we don't have to do 
          # fancy geometry to discover if we've gone past the origin at any
          # angle 
          line_count += 1
          
          # take a line off the stack and attempt to position it,
          # wrapping any words which don't fit          
          leftover_words = pdf.add_text_wrap( line_x , line_y, width, lines.shift, 
                                            size, justification, angle )

          # add words which don't fit back onto the stack
          lines.unshift( leftover_words ) unless leftover_words.nil? || 
                                                 leftover_words.empty?          
          # position at the next line          
          line_x += ( line_h * sin_theta )
          line_y -= ( line_h * cos_theta )
        end
        @inflow = nil
        return @outflow = lines.join("\n")        
      end
      
    end
  end
end
