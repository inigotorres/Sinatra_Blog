require 'sinatra'
require 'data_mapper'

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

get '/' do
  erb :main
end

get '/about' do
  erb :about
end

get '/view' do
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
