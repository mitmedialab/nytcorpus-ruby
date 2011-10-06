require 'config/environment'
require 'app/models/article_set'
require 'pp'

base_dir = ARGV[0]
output_dir = ARGV[1]

# Write a big CSV table indicating how many articles from each month were
# classified as US or World (separate CSVs).  Do the same for the word count
# in those articles.

# write a Hash of counts out to a csv file
def write_csv(attr_values, counts, filename)
  puts "  Writing to #{filename}"
  $stdout.flush
  CSV.open(filename, "wb") do |csv|
    csv << ["month"].concat(attr_values)
    counts.keys.sort.each do |year|
      counts[year].keys.sort.each do |month|
        ordered_attrs = []
        attr_values.each do |attr|
          attr_val = 0
          attr_val = counts[year][month][attr] if counts[year][month].has_key?(attr)
          ordered_attrs << attr_val
        end
        csv << [year.to_s+"_"+month.to_s].concat(ordered_attrs)
      end
    end
  end
end

puts
puts "Aggregating US, World, Front Page"
puts "  from #{base_dir} to #{output_dir}"

article_counts, word_counts = 
  ArticleSet.aggregate_over_timespan( base_dir, (1987..1987), (1..2)) { |article|
    {
      :us => article.classified_as_united_states?,
      :world => article.classified_as_world?,
      :font_page => article.front_page?
    }
  }

write_csv([:us,:world, :front_page], article_counts,
          File.join(output_dir,"news_us_v_world_article_count_by_month.csv"))

write_csv([:us,:world, :front_page], word_counts,
          File.join(output_dir,"news_us_v_world_world_count_by_month.csv"))


