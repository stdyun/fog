require 'fog/stdyun'
require 'fog/stdyun/errors'
require 'fog/compute'
require 'crack'
require 'crack/json'

module Fog
  module Compute
    class Stdyun < Fog::Service
      requires :stdyun_username

      recognizes :stdyun_password
      recognizes :stdyun_url
      recognizes :stdyun_keyname
      recognizes :stdyun_keyfile

      model_path 'fog/stdyun/models/compute'
      request_path 'fog/stdyun/requests/compute'

      # Servers
      collection :servers
      model :server
      request :create_machine
      request :reboot_machine
      request :stop_machine
      request :delete_machine
      request :get_machine
      request :getall_machines

      # Packages
      collection :packages
      model :packages
      request :get_package
      request :getall_packages

      # Datasets
      collection :datasets
      model :datasets
      request :get_dataset
      request :getall_datasets

      class Mock
        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {}
          end
        end

        def data
          self.class.data
        end

        def initialize(options = {})
          @stdyun_username = options[:stdyun_username] || Fog.credentials[:stdyun_username]
          @stdyun_password = options[:stdyun_password] || Fog.credentials[:stdyun_password]
        end

        def request(opts)
          raise "Not Implemented"
        end
      end # Mock

      class Real
        def initialize(options = {})
          @connection_options = options[:connection_options] || {}
          @persistent = options[:persistent] || false

          @stdyun_url = options[:stdyun_url] || 'https://stdyun.com'
          @stdyun_version = options[:stdyun_version] || '~1.0'

          @stdyun_username = options[:stdyun_username]

          unless @stdyun_username
            raise ArgumentError, "options[:stdyun_username] required"
          end

          if options[:stdyun_keyname] && options[:stdyun_keyfile]
            if File.exists?(options[:stdyun_keyfile])
              @stdyun_keyname = options[:stdyun_keyname]
              @stdyun_key = File.read(options[:stdyun_keyfile])

              if @stdyun_key.lines.first.include?('-----BEGIN DSA PRIVATE KEY-----')
                @key = OpenSSL::PKey::DSA.new(@stdyun_key)
              elsif @stdyun_key.lines.first.include?('-----BEGIN RSA PRIVATE KEY-----')
                @key = OpenSSL::PKey::RSA.new(@stdyun_key)
              else
                raise ArgumentError, "options[stdyun_keyfile] provided must be an RSA or DSA private key"
              end


              @header_method = method(:header_for_signature_auth)
            else
              raise ArgumentError, "options[:stdyun_keyfile] provided does not exist."
            end

          elsif options[:stdyun_password]
            @stdyun_password = options[:stdyun_password]
            @header_method = method(:header_for_basic_auth)
          else
            raise ArgumentError, "Must provide either a stdyun_password or stdyun_keyname and stdyun_keyfile pair"
          end

          @connection = Fog::Connection.new(
            @stdyun_url,
            @persistent,
            @connection_options
          )
        end

        def request(request = {})
          request[:headers] = {
            "X-Api-Version" => @stdyun_version,
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }.merge(request[:headers] || {}).merge(@header_method.call) 

          if request[:body]
            request[:body] = Fog::JSON.encode(request[:body])
          end

          response = @connection.request(request)

          if response.headers["Content-Type"].include? "application/json"
            #temp = json_decode(response.body)
            response.body = Crack::JSON.parse(response.body) #HK: change json to hash
            #response.body = Hash[*temp] #HK: change array to hash
          else
            response.body = Crack::JSON.parse(response.body) #HK: TODO change string to hash
          end

          raise_if_error!(request, response)

          response
        end

        private

        def json_decode(body)
          parsed = Fog::JSON.decode(body)
          decode_time_attrs(parsed)
        end

        def header_for_basic_auth
          {
            "Authorization" => "Basic #{Base64.encode64("#{@stdyun_username}:#{@stdyun_password}").delete("\r\n")}"
          }
        end

        def header_for_signature_auth
          date = Time.now.utc.httpdate
          begin
            signature = Base64.encode64(@key.sign("sha256", date)).delete("\r\n")
          rescue OpenSSL::PKey::PKeyError => e
            if e.message == 'wrong public key type'
              puts 'ERROR: Your version of ruby/openssl does not suport DSA key signing'
              puts 'see: http://bugs.ruby-lang.org/issues/4734'
              puts 'workaround: Please use an RSA key instead'
            end
            raise
          end
          key_id = "/#{@stdyun_username}/keys/#{@stdyun_keyname}"

          {
            "Date" => date,
            "Authorization" => "Signature keyId=\"#{key_id}\",algorithm=\"rsa-sha256\" #{signature}"
          }
        end

        def decode_time_attrs(obj)
          if obj.kind_of?(Hash)
            obj["created"] = Time.parse(obj["created"]) if obj["created"]
            obj["updated"] = Time.parse(obj["updated"]) if obj["updated"]
          elsif obj.kind_of?(Array)
            obj.map do |o|
              decode_time_attrs(o)
            end
          end

          obj
        end

        def raise_if_error!(request, response)
          case response.status
          when 401 then
            raise Errors::Unauthorized.new('Invalid credentials were used', request, response)
          when 403 then
            raise Errors::Forbidden.new('No permissions to the specified resource', request, response)
          when 404 then
            raise Errors::NotFound.new('Requested resource was not found', request, response)
          when 405 then
            raise Errors::MethodNotAllowed.new('Method not supported for the given resource', request, response)
          when 406 then
            raise Errors::NotAcceptable.new('Try sending a different Accept header', request, response)
          when 409 then
            raise Errors::Conflict.new('Most likely invalid or missing parameters', request, response)
          when 414 then
            raise Errors::RequestEntityTooLarge.new('You sent too much data', request, response)
          when 415 then
            raise Errors::UnsupportedMediaType.new('You encoded your request in a format we don\'t understand', request, response)
          when 420 then
            raise Errors::PolicyNotForfilled.new('You are sending too many requests', request, response)
          when 449 then
            raise Errors::RetryWith.new('Invalid API Version requested; try with a different API Version', request, response)
          when 503 then
            raise Errors::ServiceUnavailable.new('Either there\'s no capacity in this datacenter, or we\'re in a maintenance window', request, response)
          end
        end

      end # Real
    end
  end
end
