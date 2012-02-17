#!/usr/bin/env ruby

require 'rubygems'
require 'clamp'
require '../lib/vcloud_upload'

class VClient < Clamp::Command


  subcommand "upload", "Upload an OVG" do
    parameter "USERNAME", "The username"
    parameter "PASSWORD", "The password"
    parameter "ORG", "Your organisation"
    parameter "HOST", "The vCloud host"
    parameter "NAME", "The name of the virtual machine"
    parameter "FILENAME", "The name of the OVF file without extension"
    parameter "[DIR]", "Dir of the OVF file", :default => '.'
    parameter "[DESCRIPTION]", "A description of your VM", :default => ""

    def execute

      VCloudUpload::Client.session(username, org, password, host) do |client|

        STDIN.puts "Choose a vDC:\n"
        i = 0
        client.each(:vdc) do |vdc|
          i += 1
          STDIN.puts "#{i.to_s}. #{vdc.name} \n"
        end
        i = STDIN.gets.chomp.to_i

        STDIN.puts "Choose a catalog:\n"
        j = 0
        client.each(:catalog) do |item|
          j += 1
          STDIN.puts "#{j.to_s}. #{item.name}"
        end
        j = STDIN.gets.chomp.to_i


        client.upload_ovf(client.each(:vdc)[i-1].link, client.each(:catalog)[j-1].link, name, filename, dir, {:description => description}) do |status|

          STDIN.puts status.to_s + "%"

        end

      end
    end
  end

end

VClient.run