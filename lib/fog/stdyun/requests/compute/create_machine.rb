module Fog
  module Compute
    class Stdyun
      class Real
        def create_machine(params = {})
          request(
            :method => "POST",
            :path => "/api/v1/machines",
            :expects => [200, 201, 202],
            :body => {
                       "dataset" => 'stdyun:stdyun:ubuntu-12.04:1.0.0',
                       "package" => "m2",
                       "metadata" => {"credentials" => {"stdyun" => "stdyunrocks"}}
                     }
          )
        end
      end
    end
  end
end
