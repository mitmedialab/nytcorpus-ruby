require 'config/environment'
require 'csv'
require 'app/models/Article'

class ArticleSet

  attr_accessor :articles, :filename

  def initialize
    @articles = Array.new
  end

  def self.csv_filename(year, month)
    month = "0"+month.to_s if month < 10
    return "data_"+year.to_s+"_"+month.to_s+".csv"
  end

  def self.from_array(array_of_articles)
    set = ArticleSet.new
    set.articles = array_of_articles
    return set
  end
  
  def from_file?
    return @filename != nil
  end
  
  def self.from_csv_file(filename)
    set = ArticleSet.new
    set.filename = filename
    # load into memory
    all_rows = CSV.read(set.filename)
    row_index = 0
    all_rows.each do |row|
      if row_index > 0  # first row has titles
			  set.articles << Article.from_metadata_csv_row(row)
      end
      row_index += 1
    end
    return set
  end
  
  def to_csv(filename)
    csv_file = CSV.open(filename, "wb")
    csv_file << Article.metadata_keys
    articles.each do |article|
      csv_file << article.metadata_as_array
    end
  end
  
  def article_count
    return @articles.length
  end

  def get_matching(article_attribute_name, regex)
    valid_articles = @articles.reject do |article|
      article.has_attribute_value?(article_attribute_name, regex) ? false : true
    end
    return ArticleSet.from_array(valid_articles)
  end

  def filter_unique_articles()
    @articles.sort!{|article_a, article_b|
      if(article_a.nil? or article_b.nil? or
         article_a.headline.nil? or article_b.headline.nil?)
        0
      else
        article_a.headline <=> article_b.headline
      end
    }

    unique_articles = []
    unique_articles << @articles[0]
    @articles.each do |article|
      if !article.headline.nil? and !(article.headline == unique_articles.last.headline)
        unique_articles << article 
      end
    end
    unique_articles
  end
  
  def filter_unique_articles!()
    @articles = filter_unique_articles
  end
  
end
