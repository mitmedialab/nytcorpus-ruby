$LOAD_PATH << "/Users/civicmac/Development/civic/nytcorpus-ruby"
require 'config/environment'
require 'app/models/article'
require 'fileutils'
require 'pp'
require 'csv'

input_dir = ARGV[0]     # the one with all the metadata csvs
output_dir = ARGV[1]

def numeric?(object)
  true if Float(object) rescue false
end

# Find all the files to process
metadata_csvs = Dir.glob(File.join(input_dir,"*.csv"))

print "Found #{metadata_csvs.length} metadata CSV files to process:\n\n"
$stdout.flush

files_done = 1
dupes = 1


# walk metadata CSV files, generating freq CSV files for each one
metadata_csvs.each do |metadata_csv|
  
  # Load the entire CSV into memory for faster processing
  print "Loading #{metadata_csv} into memory (#{files_done} of #{metadata_csvs.length})... "
  $stdout.flush

  output_rows = []
  dupe_rows = []
  rows = CSV.read(metadata_csv)
  rows.sort_by!{|row| row[0].nil? ? "a": row[11].nil? ? "a" : row[0] + row[11]}
  previous_row = nil
  rows.each do |row|
    if previous_row and
       previous_row[0] == row[0] and
       previous_row[1] == row[1] and
       previous_row[11] == row[11]
      print "x"
      dupe_rows << (previous_row << row)
      dupes += 1
    else
      print "."
      output_rows << row
    end
    previous_row = row
  end
  output_csv_prefix = File.join(output_dir, metadata_csv.split("/")[-1].gsub(".csv",""))
  output_csv_filename = output_csv_prefix + "_deduped.csv"
  dupe_audit_csv_filename = output_csv_prefix + "_dupe_audit.csv"

  CSV.open(output_csv_filename, "wb") do |csv|
    output_rows.each do |row|
      csv << row
    end
  end

  CSV.open(dupe_audit_csv_filename, "wb") do |csv|
    dupe_rows.each do |row|
      csv << row
    end
  end
  puts "\n"
  files_done += 1

  
end
