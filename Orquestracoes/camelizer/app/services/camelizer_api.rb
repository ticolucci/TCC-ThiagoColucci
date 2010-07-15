# encoding: UTF-8
class CamelizerApi < ActionWebService::API::Base
  api_method :camelize, :expects => [{:string => :string}], :returns => [:string]
end

