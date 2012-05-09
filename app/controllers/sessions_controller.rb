class SessionsController < ApplicationController
  
  def new
    redirect_to '/auth/facebook'
  end
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:provider => auth['provider'], 
                      :uid => auth['uid']).first || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    redirect_to root_url, :notice => "Signed in!"
  end
  
  def destroy
    reset_session
    redirect_to root_url, notice: 'Signed out!'
  end
end
