module Fog
  module Compute
    class Stdyun

      class Mock
        def getall_machines(options={})
          res = Excon::Response.new
          res.status = 200
          res.body = self.data[:machines].values
          res
        end
      end

      class Real
        def getall_machines(options={})
          request(
            :path => "/api/v1/machines",
            :method => "GET",
            :query => options
          )
        end
      end
    end
  end
end
