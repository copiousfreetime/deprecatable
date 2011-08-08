#!/usr/bin/env ruby
#
# An example showing how the at_exit handler work
#
# You probably need to run from the parent directory as:
#
#   ruby -Ilib examples/at_exit.rb
#
require 'deprecatable'
module A
  class B
    extend Deprecatable
    def deprecate_me_1
      puts "I've been deprecated! (1)"
    end
    deprecate :deprecate_me_1, :message => "This method is to be completely removed", :removal_version => "4.2"

    def deprecate_me_2
      puts "I've been deprecated! (2)"
    end
    deprecate :deprecate_me_2, :message => "This method is to be completely removed", :removal_date => "2020-02-20"
  end
end

if $0 == __FILE__
  b = A::B.new

  Deprecatable.options.alert_frequency = :never

  4.times do
    # Context before 1.1
    # Context before 1.2
    b.deprecate_me_1
    # Context after 1.1
    # Context after 1.2

    # Context before 2.1
    # Context before 2.2
    b.deprecate_me_2
    # Context after 2.1
    # Context after 2.2
  end

  # do a bunch of things

  2.times do
    # Context before 3.1
    # Context before 3.2
    b.deprecate_me_1
    # Context after 3.1
    # Context after 3.2

    # Context before 4.1
    # Context before 4.2
    b.deprecate_me_2
    # Context after 4.1
    # Context after 4.2
  end
end
