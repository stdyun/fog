module Fog
  module Compute
    class Stdyun

      class Mock
        def get_machine(uuid)
          if machine = self.data[:machines][uuid]
            res = Excon::Response.new
            res.status = 200
            res.body = machine
            res
          else
            raise Excon::Errors::NotFound, "Not Found"
          end
        end
      end

      class Real
        def get_machine(uuid)
          request(
            :method => "GET",
            :path => "/api/v1/machines/#{uuid}",
            :expects => 200
          )
        end
      end
    end
  end
end
