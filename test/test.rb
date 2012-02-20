$: << File.join(File.dirname(__FILE__), "..", "lib")

require 'vcloud_upload'
require '../test/test_helper'

class TestUpload < Test::Unit::TestCase

  def test_upload

      cloudup = VCloudUpload::Client.new('Max_Mustermann', 'SRo', '123456', "example.com")

      i = 0
      cloudup.each('vdc') do |vdc|
        i += 0
        puts "#{i.to_s}. #{vdc.name}"
      end
      i = gets.chomp.to_i

      j = 0
      cloudup.each('catalog') do |item|
        j += 1
        puts "#{j.to_s}. #{item.link}"
      end
      j = gets.chomp.to_i

    cloudup.upload_ovf(cloudup.each('vdc')[i].link, cloudup.each('catalog')[j].link, 'vCloudUpload Test',  'vCloudUpload.i686-0.0.1','/home/user/vCloudUpload-0.0.1', 'Just a little test.', 52000000)

    puts client.status

    cloudup.logout


    # Block version

    VCloudUpload.session('Max_Mustermann', 'SRo', '123456', "localhost") do |client|

      i = 0
      client.each('vdc') do |vdc|
        i += 0
        puts "#{i.to_s}. #{vdc.name}"
      end
      i = gets.chomp.to_i

      j = 0
      client.each('catalog') do |item|
        j += 1
        puts "#{j.to_s}. #{item.link}"
      end
      j = gets.chomp.to_i

      client.upload_ovf(client.each('vdc')[i].link, client.each('catalog')[j].link, 'vCloudUpload Test',  'vCloudUpload.i686-0.0.1','/home/user/vCloudUpload-0.0.1', 'Just a little test.', 100)

      puts client.status
    end


  end

end
