require File.expand_path(File.join(File.dirname(__FILE__), '/../lib/hollybush'))

RSpec.configure do |config|
  config.before(:each) do
    $mongodb.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
  end
end
