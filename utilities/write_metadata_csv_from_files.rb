require 'config/environment'
require 'app/models/article'
require 'ftools'
require 'pp'
require 'csv'

dirname = ARGV[0]
csvname = ARGV[1]

csv_file = CSV.open(csvname, "wb")
csv_file << Article.metadata_keys

total_articles = 0
counter = 0
print "0000: "

Dir.glob(File.join(dirname, "**", "*.xml")).each do |filename|
  if filename != "." and filename != ".."
    article = Article.new(filename)
    total_articles += 1 if article
    
    csv_file << article.metadata_as_array
    
    counter += 1

    print "." if counter % 20 == 0
    $stdout.flush
    print "\n#{counter}: " if counter % 1000 == 0
  end
end

puts
puts "Total Files: #{counter}"
puts "Parsed Articles: #{total_articles}"
puts

