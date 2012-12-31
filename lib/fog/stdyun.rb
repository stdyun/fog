module Fog
  module Stdyun
    extend Fog::Provider

    service(:compute, 'stdyun/compute', 'Compute')

  end
end
