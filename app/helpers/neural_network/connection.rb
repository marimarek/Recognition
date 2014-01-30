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
end