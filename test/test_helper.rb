require 'test/unit'
require 'vcr'


VCR.config do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.stub_with :fakeweb
end