module SessionsHelper

  def sign_in(user)
    session[:id] = user.id
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find(session[:id]) if session[:id]
  end

  def signed_in?
    !current_user.nil?
  end

  def signed_in_only!
    if !signed_in?
      redirect_to root_path
    end
  end

end
