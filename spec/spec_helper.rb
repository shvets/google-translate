# spec_helper.rb

require 'rubygems'
require 'rspec'

# add lib directory
$:.unshift File.dirname(__FILE__) + '/../lib'

RSpec.configure do |config|
  config.mock_with :mocha
end
