require 'config/environment'
require 'csv'
require 'app/models/Article'

class ArticleSet

  attr_accessor :articles

  def initialize
    @articles = Array.new
  end

  def self.csv_filename(year, month)
    month = "0"+month.to_s if month < 10
    return "data_"+year.to_s+"_"+month.to_s+".csv"
  end

  def self.from_csv_file(filename)
    set = ArticleSet.new
    # load into memory
    all_rows = CSV.read(filename)
    row_index = 0
    all_rows.each do |row|
      if row_index > 0  # first row has titles
	set.articles << Article.from_metadata_csv_row(row)
      end
      row_index += 1
    end
    return set
  end
  
  def article_count
    return @articles.length
  end
    
  def get_matching(regex)
    @data.delete_if do |attribute, info|
      attribute.match(/^#{regex}$/) ? false : true
    end
  end
  
end
