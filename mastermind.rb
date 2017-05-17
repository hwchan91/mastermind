require 'sinatra'
require 'sinatra/reloader' if development?

#set :root, File.join(File.dirname(__FILE__), '..')
#set :views, Proc.new { File.join(root, "views") } #apparently these two lines do the same things; which is to direct sinatra to find the views folder in ../views

configure do
  enable :sessions
end

get "/newgame" do
  session[:history] = []
  session[:code] = set_code
  redirect to("/")
end

get "/" do
  if session[:code].nil?
    redirect to "/newgame"
  elsif session[:history] != [] and win?(session[:guess_cache], session[:code])
    redirect to "/win"
  elsif session[:history].length >= 12
    redirect to "/lose"
  else
    @history = session[:history]
    @code = session[:code]
    if !session[:guess_cache].nil?
      @guess_cache = check_guess_valid?(session[:guess_cache])? nil : session[:guess_cache]
    end
    erb :index
  end
end

get "/win" do
  @code = session[:code]
  erb :win
end

get "/lose" do
  @code = session[:code]
  erb :lose
end

post "/" do
  session[:guess_cache] = params[:guess]
  if check_guess_valid?(params[:guess])
    session[:history] << params[:guess]
  end
  redirect to "/"
end

helpers do
  def set_code
    4.times.map{rand(6)+1}.join
  end

  def check_guess_valid?(guess)
    if guess.length == 4
      return true if guess.split("").all?{|i| i.between?("1","6")}
    end
    false
  end

  def check_guess(guess, code = session[:code])
    code = code.split("")
    guess = guess.split("")
    complete_match, partial_match = 0, 0
    4.times do |i|
      if code[i] == guess[i]
        complete_match += 1
        code[i], guess[i] = "X", "Y"
      end
    end
    4.times do |i|
      4.times do |j|
        if guess[i] == code[j]
          partial_match += 1
          code[j], guess[i] = "X", "Y"
        end
      end
    end

    if complete_match == 0 and  partial_match == 0
      ""
    else
     ("⚈ " * complete_match + "○ " * partial_match).strip
    end
  end

  def win?(guess, code)
    check_guess(guess, code) == "⚈ ⚈ ⚈ ⚈"
  end

end
