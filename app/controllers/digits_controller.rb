class DigitsController < ApplicationController
  before_action :signed_in_only!

  def history
    @digits = Digit.find :all, :conditions => ["user_id = ?", current_user.id]
  end

  def show
    @digit = Digit.find params[:id], :conditions => ["user_id = ?", current_user.id]
  end

  def delete
    digit = Digit.find params[:id], :conditions => ["user_id = ?", current_user.id]
    digit.delete

    redirect_to history
  end

  def mark
    @digit = Digit.find params[:id], :conditions => ["user_id = ?", current_user.id]
    @digit.digit_user_marked = params[:mark]
    @digit.update

    render 'show'
  end
end
