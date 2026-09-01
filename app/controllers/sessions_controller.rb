class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      @error = "Invalid email or password"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path
  end
end
