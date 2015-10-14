$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'rspec/its'
require 'webmock/rspec'
require 'lazy_ant'
require 'ostruct'
require 'multi_xml'

class User < OpenStruct
end

class DataPicker < Faraday::Response::Middleware
  def on_complete(env)
    env.body = env.body['data']
  end
  Faraday::Response.register_middleware data_picker: self
end

class MyClient
  include LazyAnt::DSL

  configurable :client_token, default: ''
  configurable :client_secret, default: ''
  configurable :dev?, default: false

  base_url 'http://api.example.com'

  connection do |faraday|
    faraday.headers['X-client-token'] = config.client_token
  end

  converter :data_picker

  group :users do
    api :find, get: '/users/:id.json', entity: User

    group :posts do
      base_url 'http://api2.example.com'
      api :find, get: '/users/:user_id/posts/:id.json'
    end
  end

  group :request_and_response do
    request :url_encoded
    response :xml
    connection do |con|
      con.request :url_encoded
      con.response :xml
      con.params[:foo] = 'bar'
    end

    api :post, post: '/version.xml'
    api :get, get: '/version.xml'
  end

  api :version, post: '/version.json'
end
