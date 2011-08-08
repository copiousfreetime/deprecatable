#!/usr/bin/env ruby
#
# An example showing how the alert_frequency option works
#
# You probably need to run from the parent directory as:
#
#   ruby -Ilib examples/alert_frequency.rb
#
require 'deprecatable'
module A
  class B
    extend Deprecatable
    def initialize
      @call_count = 0
    end
    def deprecate_me
      @call_count += 1
      "deprecate_me call #{@call_count}"
    end
    deprecate :deprecate_me, :message => "This method is to be completely removed", :removal_version => "4.2"
  end
end

if $0 == __FILE__

  puts "This is an example of showing how to affect the alert frequency"
  puts "You can change the alert frequency by:"
  puts
  puts "  1) Setting `Deprecatable.options.alert_freqeuncy` in ruby code."
  puts "  2) Setting the DEPRECATABLE_ALERT_FREQUENCY envionment variable."
  puts
  puts "They may be set to one of the following values:  'never', 'once', 'always'"
  puts "When you use both (1) and (2) simultaneously, you will see that"
  puts "setting the environment variable always overrides the code."

  puts
  puts "Here are some example ways to run this program"

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
  puts "-" * 72

  Deprecatable.options.alert_frequency = ARGV.shift || 'once'
  Deprecatable.options.has_at_exit_report = false

  puts
  puts "Running with ENV['DEPRECATABLE_ALERT_FREQUENCY'] => #{ENV['DEPRECATABLE_ALERT_FREQUENCY']}"
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
