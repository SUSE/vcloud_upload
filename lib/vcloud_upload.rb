require "vcloud_upload/version"

#@author Daniel Igel
#@version 0.0.1

module VCloudUpload

  class Item

    attr_accessor :name
    attr_accessor :link

    # Return the name and the link together in a string.
    #
    # @return [String] (see description)
    def to_s
      "#{self.name} => #{self.link}"
    end

  end


  def self.session (username, org, password, host)

    begin
        client = Client.new(username, org, password, host)

        yield client if block_given?

    rescue Exception => e
        raise e
    ensure
        client.logout if !client.nil?
    end

  end

  require "base64"
  require 'rubygems'
  require 'rest_client'
  require 'rexml/document'

  class Client

    public




    # Initialize the Client.
    #
    # @example Initialize
    #   vClient = VCloudUpload::Client.new({:username=>'Emma_Example', :org=>'SRo', :password=>'123456', :host=>'https://vcd1.example.com'})
    #
    # @param [String]  username The username
    # @param [String] org  Name of the Organisation in the Cloud
    # @param [String] password The password
    # @param [String] host The cloud host address

    def initialize(username, org, password, host)

      @host = host + "/api/v1.0/"
      @username = username

      # Encode base_user_string (example: Max_Musterman@SRo:mypassword)
      @base_user_string = (Base64.b64encode(username + '@' + org + ':' + password)).chomp!


      login()

    end



    # Perform the logout.
    # @example A logout after a login
    #   vClient = VCloudUpload::Client.new({:username=>'Emma_Example', :org=>'SRo', :password=>'123456', :host=>'https://vcd1.example.com'}
    #
    #   vClient.logout
    #
    # @note The authentication key will be wasted after 30 min when you don't call this method!'
    def logout
      # Logout
      response = request({:method => "POST", :uri => @host + "logout"})
    end

    # Create a list of item witch contains the name and the link of all vDCs'.
    #
    # @example Print a list of vDC's
    #   vClient = OpenCloudUP::Client.new({:username=>'Emma_Example', :org=>'SRo', :password=>'123456', :host=>'https://vcd1.example.com'}
    #   vClient.login
    #
    #   vClient.each('vdc') do |vdc|
    #        puts "Name:  #{vdc.name}\nLink: #{vdc.link}"
    #   end
    #
    #   vClient.logout
    #
    #  @param [String] item Which element you want to list
    #  @return [Array]  You can handle the return like vDC[0].name
    def each(type)
      # call vDC list
      response = request({:method => 'GET', :uri => @org_link})

      # parse the list
      out = Array.new

      content = parse_content(response, '//Link')

      content.each { |e|

        # each node
        if e.attribute('type').to_s=="application/vnd.vmware.vcloud.#{type}+xml"

          item = Item.new

          item.name = e.attribute('name').to_s
          item.link = e.attribute('href').to_s

          yield item if block_given?

          out << item
        end

      }

      out
    end

    # Get the status of the upload
    #
    # @return [Integer] Return the status of the upload in percent.
    def status

      respone = request({:uri=>@vapp_link, :method=>'GET'})

      bytestransfered = parse_content(respone, '//Files/File/Link')[0].attribute('bytesTransferred')
      size = parse_content(respone, '//Files/File/Link')[0].attribute('size')

      (bytestransfered.to_i / size.to_i + 100)

    end


    # Upload the OVF and the image in packages sized by the variable #blocksize or automatically with 50MB.
    #
    # @example A logout after a login
    #   vClient = OpenCloudUP::Client.new({:username=>'Emma_Example', :org=>'SRo', :password=>'123456', :host=>'https://vcd1.example.com'}
    #   vClient.login
    #
    #   vDC = vClient.each_vdc
    #   i = 0
    #   vDC.each do |dc|
    #      i += 1
    #      puts "#{i.to_s}. #{dc.link}"
    #   end
    #   i = gets.chomp
    #
    #   catalog = vClient.each_catalog('catalog')
    #   j = 0
    #   catalog.each do |cat|
    #      j += 1
    #      puts "#{j.to_s}. #{cat.name}"
    #   end
    #
    #   vClient.uploadOVF(vDC[i-1].link, catalog[j-1].link, 'My VM', 'openSUSE-12.1-i586', '/home/me/VM', 'My first virtual machine', 52428800)
    #
    #   vClient.logout"
    #
    # @param [String] vDC_Link Link of the selected virtual datacenter.
    # @param [String] catalog_link Link of the selected catalog.
    # @param [String] vmname Name of the virtual machine.
    # @param [String] filename The filename without the extension .ovf
    # @param [String] filepath The path to the folder which contains the ovf AND the needed files.
    # @param [optional, String] description Optional a description of your virtual machine.
    # @param [optional, Integer] blocksize The file will be send in packages. This is the package size in bytes (standard = 50MB).
    # @return [optional, String] This method can throw an exception with the error message sent by the vCloud.
    def uploadOVF(vDC_Link, catalog_link, vmname, filename, filepath, description = '', blocksize = 52428800)

      begin
        # Build needed vApp description
        send = "<UploadVAppTemplateParams name=\"#{vmname}\" xmlns=\"http://www.vmware.com/vcloud/v1\"> \n
                <Description>#{description}</Description>\n</UploadVAppTemplateParams>"

        # Create new vApp-Template
        response = RestClient.post("#{vDC_Link}/action/uploadVAppTemplate", send,{
                                    :content_type => 'application/vnd.vmware.vcloud.uploadVAppTemplateParams+xml',
                                    'x-vcloud-authorization' => @auth_key})

        # Find upload link for the descriptor
        upload_link = parse_content(response, '//Files/File/Link')[0].attribute('href').to_s

        # Link to the new created vApp
        @vapp_link = parse_content(response, 'VAppTemplate')[0].attribute('href').to_s

        # Read ovf
        file = File.read("#{filepath}/#{filename}.ovf")

        # Start upload the ovf if possible

        response = RestClient.put(upload_link, file, {:content_type => 'text/xml', 'x-vcloud-authorization' => @auth_key})
        raise response if (response.code!=200)

        response = request({:uri => @vapp_link})
        raise response if (response.code!=200)


        # Get name and upload link of the needed vmdk files
        parse_content(response, '//Files/File').each do |data|

          if data.attribute('name').to_s!='descriptor.ovf'
            name = data.attribute('name').to_s
            size = data.attribute('size').to_s
            upload_link = parse_content(data.to_s, '//Link')[0].attribute('href').to_s

            # Read vmdk file
            fd = IO.sysopen("#{filepath}/#{name}", 'r')
            stream = IO.new(fd, 'r')
            tmp = 0

            until stream.eof?
              # Read the byte block from the fiel
              block = stream.read(blocksize)

              tmpsize = block.unpack("C*").size
              range = "bytes #{tmp}-#{tmp+tmpsize}/#{size}"

              # Send the block
              response = RestClient.put(upload_link, block, {'Content-length' => tmpsize, 'Content-Range' => range,'x-vcloud-authorization' => @auth_key})
              raise response if (response.code!=200)

              tmp += tmpsize
            end

            # Move the vApp to the Catalog
            send = "<CatalogItem name=\"#{vmname}\" xmlns=\"http://www.vmware.com/vcloud/v1\"> \n
                        <Description>#{description}</Description>\n
                        <Entity href=\"#{@vapp_link}\"/>\n
                        <Property key=\"Owner\">#{@username}</Property>
                    </CatalogItem>"

            response = RestClient.post("#{catalog_link}/catalogItems", send,{
                                    :content_type => 'application/vnd.vmware.vcloud.catalogItem+xml',
                                    'x-vcloud-authorization' => @auth_key})
            raise response if (response.code!=200)
          end
        end
      rescue Exception => e

        e

      end
    end


  # Private methods~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    private

    # Login to the Cloud.
    #
    # @note You have to call this method before any other will work!
    def login ()

      #definde needed header
      headers = {'Authorization' => "Basic " + @base_user_string}

      #Login
      response = request({:method => "POST", :uri => @host + "login", :headers => headers})

      #Get organisation link
      @org_link = parse_content(response.body, '//Org')[0].attribute('href').to_s

      #Get  authentication header key
      @auth_key = response.headers[:x_vcloud_authorization]

    end



    # Send a HTTP request
    #
    #
    # @param [Hash] params Contains the url, body, headers and set the request method and the expected response code.
    # @option [String] :uri The url of the request
    # @option [String] :body The request body.
    # @option [String] :headers The request headers.
    # @option [Integer] :expect The expected response code.
    # @option [String] :method The used method('GET', 'POST', 'PUT')
    # @return [RestClient::Response]  See RestClient documentation.
    def request(params)
      begin

        # Add auth header
        headers = params[:headers] || {}
        headers['x-vcloud-authorization'] = @auth_key if !@auth_key.equal?('')

        # set connection options
        options = {
                    :url => params[:uri],
                    :body => params[:body] || '',
                    :expects => params[:expects] || 200,
                    :headers => headers,
                    :method => params[:method] || 'GET'
                  }

        # connect
        res = RestClient::Request.execute options

        raise res if (res.code!=params[:expects] && res.code!=200)

        res
      rescue Exception => e
         raise e
      end

    end

    # Parse the XML response
    #
    # @visibility public
    #
    # @param [String, #response] The incoming response.
    # @param [String, #item] The searched node.
    # @return [Array, REXML::Node]  See REXML documentation.
    def parse_content(response, item)

      # Create XML document
      document = REXML::Document.new(response)

      # Ini output array
      out = Array.new()

      # looking for item
      REXML::XPath.each(document, item) {
        |e|  out << e
      }

      out
    end


  end

end