#!/usr/bin/env ruby

require 'rubygems'
require 'clamp'
require '../lib/vcloud_upload'

class VClient < Clamp::Command


  subcommand "upload", "Upload an OVG" do
    parameter "FILENAME", "The name of the OVF file without extension"
    parameter "[DIR]", "Dir of the OVF file", :default => '.'
    parameter "[DESCRIPTION]", "A description of your VM", :default => ""

    def execute


      puts "Username: "
      username = STDIN.gets.chomp

      puts "Password: "
      password = STDIN.gets.chomp

      puts "Organisation: "
      org = STDIN.gets.chomp

      puts "vCloud host: "
      host = STDIN.gets.chomp

      puts "Name of virtual machine: "
      name = STDIN.gets.chomp

      VCloudUpload::Client.session(username, org, password, host) do |client|

        puts "Choose a vDC:\n"
        i = 0
        client.each(:vdc) do |vdc|
          i += 1
          puts "#{i.to_s}. #{vdc.name} \n"
        end
        i = STDIN.gets.chomp.to_i

        puts "Choose a catalog:\n"
        j = 0
        client.each(:catalog) do |item|
          j += 1
          puts "#{j.to_s}. #{item.name}"
        end
        j = STDIN.gets.chomp.to_i

        i = 0
        c = String.new

        client.uploadOVF(client.each(:vdc)[i-1].link, client.each(:catalog)[j-1].link, name, filename, dir, {:description => description}) do |status|

          puts status.to_s + "%"

        end

      end
    end
  end

end

VClient.run