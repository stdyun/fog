module Fog
  module Compute
    class Stdyun
      class Real
        def stop_machine(uuid)
          request(
            :method => "POST",
            :path => "/api/v1/machines/#{uuid}",
            :query => {"action" => "stop"},
            :expects => 200
          )
        end
      end
    end
  end
end
