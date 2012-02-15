$: << File.join(File.dirname(__FILE__), "..", "lib")

require 'vcloud_upload'

class TestUpload < Test::Unit::TestCase

  def test_upload

      cloudup = VCloudUpload::Client.new('Max_Mustermann', 'SRo', '123456', "https://vcd1.example.com")

      i = 0
      cloudup.each_vdc.each do |vdc|
        i += 0
        puts "#{i.to_s}. #{vdc.name}"
      end
      i = gets.chomp.to_i

      j = 0
      cloudup.each_catalog.each do |item|
        j += 1
        puts "#{j.to_s}. #{item.link}"
      end
      j = gets.chomp.to_i

    cloudup.uploadOVF(cloudup.each_vdc[i].link, cloudup.each_catalog[j].link, 'vCloudUpload Test',  'vCloudUpload.i686-0.0.1','/home/user/vCloudUpload-0.0.1', 'Just a little test.', 52000000)

    cloudup.logout

  end

end
