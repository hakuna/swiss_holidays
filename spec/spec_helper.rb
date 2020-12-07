begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler.setup

require 'swiss_holidays'

RSpec.configure do |config|

end
