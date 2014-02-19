class SessionsController < ApplicationController

  def create
    user = User.find_by(name: params[:session][:name])
    if user && user.authenticate(params[:session][:password])
      sign_in user
    else
      flash[:error] = 'Invalid credentials. :('
    end

    redirect_to root_path
  end

  def destroy
    session[:id] = nil
    redirect_to root_path
  end

end
