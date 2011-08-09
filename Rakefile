# vim: syntax=ruby

begin
  require 'rubygems'
  require 'hoe'
rescue LoadError 
  abort <<-_
  Developing deprecatable requires the use of rubygems and hoe.

    gem install hoe
  _
end

Hoe.plugin :doofus, :git, :gemspec2, :minitest

Hoe.spec 'deprecatable' do
  developer 'Jeremy Hinegardner', 'jeremy@copiousfreetime.org'

  # Use rdoc for history and readme
  self.history_file = 'HISTORY.rdoc'
  self.readme_file  = 'README.rdoc'

  self.extra_rdoc_files = [ self.readme_file, self.history_file ]

  # test with minitest
  self.extra_dev_deps << [ 'rcov', '~> 0.9.10']

end

