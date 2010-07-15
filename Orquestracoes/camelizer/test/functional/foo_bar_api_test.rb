# encoding: UTF-8
require File.dirname(__FILE__) + '/../test_helper'
require 'foo_bar_controller'

class FooBarController; def rescue_action(e) raise e end; end

class FooBarControllerApiTest < Test::Unit::TestCase
  def setup
    @controller = FooBarController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
end
