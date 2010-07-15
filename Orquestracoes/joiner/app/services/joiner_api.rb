# encoding: UTF-8
class JoinerApi < ActionWebService::API::Base
  api_method :join, :expects => [{:string => :string}], :returns => [:string]
end

