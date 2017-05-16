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
  session[:tries] = 12
  session[:guess_cache] = "1111"
  redirect to("/")
end

get "/" do
  if session[:code].nil?
    redirect to "/newgame"
  else
    @tries = session[:tries]
    @history = session[:history]
    @valid = check_guess_valid?(session[:guess_cache])
    @guess_cache = @valid? nil : session[:guess_cache]
    @win = win?(session[:guess_cache], session[:code])
    @code = session[:code]
    erb :index
  end
end

post "/" do
  #@lose = true if session[:tries] == 0
  #@win = true if win?(params[:guess], session[:code])
  #session[:valid_guess] = check_guess_valid?(params[:guess])
  session[:guess_cache] = params[:guess]
  if check_guess_valid?(params[:guess])
    session[:history] << params[:guess]
    session[:tries] -= 1
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
