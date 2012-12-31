module Fog
  module Compute
    class Stdyun

      class Mock
        def getall_datasets
          res = Excon::Response.new
          res.status = 200
          res.body = self.data[:datasets].values
          res
        end
      end

      class Real
        def getall_datasets
          request(
            :method => "GET",
            :path => "/api/v1/datasets"
          )
        end
      end
    end
  end
end
