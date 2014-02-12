require 'fileutils'

class RecognizerController < ApplicationController
  include RecognizerHelper
  protect_from_forgery except: :test

  @@network = Network.new

  def index
  end

  def recognize
    pixels = params[:pixels]

    data = Array.new(32)
    for i in 0..31
      data[i] = Array.new(32, -0.1)
    end

    for i in 0..27
      for j in 0..27
        data[2+i][2+j] = pixels[i*28+j].to_f/200.0 - 0.1
      end
    end

    digitsChance = @@network.compute(data)
    if signed_in?
      digit = Digit.create!(digit_recognize: recognizeDigit(digitsChance), user_id: @current_user.id)

      path = "#{Rails.root}/public/uploads/" + @current_user.id.to_s;
      save path, digit.id, params[:data_uri]
    end

    render :json => digitsChance
  end

  private
    def recognizeDigit(digitsChance)
      digit = 0
      digitChance = digitsChance[0]
      for i in 1..9
        if digitsChance[i] > digitChance
          digit = 9
          digitChance = digitsChance[i]
        end
      end

      return digit
    end

    def save(path, fileId, data)
      image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

      unless File.directory?(path)
        FileUtils.mkdir_p(path)
      end

      File.open(path + "/" + fileId.to_s + '.png', 'wb+') do |f|
        f.write image_data
      end
    end

end
