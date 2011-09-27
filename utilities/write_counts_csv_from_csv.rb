require 'config/environment'
require 'app/models/article'
require 'ftools'
require 'pp'
require 'csv'

Front_Page_Only = true
Col_Index_In_Csv = 4  # this is the col to filter for

csvname = ARGV[0]
output_csv = ARGV[1]
counts = Hash.new

row_index = 0

def numeric?(object)
  true if Float(object) rescue false
end

print "Loading csv into memory... "
$stdout.flush
all_rows = CSV.read(csvname)
print "done (#{all_rows.length} rows)\n"

print "Aggregating Info..."
$stdout.flush

all_rows.each do |row|
  if row_index > 0

    is_front_page = (row[7]=="A") && (row[6].to_i==1)
    
    if (not Front_Page_Only) || (is_front_page && Front_Page_Only)
      
      word_count = 0
      if numeric?(row[10].to_s)
        word_count = row[10].to_i
      end
      
      raw_value = row[Col_Index_In_Csv]
      if not raw_value.nil?
        raw_value.split(",").each do |value|
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

print "done\n"

print "Writing to #{output_csv}..."
$stdout.flush

CSV.open(output_csv, "wb") do |csv|
  csv << ["value","stories","word"]
  counts.each_pair do |key,value|
    csv << [key,value[:stories],value[:words]]
  end
end

print "done\n"
