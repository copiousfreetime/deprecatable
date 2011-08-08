#!/usr/bin/env ruby
#
# An example showing how the caller_context_padding option works
#
# You probably need to run from the parent directory as:
#
#   ruby -Ilib examples/caller_context_padding.rb
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
This is an example of showing how to affect the caller context padding
You can change the caller_context_padding by

  1) Setting `Deprecatable.options.caller_context_padding` in ruby code.
  2) Setting the DEPRECATABLE_CALLER_CONTEXT_PADDING envionment variable.

They may be set to an integer value that is >= 1
When you use both (1) and (2) simultaneously, you will see that
setting the environment variable always overrides the code.

Here are some example ways to run this program"

__

  [ nil, "DEPRECATABLE_CALLER_CONTEXT_PADDING=" ].each do |env|
    (1..3).each do |env_setting|
      next if env.nil? and env_setting > 1
      (1..3).each do |cmd_line|
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
  caller_context_padding = ARGV.shift
  usage unless caller_context_padding || ENV['DEPRECATABLE_CALLER_CONTEXT_PADDING']
  Deprecatable.options.caller_context_padding = Float( caller_context_padding ).to_i if caller_context_padding

  puts
  puts "Running with ENV['DEPRECATABLE_CALLER_CONTEXT_PADDING']  => #{ENV['DEPRECATABLE_CALLER_CONTEXT_PADDING']}"
  puts "Running with Deprecatable.options.caller_context_padding => #{Deprecatable.options.caller_context_padding}"
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
