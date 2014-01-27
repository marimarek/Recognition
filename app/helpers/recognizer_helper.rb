module RecognizerHelper
  class Connection
    def initialize(inNeuron, outNeuron, weight)
      @in = inNeuron
      @out = outNeuron
      @weight = weight


      @out.addInputConn(self)
      @in.addOutputConn(self)
    end

    def out
      return @in.out*@weight;
    end

    def self.convolution(input, output, featureWidth, featureHeight, weights )
      for i in 0..output.height-1
        for j in 0..output.width-1
          for k in 0..featureHeight-1
            for l in 0..featureWidth-1
              Connection.new(input.at(i+k, j+l), output.at(i, j), weights[k][l])
            end
          end
        end
      end

    end

    def self.subsampling(input, output, featureWidth, featureHeight, weight)
      for i in 0..output.height-1
        for j in 0..output.width-1
          for k in 0..featureHeight-1
            for l in 0..featureWidth-1
              Connection.new(input.at(i*featureHeight+k, j*featureWidth+l), output.at(i, j), weight)
            end
          end
        end
      end

    end


    def self.full_connnection_ll(input, output, weights)
      for i in 0..input.size-1
        for j in 0..output.size-1
          Connection.new(input.at(i), output.at(j), weights[i][j])
        end
      end
    end

    def self.full_connnection_fl(input, output, weights)
      for i in 0..input.height-1
        for j in 0..input.width-1
          for k in 0..output.size-1
            Connection.new(input.at(i, j), output.at(k), weights[i][j][k])
          end
        end
      end
    end
  end

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



  class InputNeuron < Neuron
    def in( input)
      @ready = true
      @outValue = input
    end
  end


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

  class Network
    def initialize
      f = File.open('weights.ws', 'rb')

      @input = Input.new(32, 32)
      @layerC1 = Array.new(6)
      @layerS2 = Array.new(6)
      @layerC3 = Array.new(16)
      @layerS4 = Array.new(16)
      @layerC5 = Array.new(120)

      weights = Array.new(84)
      for i in 0..weights.count-1
        the_float_as_string = f.read(8)
        weights[i] = the_float_as_string.unpack('G')[0]
      end
      @layerF6 = Layer.new(84, weights)

      weights = Array.new(10)
      for i in 0..weights.count-1
        the_float_as_string = f.read(8)
        weights[i] = the_float_as_string.unpack('G')[0]
      end
      @output = Layer.new(10, weights)

      for i in 0..@layerC1.count-1
        @layerC1[i] = FeatureMap.new(28, 28, f.read(8).unpack('G')[0])
        @layerS2[i] = FeatureMap.new(14,14, f.read(8).unpack('G')[0])
      end
      for i in 0..@layerC3.count-1
        @layerC3[i] = FeatureMap.new(10,10, f.read(8).unpack('G')[0])
        @layerS4[i] = FeatureMap.new(5,5, f.read(8).unpack('G')[0])
      end
      for i in 0..@layerC5.count-1
        @layerC5[i] = FeatureMap.new(1,1, f.read(8).unpack('G')[0])
      end

      for i in 0..@layerC1.count-1
        weights = Array.new(5)
        for k in 0..4
          weights[k] = Array.new(5)
          for l in 0..4
            the_float_as_string = f.read(8)
            weights[k][l] = the_float_as_string.unpack('G')[0]
          end
        end
        Connection.convolution(@input, @layerC1[i], 5, 5, weights)
        Connection.subsampling(@layerC1[i], @layerS2[i], 2, 2, f.read(8).unpack('G')[0])
      end

      #convolution S2-C3
      for i in 0..11
        for j in 0..2
          weights = Array.new(5)
          for k in 0..4
            weights[k] = Array.new(5)
            for l in 0..4
              the_float_as_string = f.read(8)
              weights[k][l] = the_float_as_string.unpack('G')[0]
            end
          end
          Connection.convolution(@layerS2[(i+j)%6], @layerC3[i], 5, 5, weights)
        end
      end

      for i in 6..11
        weights = Array.new(5)
        for k in 0..4
          weights[k] = Array.new(5)
          for l in 0..4
            the_float_as_string = f.read(8)
            weights[k][l] = the_float_as_string.unpack('G')[0]
          end
        end
        Connection.convolution(@layerS2[(i+3)%6], @layerC3[i], 5, 5, weights)
      end

      for i in 12..14
        for j in 0..1
          weights = Array.new(5)
          for k in 0..4
            weights[k] = Array.new(5)
            for l in 0..4
              the_float_as_string = f.read(8)
              weights[k][l] = the_float_as_string.unpack('G')[0]
            end
          end
          Connection.convolution(@layerS2[(i+j)%6], @layerC3[i], 5, 5, weights)
        end
        for j in 3..4
          weights = Array.new(5)
          for k in 0..4
            weights[k] = Array.new(5)
            for l in 0..4
              the_float_as_string = f.read(8)
              weights[k][l] = the_float_as_string.unpack('G')[0]
            end
          end
          Connection.convolution(@layerS2[(i+j)%6], @layerC3[i], 5, 5, weights)
        end
      end

      for i in 0..5
        weights = Array.new(5)
        for k in 0..4
          weights[k] = Array.new(5)
          for l in 0..4
            the_float_as_string = f.read(8)
            weights[k][l] = the_float_as_string.unpack('G')[0]
          end
        end
        Connection.convolution(@layerS2[i], @layerC3[15], 5, 5, weights)
      end
      #convolution S2-C3

      for i in 0..@layerC3.count-1
        Connection.subsampling(@layerC3[i], @layerS4[i], 2, 2, f.read(8).unpack('G')[0])
      end

      for i in 0..@layerS4.count-1
        for j in 0..@layerC5.count-1
          weights = Array.new(5)
          for k in 0..4
            weights[k] = Array.new(5)
            for l in 0..4
              the_float_as_string = f.read(8)
              weights[k][l] = the_float_as_string.unpack('G')[0]
            end
          end
          Connection.convolution(@layerS4[i], @layerC5[j], 5, 5, weights)
        end
      end

      for i in 0..@layerC5.count-1
        weights = Array.new(@layerC5[i].height)
        for k in 0..@layerC5[i].height-1
          weights[k] = Array.new(@layerC5[i].width)
          for l in 0..@layerC5[i].width-1
            weights[k][l] = Array.new(@layerF6.size)
            for m in 0..@layerF6.size-1
              the_float_as_string = f.read(8)
              weights[k][l][m] = the_float_as_string.unpack('G')[0]
            end
          end
        end
        Connection.full_connnection_fl(@layerC5[i], @layerF6, weights)
      end

      weights = Array.new(@layerF6.size)
      for i in 0..@layerF6.size-1
        weights[i] = Array.new(@output.size)
        for j in 0..@output.size-1
          the_float_as_string = f.read(8)
          weights[i][j] = the_float_as_string.unpack('G')[0]
        end
      end
      Connection.full_connnection_ll(@layerF6, @output, weights)
    end


    def compute(data)
      reset
      @input.readInput(data)

      output = Array.new(10)
      for i in 0..9
        output[i] = @output.at(i).out
      end

      return output
    end


    def reset
      @input.reset

      for i in 0..@layerC1.size-1
        @layerC1[i].reset
      end
      for i in 0..@layerS2.size-1
        @layerS2[i].reset
      end
      for i in 0..@layerC3.size-1
        @layerC3[i].reset
      end
      for i in 0..@layerS4.size-1
        @layerS4[i].reset
      end
      for i in 0..@layerC5.size-1
        @layerC5[i].reset
      end

      @layerF6.reset
      @output.reset
    end
  end
end
