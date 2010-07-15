# encoding: UTF-8
class JoinerController < ApplicationController
  include ActionWebService::ActsAsWebService::ClassMethods
  acts_as_web_service

  include ActionWebService::Dispatcher::ActionController::WsdlAction

  wsdl_service_name 'Joiner'
  web_service_api JoinerApi
  web_service_scaffold :invocation

  before_filter :puts_debug
  skip_before_filter :verify_authenticity_token


  def join string
    return string.gsub(/\s/, '_')
  end

  def puts_debug
    puts '-------------------------------------------------------------------'

    p request

    puts '\n\n------------------------------------------------------------------'
  end
end

