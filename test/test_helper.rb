require 'test/unit'
require 'config/environment'

def load_stdin_fixture filename
  file = load_fixture_file filename
  $stdin = file.read
end

def load_fixture_file filename
  filepath = File.join(ROOT, "test", "fixtures", filename)
  return nil if !File.exists?(filepath)
  file = File.open(filepath, 'rb:UTF-8')
end

