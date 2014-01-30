module RecognizerHelper
  class InputNeuron < Neuron
    def in( input)
      @ready = true
      @outValue = input
    end
  end
end