module Fog
  module Compute
    class Stdyun
      class Dataset < Fog::Model
        identity :id

        attribute :id
        attribute :name
        attribute :urn
        attribute :os
        attribute :default

        def get
          requires :name
          self.connection.get_dataset(name)
        end

        def getall
          self.connection.getall_datasets()
        end
      end
    end
  end
end
