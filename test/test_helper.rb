require 'subroutine'
require 'minitest/autorun'
require 'minitest/unit'

require 'minitest/reporters'
require 'mocha/mini_test'

Minitest::Reporters.use!([Minitest::Reporters::DefaultReporter.new])

class TestCase < (MiniTest::Unit::TestCase rescue ::MiniTest::Test); end

require_relative 'support/ops'
