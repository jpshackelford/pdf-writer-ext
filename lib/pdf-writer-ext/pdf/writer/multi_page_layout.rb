require 'thread'

module PDF
  class Writer
    
    class PositionableItem
      
      def at( x, y )
        @x,@y=@x,y
        self
      end
      
      def render( pdf )
        raise NotImplementedError
      end
      
    end
    
    class SinglePageItem < PositionableItem
      
      def next_page        
      end
      
      def more?
        false
      end
      
      def page_number
        1
      end
      
    end
    
    class MultiPageItem < PositionableItem
      
      attr_reader :page_number
      
      def next_page
        @page_number ||= 1
        @page_number += 1 
        self
      end
      
      def more?
        raise NotImplementedError
      end
      
    end
    
    class IllegalStateError < Exception 
    end
    
       
    class MultiPageLayout
      
      attr_accessor :item_provider, :item_adapter 
      
      attr_reader :page_number, :item_number, :items_on_page,
                  :incomplete_items, :incomplete_item_refs
      
      def initialize
        @page_number = 0
        @item_number = 0
        @items_on_page = 0
        @incomplete_items = {}
        @incomplete_item_refs = {}
        @render_queue = Queue.new
      end

      # override in subclasses
      # Set x,y for item using #page_number, #item_number and #items_on_page
      # as well as geometry from PDF::Writer but leave rendering to the item. 
      def position( item, pdf )
        raise NotImplementedError        
      end
      
      # override in subclasses
      def next_page?        
        raise NotImplementedError
      end
      
      # optional hook for starting item list
      def items_start( pdf )       
      end

      # optional hook for finalizing item list
      def items_start( pdf )        
      end

      # optional hook for starting a new page
      def page_start( pdf )        
      end

      # optional hook for finalizing page 
      def page_end( pdf )        
      end

      # Handles all of the details of adapting the model and rendering the items
      # in the PDF using the ItemProvider and ItemAdapter you specify as well as
      # the #position and #new_page? methods you implement.
      def render( pdf )
        
        raise IllegalStateError, "No ItemProvier specified" if 
          @item_provider.nil?
        
        raise IllegalStateError, "No ItemAdapter specified" if 
          @item_adapter.nil?
        
        items_start( pdf )
        
        @item_provider.each do |item|          
          
          # adapt the item using the item adapter
          adapted_item = @item_adapter.adapt( item )
          
          # start a new page if we need to
          if @item_number > 0 && next_page?         
            page_end( pdf )    
            new_page( pdf )
            page_start( pdf )                        
          end

          # WE NEED TO BE ABLE TO REUSE THIS CODE FOR ADITIONAL RENDERINGS
          # OF ITEMS IF adapted_item#more? HOW WILL WE STRUCTURE THIS DIFFERENTLY?

          # place the item on the page          
          position( adapted_item, pdf ) # layout tells the item where on the page
          item.render( pdf )            # but the item knows how to draw itself
          
          # keep track of some information #position will use
          # to layout the item on the page
          @item_number   += 1 
          @items_on_page += 1
                    
          # We keep only items we are still going to use
          # so we don't eat up tons of memory for documents
          # with thousands of item.
          adapted_item.more? ? retain( adapted_item ) : dispose( adapted_item ) 
        end
        
        items_end( pdf )
      end
      
      private
      
      # Mark the item as displayed and clean-up any outstanding references to it. 
      def dispose( item )
        pages = @incomplete_item_refs[ item ]
        unless pages.nil?
          # for each page on which the item appears
          pages.each do |page|
            # remove it
            items = @incomplete_items[ page ] 
            items.delete( item )
            # and remove the page too if we've delete the last one
            @incomplete_items.delete( page ) if items.empty?            
          end          
        end
        # remove the item cross-reference
        @incomplete_item_refs.delete( item )
      end
      
      # Store the item in a hash indexed by the page on which the item appeared.
      def retain( item )        
        # record the item itself
        @incomplete_items[ @page_number ] ||= []
        @incomplete_items[ @page_number ] << item        
        # store a reference indexed by item for easy disposal
        @incomplete_item_refs[ item ] ||= []
        @incomplete_item_refs[ item ] << @page_number 
      end     
      
      def new_page( pdf )
        pdf.start_new_page
        @page_number += 1
        @items_on_page = 0
      end
      
    end
    
    
    
  end
end