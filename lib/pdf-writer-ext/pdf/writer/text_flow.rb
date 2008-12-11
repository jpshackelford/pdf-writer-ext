module PDF
  class Writer

    class TextFlow
      
      attr_reader :outflow
      
      def initialize
        @flow = []
        @inflow = ''
        @outflow = ''
      end
      
      def << ( item ) 
        @flow << item
      end
      
      def inflow( text )
        @inflow = text
      end
      
      alias text= inflow
      
      def render( pdf )   
        text = @inflow.dup
        @flow.each do |item|
          item.inflow( text )
          item.render( pdf )
          text = item.outflow
        end
        @outflow = text
      end
      
    end
    
    
  end
end