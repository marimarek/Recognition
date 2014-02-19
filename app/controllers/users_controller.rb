class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      path = "#{Rails.root}/app/assets/images/digits/" + @user.id.to_s
      unless File.directory?(path)
        FileUtils.mkdir_p(path)
      end
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
    signed_in_only!
  end

  def destroy
    signed_in_only!
    if @current_user.authenticate(params[:password])
      path = "#{Rails.root}/app/assets/images/digits/" + @current_user.id.to_s
      if File.directory?(path)
        FileUtils.rm_rf(path)
      end
      @current_user.destroy
      session[:id] = nil
      redirect_to root_path
    else
      flash[:error] = 'Invalid password. :('
      redirect_to settings_path
    end
  end

  def update
    if @current_user.update_attributes(user_params)
      redirect_to root_path
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
