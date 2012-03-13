require 'rubygems'

ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

$KCODE = "U"
require 'jcode' if RUBY_VERSION < '1.9'
