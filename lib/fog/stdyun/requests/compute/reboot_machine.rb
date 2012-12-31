module Fog
  module Compute
    class Stdyun
      class Real
        def reboot_machine(id)
          request(
            :method => "POST",
            :query => {"action" => "reboot"},
            :path => "/api/v1/machines/#{id}"
          )
        end
      end
    end
  end
end
