$LOAD_PATH << "/Users/civicmac/Development/civic/nytcorpus-ruby"
require 'config/environment'
require 'app/models/article'
require 'fileutils'
require 'pp'
require 'csv'
require 'nokogiri'

#This script iterates through the entire dataset of articles
#Creates a stripped fulltext file for each article

INPUT_DIR  = ARGV[0]     # the one with all the metadata csvs
OUTPUT_DIR = ARGV[1]
DATASOURCE_PREFIX = "data/full/"

# Find all the files to process
metadata_csvs = Dir.glob(File.join(INPUT_DIR,"*deduped.csv"))
print "Found #{metadata_csvs.length} metadata CSV files to process:\n\n"
$stdout.flush

files_done = 1

metadata_csvs.each do |metadata_csv|
  print "Loading #{metadata_csv} into memory (#{files_done} of #{metadata_csvs.length})... "
  $stdout.flush
  all_rows = CSV.read(metadata_csv)
  print "done (#{all_rows.length} rows)\n"

  all_rows.each do |article_row|
    next if article_row[0] == "@publication_date"
    article = Article.from_metadata_csv_row(article_row)
    fulltext_output_filename = File.join(OUTPUT_DIR, article.filename.gsub(DATASOURCE_PREFIX, "").gsub("xml", "txt"))

    xml_article = Article.from_xml_file(article.filename)
    
    #make the directory if it doesn't exist
    xml_article_fulltext = (xml_article.doc/"block[@class='full_text']").inner_text
    FileUtils.mkdir_p(File.dirname(fulltext_output_filename))
    File.open(fulltext_output_filename, 'w') {|f| f.write(xml_article_fulltext) }
    print "."
  end
end
