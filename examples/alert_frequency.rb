#!/usr/bin/env ruby
#
# An example showing how the alert_frequency option works
#
# You probably need to run from the parent directory as:
#
#   ruby -Ilib examples/alert_frequency.rb
#
require 'deprecatable'

#----------------------------------------------------------------------
# We create an example class with a deprecated method
#----------------------------------------------------------------------
module A
  class B
    extend Deprecatable
    def initialize
      @call_count = 0
    end
    def deprecate_me
      @call_count += 1
      puts "deprecate_me call #{@call_count}"
    end
    deprecate :deprecate_me, :message => "This method is to be completely removed", :removal_version => "4.2"
  end
end


#----------------------------------------------------------------------
# usage, you can ignore this for now, this will get printed out if you
# do not put any commandline arguments down
#----------------------------------------------------------------------
def usage
  puts <<__
This is an example of showing how to affect the alert frequency
You can change the alert frequency by:

  1) Setting `Deprecatable.options.alert_freqeuncy` in ruby code.
  2) Setting the DEPRECATABLE_ALERT_FREQUENCY envionment variable.

They may be set to one of the following values:  'never', 'once', 'always'
When you use both (1) and (2) simultaneously, you will see that
setting the environment variable always overrides the code.

Here are some example ways to run this program

__


  [ nil, "DEPRECATABLE_ALERT_FREQUENCY=" ].each do |env|
    %w[ never once always ].each do |env_setting|
      next if env.nil? and env_setting != 'never'
      %w[ never once always ].each do |cmd_line|
        next if env and (env_setting == cmd_line)
        parts = [ "    " ]
        parts << "#{env}#{env_setting}" if env
        parts << "ruby -Ilib #{__FILE__} #{cmd_line}"
        puts parts.join(' ')
      end
    end
  end

  puts
  exit 1
end

if $0 == __FILE__
  # Turning off the at exit report, for more information on them,
  # see the examples/at_exit.rb
  Deprecatable.options.has_at_exit_report = false

  # capture the parameters, we'll run if there is a commandline parameter
  # of if the environment variable is et
  alert_frequency = ARGV.shift
  usage unless alert_frequency || ENV['DEPRECATABLE_ALERT_FREQUENCY']

  Deprecatable.options.alert_frequency = alert_frequency if alert_frequency

  puts
  puts "Running with ENV['DEPRECATABLE_ALERT_FREQUENCY']  => #{ENV['DEPRECATABLE_ALERT_FREQUENCY']}"
  puts "Running with Deprecatable.options.alert_frequency => #{Deprecatable.options.alert_frequency}"
  puts "-" * 72
  puts

  b = A::B.new
  4.times do
    # Context before 1.1
    # Context before 1.2
    b.deprecate_me
    # Context after 1.1
    # Context after 1.2
  end

  2.times do
    # Context before 2.1
    # Context before 2.2
    b.deprecate_me
    # Context after 2.1
    # Context after 2.2
  end
end
