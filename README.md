VMware vCloud(TM) OVF uploader [vcloud_uploader]
===============================================

Please read the complete README before you start!

How to use its
--------------

You can use the vcloud_upload on two different ways. No worry about the version, vcloud_upload supports 1.0 and 1.5 and took the right one automatically.

In both cases you have to initialize an vcloud_upload Client with you login data's. After that it is important to select a virtual datacenter(vDC) and a catalog. With these information you can upload an OVF.

The unsafe way look like this:

```ruby
require 'vcloud_upload'

client = VCloudUpload::Client.new('Username', 'Organisation', 'Password', 'vcd1.examplehost.com')


puts "Choose a vDC:\n"
i = 0
client.each(:vdc) do |vdc|
  i += 1
  puts "#{i.to_s}. #{vdc.name} \n"
end
i = gets.chomp.to_i

puts "Choose a catalog:\n"
j = 0
client.each(:catalog) do |item|
  j += 1
  puts "{#j.to_s}. #{item.name}"
end
j = gets.chomp.to_i

client.uploadOVF(client.each('vdc')[i].link, client.each('catalog')[j].link, 'Name of your VM', 'OVFFilename', 'path/to/the/ovf', 'a random description')

client.logout
```

When you know you could forget the client.logout, then try this one:

```ruby
require 'vcloud_upload'

VCloudUpload.session('Username', 'Organisation', 'Password', 'vcd1.examplehost.com') do |client|

  puts "Choose a vDC:\n"
  i = 0
  client.each('vdc') do |vdc|
    i += 1
    puts "#{i.to_s}. #{vdc.name} \n"
  end
  i = gets.chomp.to_i

  puts "Choose a catalog:\n"
  j = 0
  client.each('catalog') do |item|
    j += 1
    puts "{#j.to_s}. #{item.name}"
  end
  j = gets.chomp.to_i

  client.uploadOVF(client.each('vdc')[i].link, client.each('catalog')[j].link, 'Name of your VM', 'OVFFilename', 'path/to/the/ovf', 'a random description')

end
```

It is very import that you use the Client.logout method, because the application can throw an Error on the upload.

For more read the documentation.

License
-------

Copyright (C) 2012 SUSE LINUX Products GmbH.

vcloud_upload is licensed under the MIT license. See LICENSE for details.
