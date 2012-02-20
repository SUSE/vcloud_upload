require 'test/unit'
require 'vcr'


VCR.config do |c|
  c.cassette_library_dir = '../test/fixtures/vcr_cassettes'
  c.stub_with :webmock
end
