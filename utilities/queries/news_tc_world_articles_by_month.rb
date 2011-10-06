require 'config/environment'
require 'app/models/article_set'
require 'pp'

base_dir = ARGV[0]
output_dir = ARGV[1]

# Write a CSV for each month with the metadata of all articles that were about
# World news.

attribute = :@taxonomic_classifiers      # what attribute to 

puts "Generating list of all articles classified as World news"
puts "  from #{base_dir} to #{output_dir}\n"

(1987..2007).each do |year|
  (1..12).each do |month|
    file_path = File.join(base_dir, ArticleSet.csv_filename(year, month))
    if File.exists?(file_path)
      puts "    #{file_path}"
      set = ArticleSet.from_csv_file(file_path)
      set.accept! { |article|
      	article.classified_as_world?
      }
      month = "0"+month.to_s if month < 10
      set.to_csv(File.join(output_dir,"top_news_world_#{year}_#{month}.csv"))
    end
  end
end

