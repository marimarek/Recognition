module RecognizerHelper
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