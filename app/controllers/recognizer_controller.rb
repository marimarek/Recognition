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

    render :json => @@network.compute(data)
  end
end
