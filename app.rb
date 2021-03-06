require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

def create_meetup(name, location, description)
  Meetup.create(name: name, location: location, description: description)
end

def create_comments(user_id, meetup_id, title, body)
  Comment.create(user_id: user_id, meetup_id: meetup_id, title: title, body: body)
end

get '/' do
  @meetups = Meetup.all.order('name asc')
  erb :index
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end

get '/meetups/:id' do
authenticate!
@meetup = Meetup.find(params[:id])
@comments = Comment.where(meetup_id: params[:id])
@users = @meetup.users("username, avatar_url")
erb :'meetups/show'
end



get '/create_meetup' do
authenticate!
erb :'create_meetup/show'
end

post '/create_meetup' do
@name = params[:name]
@location = params[:location]
@description = params[:description]
@new_meetup = create_meetup(@name, @location, @description)
@id = @new_meetup[:id]
flash[:notice] = "You just made a new post!"
redirect "/meetups/#{@id}"
end

post "/join_meetup/:id" do
  @user_id = session[:user_id]
  @meetup_id = params[:id]
  @meetup = Meetup.find(@meetup_id)
  @meetup.users.include?(current_user)
  @join = @meetup.users << current_user
  flash[:notice] = "Event joined!"
  redirect "/meetups/#{@meetup_id}"
end

post "/leave_meetup/:id" do
  @user_id = session[:user_id]
  @meetup_id = params[:id]
  @meetup = Meetup.find(@meetup_id)
  @meetup.users.include?(current_user)
  @meetup.users.delete(current_user)
  flash[:notice] = "You have left this Meetup!"
  redirect "/meetups/#{@meetup_id}"
end

post "/create_comment/:id" do
@user_id = session[:user_id]
@meetup_id = params[:id]
@title = params[:title]
@body = params[:body]
@meetup = Meetup.find(@meetup_id)
@new_comments = create_comments(@user_id, @meetup_id, @title, @body)
flash[:notice] = "Comment Posted!"
redirect "/meetups/#{@meetup_id}"
end

