require 'config/environment'
require 'app/models/article'
require 'ftools'
require 'pp'
require 'csv'

# This script walks the entire data directory, created a summary csv file
# for each month.
# WARNING: this takes a LOOOOOOOOONG time

REALLY_PARSE = true   # for debugging
DATA_DIR = "data/"

csv_dest_dir = ARGV[0]  # something like "analysis/"

# first get all the subdirectory paths
dirs_to_process = []
Dir.glob(File.join(DATA_DIR,"**")).each do |year_dir|
  Dir.glob(File.join(year_dir,"*")).each do |month_dir|
    dirs_to_process << month_dir if File.directory?(month_dir)
  end
end

puts "Found #{dirs_to_process.length} folders to process under #{DATA_DIR}:"
puts


# now process each directory

total_articles = 0
dirs_processed = 1

dirs_to_process.each do |dir|

  csv_file_name = File.join(csv_dest_dir,dir.gsub("/","_")+".csv")
  if REALLY_PARSE
    csv_file = CSV.open(csv_file_name, "wb")
    csv_file << Article.metadata_keys
  end

  counter = 0
  puts "Parsing from #{dir} to #{csv_file_name} (#{dirs_processed} of #{dirs_to_process.length})"
  print "  0000: "

  Dir.glob(File.join(dir, "**", "*.xml")).each do |filename|
    if filename != "." and filename != ".."
      if REALLY_PARSE 
        article = Article.new(filename)
        if article 
          total_articles += 1
          csv_file << article.metadata_as_array
        end
      end
      counter += 1
      print "." if counter % 20 == 0
      $stdout.flush
      print "\n  #{counter}: " if counter % 1000 == 0
    end
  end
  puts
  puts "  done (parsed #{counter} files)"
  puts
end

puts
puts "Done! Parsed Articles: #{total_articles}"
puts
