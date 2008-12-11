# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  load 'tasks/setup.rb'
end

ensure_in_path 'lib'
require 'pdf-writer-ext'

task :default => 'spec:run'

PROJ.name = 'pdf-writer-ext'
PROJ.authors = 'FIXME (who is writing this software)'
PROJ.email = 'FIXME (your e-mail)'
PROJ.url = 'FIXME (project homepage)'
PROJ.version = PdfWriterExt::VERSION
PROJ.rubyforge.name = 'pdf-writer-ext'

PROJ.spec.opts << '--color'

# EOF
