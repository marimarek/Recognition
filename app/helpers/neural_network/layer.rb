module RecognizerHelper
  class Layer
    def initialize(size, weights)
      @neurons = Array.new(size)
      @biasNeurons = Array.new(size)

      for i in 0..size-1
        @neurons[i] = Neuron.new
        @biasNeurons[i] = InputNeuron.new
        @biasNeurons[i].in(1.0)
        Connection.new(@biasNeurons[i], @neurons[i], weights[i])
      end
    end

    def at(i)
      return @neurons[i]
    end

    def size
      return @neurons.count
    end

    def reset
      for i in 0..size-1
        @neurons[i].reset
      end
    end
  end
end