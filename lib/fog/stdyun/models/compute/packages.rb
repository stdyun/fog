require 'fog/stdyun/models/compute/package'

module Fog
  module Compute
    class Stdyun
      class Packages < Fog::Collection

        model Fog::Compute::Stdyun::Package

        def all
          data = connection.getall_packages().body
          load(data)
        end

        def get(name)
          data = connection.get_package(name).body
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
