require 'config/environment'
require 'hpricot'

class Article
  attr_accessor :publication_date
  attr_accessor :byline
  attr_accessor :body
  attr_accessor :dateline
  attr_accessor :descriptors
  attr_accessor :taxonomic_classifiers
  attr_accessor :locations
  attr_accessor :page
  attr_accessor :column_number #typically 6 columns per page
  def initialize(file)
  end
end
