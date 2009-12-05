require 'test/unit'
require 'time'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rbankgiro'

def fixture_file_path(filename)
  return '' if filename == ''
  File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
end
