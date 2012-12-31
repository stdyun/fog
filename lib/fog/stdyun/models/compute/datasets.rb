require 'fog/stdyun/models/compute/dataset'

module Fog
  module Compute
    class Stdyun
      class Datasets < Fog::Collection

        model Fog::Compute::Stdyun::Dataset

        def all
          data = connection.getall_datasets.body
          load(data)
        end

        def get(name)
          data = connection.get_dataset(name).body
          if data
            new(data)
          else
            nil
          end
        end

      end
    end
  end
end
