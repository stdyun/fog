module Fog
  module Compute
    class Stdyun

      class Mock
        def getall_packages
          response = Excon::Response.new()
          response.status = 200
          response.body = self.data[:packages].values
          response
        end
      end

      class Real
        # Lists all the packages available to the authenticated user
        # ==== Returns
        # Exon::Response<Array>
        # * name<~String> The "friendly name for this package
        # * memory<~Number> How much memory will by available (in Mb)
        # * disk<~Number> How much disk space will be available (in Gb)
        # * swap<~Number> How much swap memory will be available (in Mb)
        # * default<~Boolean> Whether this is the default package in this datacenter"
        #
        def getall_packages
          request(
            :path => "/api/v1/packages",
            :method => "GET",
            :expects => 200
          )
        end
      end # Real

    end

  end
end
