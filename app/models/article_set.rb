require 'config/environment'
require 'csv'
require 'app/models/article'

class ArticleSet

  attr_accessor :articles, :filename, :parse_error_count

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
    @parse_error_count = 0
    set = ArticleSet.new
    set.filename = filename
    # read line by line to handle annoying errors better
    #   http://railsforum.com/viewtopic.php?id=2280
    error_count = 0
    row_index = 0
    input = File.open(filename)
    input.each do |line|
      row = CSV::parse_line(line, ',')
      if row.size == 0
        @parse_error_count += 1
      elsif row[0].nil?
        # skip
      else
        if row_index > 0  # first row has titles
          set.articles << Article.from_metadata_csv_row(row)
        end
        row_index += 1
      end
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
  
  def to_sql_insert_file(filename,table_name)
    sql_file = File.open(filename, 'w')
    @articles.each do |article|
      sql_file.write(article.as_mysql_insert(table_name))
      sql_file.write("\n")
    end
    sql_file.close
  end
  
  def article_count
    return @articles.length
  end

  def get_matching(article_attribute_name, regex)
		accept { |article|
			article.has_attribute_value?(article_attribute_name, regex)
		}
  end
  
  def accept(&filter_block)
		valid_articles = @articles.reject do |article|
      !filter_block.call(article)	# return true to keep it
		end
    return ArticleSet.from_array(valid_articles)
  end

	def accept!(&filter_block)
		@articles = @articles.reject do |article|
      !filter_block.call(article)	# return true to keep it
		end
		self
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
  
  def self.aggregate_over_timespan(base_dir, year_range, month_range, &article_filter_block)
    article_counts = Hash.new
    word_counts = Hash.new
    year_range.each do |year|
      article_counts[year] = Hash.new
      word_counts[year] = Hash.new
      month_range.each do |month|
        csv_name = ArticleSet.csv_filename(year,month)
        csv_path = File.join(base_dir,csv_name)
        if File.exists?(csv_path)
            article_counts[year][month] = Hash.new
            word_counts[year][month] = Hash.new
            puts "  Processing #{csv_path}"
            set = ArticleSet.from_csv_file(csv_path)
            
						month_article_counts = {}
						month_word_counts = {}
						set.articles.each do |article|
							flags = article_filter_block.call(article)	# results a hash of bools
							flags.each_pair do |key, passes|
								month_article_counts[key] = 0 if !month_article_counts.has_key?(key)
								month_article_counts[key] += 1 if passes
								month_word_counts[key] = 0 if !month_word_counts.has_key?(key)
								month_word_counts[key] += article.word_count.to_i if passes
							end
						end
            
            article_counts[year][month] = month_article_counts
            word_counts[year][month] = month_word_counts
        end
      end
    end
    return article_counts, word_counts
  end
  
end
