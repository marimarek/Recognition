module RecognizerHelper
  class FeatureMap
    def initialize(width, height, weight)
      @neurons = Array.new(height)
      @biasNeuron = InputNeuron.new
      @biasNeuron.in(1.0)

      for i in 0..height-1
        @neurons[i] = Array.new(width)
        for j in 0..width-1
          @neurons[i][j] = Neuron.new
          Connection.new(@biasNeuron, @neurons[i][j], weight)
        end
      end
    end

    def at(x, y)
      return @neurons[x][y]
    end

    def width
      if(@neurons.empty?)
        return 0
      end
      return @neurons[0].count
    end

    def height
      return @neurons.count
    end

    def reset
      for i in 0..height-1
        for j in 0..width-1
          @neurons[i][j].reset
        end
      end
    end
  end
end