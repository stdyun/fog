require 'fog/compute/models/server'
module Fog
  module Compute
    class Stdyun

      class Server < Fog::Compute::Server
        identity :id

        attribute :name
        attribute :state
        attribute :type
        attribute :dataset
        attribute :ips
        attribute :memory
        attribute :disk
        attribute :metadata

        attribute :created, :type => :time
        attribute :updated, :type => :time

        def public_ip_address
          ips.empty? ? nil : ips.first
        end

        def ready?
          self.state == 'running'
        end

        def stopped?
          requires :id
          self.state == 'stopped'
        end

        def destroy
          requires :id
          self.connection.delete_machine(id)
          true
        end

        def stop
          requires :id
          self.connection.stop_machine(id)
          self.wait_for { stopped? }
          true
        end

        def reboot
          requires :id
          self.connection.reboot_machine(id)
          true
        end
      end
    end
  end
end
