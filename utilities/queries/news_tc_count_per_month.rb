require 'config/environment'
require 'app/models/attribute_value_set'
require 'pp'

base_dir = ARGV[0]
output_dir = ARGV[1]

# Write a big CSV table indicating how many articles from each month were
# included a specific taxonomy classifier term.  Do the same for the word
# count in those articles.  Change the regex variable to count something
# different.

attribute = "tc"      # what attribute to 
regex = "Top/News/?[^/]*"

print "Aggregating #{attribute} from #{base_dir} \n"

article_counts, word_counts, attr_values =
  AttributeValueSet.aggregate_over_timespan( base_dir, (1987..2007), (1..12), attribute, regex)

# write a Hash of counts out to a csv file
def write_csv(attr_values, counts, filename)
  print "  Writing to #{filename}..."
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
  print " done\n\n"
end

# write out the csv of counts for each month
write_csv(attr_values, article_counts, File.join(output_dir,"counts_"+attribute+"_articles.csv"))
write_csv(attr_values, word_counts, File.join(output_dir,"counts_"+attribute+"_words.csv"))

