module RecognizerHelper
  class Neuron
    def initialize
      @ready = false
      @outValue = 0
      @ins = Array.new
      @outs = Array.new
    end

    def out
      if(@ready == false)
        sum = 0.0;
        @ins.each do |inConnection|
          sum += inConnection.out
        end

        @outValue = outFun(sum)
        @ready = true
      end

      return @outValue
    end

    def reset
      @ready = false
    end

    def addInputConn(conn)
      @ins << conn
    end

    def addOutputConn(conn)
      @outs << conn
    end

    def nbrOfIns
      return ins.count
    end

    def nbrOfOuts
      return outs.count
    end

    private
    def outFun(x)
      return 1.7159*Math.tanh(2.0*x/3.0)
    end
  end
end