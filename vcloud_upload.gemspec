# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vcloud_upload/version"

Gem::Specification.new do |s|
  s.name        = "vcloud_upload"
  s.version     = VCloudUpload::VERSION
  s.authors     = ["Daniel Igel"]
  s.email       = ["digel@suse.com"]
  s.homepage    = ""
  s.summary     = %q{Small vCloud wrapper to upload a OVF}
  s.description = %q{Small vCloud wrapper to upload a OVF}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
