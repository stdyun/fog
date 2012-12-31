module Fog
  module Compute
    class Stdyun

      class Mock
        def get_dataset(id)
          if ds = self.data[:datasets][id]
            res = Excon::Response.new
            res.status = 200
            res.body = ds
          else
            raise Excon::Errors::NotFound
          end
        end
      end

      class Real
        def get_dataset
          request(
            :method => "GET",
            :path => "/api/v1/datasets"
          )
        end
      end

    end
  end
end
