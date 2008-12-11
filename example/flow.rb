$LOAD_PATH << File.join( File.dirname( __FILE__), '..', 'lib')
require 'pdf-writer-ext'

pdf = PDF::Writer.new

text = <<-EOF
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor 
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu 
fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum.
EOF

text.gsub!("\n",' ')

flow = PDF::Writer::TextFlow.new

flow << PDF::Writer::TextBox.new( 150, 100, 
                                  :border => 1, :pad => 10, :angle => 60 ).
                                  at( 100, 400 )
                                  
flow << PDF::Writer::TextBox.new( 150, 100, 
                                     :border => 1, :pad => 10, :angle => 120 ).
                                     at(300,400)
flow.inflow( text )
flow.render( pdf )

pdf.text( flow.outflow )
pdf.save_as('test.pdf')