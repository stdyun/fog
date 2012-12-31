module Fog
  module Compute
    class Stdyun
      class Package < Fog::Model
        identity :name

        attribute :name
        attribute :vcpus
        attribute :memory
        attribute :disk
        attribute :bandwidth
        attribute :default

        def get
          requires :name
          self.connection.get_package(name)
        end

        def getall
          self.connection.getall_packages()
        end
      end
    end
  end
end
