module PDF
  class Writer
    
    class Border
      
      # Array element for X axis in coordinate pair 
      X = 0
      
      # Array element for Y axis in coordinate pair
      Y = 1
      
      attr_reader :x, :y, :height, :width, :angle, :style
      
      attr_reader :theta, :sin_theta, :cos_theta
      private     :theta, :sin_theta, :cos_theta
      
      def initialize(x, y, width, height, angle, style_or_size = 0.5 )
        @x = x
        @y = y
        @w = width
        @h = height
        @angle  = angle
        @style = style_for( style_or_size )
        @theta  = ::PDF::Math.deg2rad( angle )
        @sin_theta = ::Math.sin( @theta )
        @cos_theta = ::Math.cos( @theta )
      end
      
      def render( pdf )        
        pdf.stroke_style( @style )                
        pdf.move_to( *bottom_left )
        pdf.line_to( *top_left )
        pdf.line_to( *top_right )
        pdf.line_to( *bottom_right )
        pdf.close.stroke   
      end
      
      private
      
      def style_for( style_or_size )
        case style_or_size
        when PDF::Writer::StrokeStyle
          style = style_or_size          
        when Numeric
          style = PDF::Writer::StrokeStyle.new( style_or_size.to_f )
        end
        return style
      end  
       
      def bottom_left
        return @x, @y
      end
      
      alias border_orgin bottom_left
      
      def top_left
        return  @x - sin_theta * @h,
                @y + cos_theta * @h
      end
      
      def top_right
        return (top_left[X] - @x ) + bottom_right[X],
               (bottom_right[Y] - @y) + top_left[Y]
      end
      
      def bottom_right
        return @x + cos_theta * @w,
               @y + sin_theta * @w        
      end
            
    end

  end
end
