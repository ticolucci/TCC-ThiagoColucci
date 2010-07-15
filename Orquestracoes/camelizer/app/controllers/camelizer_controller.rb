# encoding: UTF-8
class CamelizerController < ApplicationController
  include ActionWebService::ActsAsWebService::ClassMethods
  acts_as_web_service

  include ActionWebService::Dispatcher::ActionController::WsdlAction

  wsdl_service_name 'Camelizer'
  web_service_api CamelizerApi
  web_service_scaffold :invocation
  skip_before_filter :verify_authenticity_token

  def camelize string
    return string.camelize
  end
end

