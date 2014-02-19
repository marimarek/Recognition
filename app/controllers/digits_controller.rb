class DigitsController < ApplicationController
  before_action :signed_in_only!

  def history
    @digits = Digit.find :all, :order => "created_at", :offset => (params[:page].to_i-1)*15, :limit => 15, :conditions => {user_id: current_user.id}
    counters
  end

  def correct
    @digits = Digit.find :all, :order => "created_at", :offset => (params[:page].to_i-1)*15, :limit => 15,
                         :conditions => ['digit_recognize = digit_user_marked AND user_id = ?', current_user.id]
    counters

    render 'history'
  end

  def fail
    @digits = Digit.find :all, :order => "created_at", :offset => (params[:page].to_i-1)*15, :limit => 15,
                         :conditions => ['digit_recognize != digit_user_marked AND user_id = ?', current_user.id]
    counters

    render 'history'
  end

  def unmarked
    @digits = Digit.find :all, :order => "created_at", :offset => (params[:page].to_i-1)*15, :limit => 15,
                         :conditions => {digit_user_marked: nil, user_id: current_user.id}
    counters

    render 'history'
  end

  def destroy
    digit = Digit.find_by_id params[:id], :conditions => ["user_id = ?", current_user.id]
    if !digit.nil?
      File.delete("#{Rails.root}/app/assets/images/" + digit.url)
      digit.delete
    end

    redirect_to history_path
  end

  def mark
    digit = Digit.find_by_id params[:digit][:id], :conditions => ["user_id = ?", current_user.id]
    if digit.nil?
      redirect_to root_path
    else
      digit.digit_user_marked = params[:digit][:digit_user_marked]
      digit.update digit_user_marked: params[:digit][:digit_user_marked]

      redirect_to history_path
    end
  end

private
  def counters
    @all = Digit.where(user_id: current_user.id).count
    @correct = Digit.where('digit_recognize = digit_user_marked AND user_id = ?', current_user.id ).count
    @fail = Digit.where('digit_recognize != digit_user_marked AND user_id = ?', current_user.id).count
    @unmarked = Digit.where(digit_user_marked: nil, user_id: current_user.id).count
  end
end
