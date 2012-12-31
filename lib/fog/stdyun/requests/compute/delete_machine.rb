module Fog
  module Compute
    class Stdyun
      class Real
        def delete_machine(machine_id)
          request(
            :path => "/api/v1/machines/#{machine_id}",
            :method => "DELETE",
            :expects => [200, 204]
          )
        end
      end
    end
  end
end
