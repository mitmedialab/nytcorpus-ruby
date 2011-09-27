require 'config/environment'
require 'app/models/article'
require 'ftools'
require 'pp'
require 'csv'

# which columns to aggregate for value counts
Cols_To_Write = {
  :tc => 4,
}

csvname = ARGV[0]
output_csv_prefix = ARGV[1]

def numeric?(object)
  true if Float(object) rescue false
end

# return a Hash from attribute value to {article_count, word_count}
def get_counts(all_rows,column_name,column_index,front_page_only)
  print "Aggregating column #{column_name}..."
  $stdout.flush

  counts = Hash.new
  row_index = 0

  all_rows.each do |row|
    if row_index > 0  # first row has titles
      is_front_page = (row[7]=="A") && (row[6].to_i==1)
      
      if (not front_page_only) || (is_front_page && front_page_only)
        
        word_count = 0
        if numeric?(row[10].to_s)
          word_count = row[10].to_i
        end
        
        raw_value = row[column_index]
        if not raw_value.nil?
          raw_value.split("|").each do |value|
            if not counts.has_key?(value)
              counts[value] = {:stories=>0, :words=>0}
            end
            counts[value][:stories] += 1
            counts[value][:words] += word_count
          end
        end
        
      end
      
    end
    row_index += 1
  end
  
  print " done\n"
  return counts
end

# write a Hash of counts out to a csv file
def write_csv(counts,filename)
  print "  Writing to #{filename}..."
  $stdout.flush
  CSV.open(filename, "wb") do |csv|
    csv << ["value","stories","word"]
    counts.each_pair do |key,value|
      csv << [key,value[:stories],value[:words]]
    end
  end
  print " done\n\n"
end

# Load the entire CSV into memory for faster processing
print "Loading csv into memory... "
$stdout.flush
all_rows = CSV.read(csvname)
print "done (#{all_rows.length} rows)\n\n"

# write some summary csv files for each piece of metadata we care about
Cols_To_Write.each_pair do |column_name,column_index|

  output_csv_filename = output_csv_prefix + "_" + column_name.to_s
  
  counts = get_counts(all_rows, column_name, column_index, false)
  write_csv(counts, output_csv_filename + ".csv")
  
  counts = get_counts(all_rows, column_name, column_index, true)
  write_csv(counts, output_csv_filename + "_front_page.csv")
  
end
