require 'config/environment'
require 'app/models/value_frequency_csv'
require 'pp'

base_dir = ARGV[0]
output_dir = ARGV[1]

attribute = "tc"
prefix = "Top/News/[^/]*"

print "Aggregating #{attribute} from #{base_dir} \n"

article_counts = Hash.new
word_counts = Hash.new
attr_values = []

# collect values we care about from all theyear files
(1987..2007).each do |year|
  article_counts[year] = Hash.new
  word_counts[year] = Hash.new
  (1..12).each do |month|
    csv_name = ValueFrequencyCsv.canoncial_filename(year,month,attribute)
    csv_path = File.join(base_dir,csv_name)
    if File.exists?(csv_path)
      article_counts[year][month] = Hash.new
      word_counts[year][month] = Hash.new
      print "  Loading #{csv_path}... "
      $stdout.flush
      csv = ValueFrequencyCsv.new(csv_path)
      print "done #{csv.attribute_count} attributes\n"
      csv.get_matching(prefix).each_pair do |attr, info|
        attr_values << attr if not attr_values.include?(attr)
        article_counts[year][month][attr] = info[:articles]
        word_counts[year][month][attr] = info[:words]
      end
    end
  end
end

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

# alphabetical
attr_values.sort!

# write out the csv of counts for each month
write_csv(attr_values, article_counts, File.join(output_dir,"counts_"+attribute+"_articles.csv"))
write_csv(attr_values, word_counts, File.join(output_dir,"counts_"+attribute+"_words.csv"))

