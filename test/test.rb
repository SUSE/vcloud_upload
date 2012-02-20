$: << File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'vcloud_upload'

class TestUpload < Test::Unit::TestCase


  def test_upload
      require "test/test_helper.rb"

       VCR.use_cassette('example_com', :record => :once) do
        cloudup = VCloudUpload::Client.new('Max_Mustermann', 'SRo', '123456', "example.com")

        puts 'All vDCs:'
        i = 0
        cloudup.each(:vdc) do |vdc|
          i += 1
          puts "#{i.to_s}. #{vdc.name}"
        end

        puts 'All catalogs:'
        j = 0
        cloudup.each(:catalog) do |item|
          j += 1
          puts "#{j.to_s}. #{item.name}"
        end


      cloudup.upload_ovf(cloudup.each(:vdc)[0].link, cloudup.each(:catalog)[1].link, 'vCloudUpload Test',  'vCloudUpload.i686-0.0.1','test')

      cloudup.logout

     end

    end

end
