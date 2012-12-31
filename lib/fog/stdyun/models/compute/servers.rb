require 'fog/core/collection'
require 'fog/stdyun/models/compute/server'

module Fog
  module Compute

    class Stdyun
      class Servers < Fog::Collection
        model Fog::Compute::Stdyun::Server

        def all
          data = self.connection.getall_machines().body
          load(data)
        end

        def create(params = {})
          data = self.connection.create_machine(params).body
          server = new(data)
          server
        end

        def bootstrap(new_attributes = {})
          server = create(new_attributes)
          server.wait_for { ready? }
          server
        end

        def get(machine_id)
          data = self.connection.get_machine(machine_id).body
          new(data)
        end

        def getall
          data = self.connection.getall_machines().body
          load(data)
        end

      end
    end # Stdyun

  end # Compute
end # Fog
