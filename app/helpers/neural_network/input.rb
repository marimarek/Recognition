module RecognizerHelper
  class Input
    def initialize(width, height)
      @neurons = Array.new(height)

      for i in 0..height-1
        @neurons[i] = Array.new(width)
        for j in 0..width-1
          @neurons[i][j] = InputNeuron.new
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

    def readInput(data)
      for i in 0..height-1
        for j in 0..width-1
          @neurons[i][j].in(data[i][j])
        end
      end
    end
  end
end