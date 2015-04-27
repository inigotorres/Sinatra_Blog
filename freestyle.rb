require 'sinatra'
require 'rubygems'
require 'data_mapper'
require 'pony'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/freestyle.db")

class Message
  include DataMapper::Resource
  property :id, Serial
  property :name, Text
  property :email, Text, :required => true
  property :subject, Text
  property :content, Text, :required => true
  property :created_at, DateTime
end

DataMapper.finalize.auto_upgrade!

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end
end

get '/' do
  erb :main
end

get '/about' do
  erb :about
end

get '/view' do
  protected!

  @messages = Message.all :order => :id.desc
  erb :view
end

post '/send' do
  m = Message.new
  m.name = params[:name]
  m.email = params[:email]
  m.subject = params[:subject]
  m.content = params[:content]
  if m.save
    Pony.mail :to => 'itorres@peertransfer.com', 
              :from => 'no_response_please@peertransfer.com', 
              :subject => 'New message in your blog',
              :body => "New message in your blog! Received at #{m.created_at} from #{m.name} with email #{m.email} and subject #{m.subject}"
    erb :send
  else
    erb :send_error
  end
end

delete '/:id' do
  m = Message.get params[:id]
  m.destroy
  redirect '/view'
end
