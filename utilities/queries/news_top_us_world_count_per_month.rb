require 'config/environment'
require 'app/models/article_set'
require 'pp'

base_dir = ARGV[0]
output_dir = ARGV[1]

# Write a big CSV table indicating how many articles from each month were
# classified as US or World (separate CSVs).  Do the same for the word count
# in those articles.

# write a Hash of counts out to a csv file
def write_csv(counts, filename)
  print "  Writing to #{filename}"
  CSV.open(filename, "wb") do |csv|
    csv << ["month","count"]
    counts.keys.sort.each do |year|
      counts[year].keys.sort.each do |month|
        csv << [year.to_s+"_"+month.to_s, counts[year][month]]
      end
    end
  end
  puts " done"
end

# US
puts
puts "Aggregating US"
puts "  from #{base_dir} to #{output_dir}"
us_article_counts, us_word_counts = 
  ArticleSet.aggregate_over_timespan( base_dir, (1987..2007), (1..12)) { |article|
    article.classified_as_united_states?
  }
write_csv(us_article_counts, File.join(output_dir,"news_top_us_article_count_by_month.csv"))
write_csv(us_word_counts, File.join(output_dir,"news_top_us_word_count_by_month.csv"))

# World
puts
puts "Aggregating world"
puts "  from #{base_dir} to #{output_dir}"
world_article_counts, world_word_counts =
  ArticleSet.aggregate_over_timespan( base_dir, (1987..2007), (1..12)) { |article|
    article.classified_as_world?
  }
write_csv(world_article_counts, File.join(output_dir,"news_top_world_article_count_by_month.csv"))
write_csv(world_word_counts, File.join(output_dir,"news_top_world_word_count_by_month.csv"))


