require 'config/environment'
require 'csv'

class AttributeValueSet
 
  attr_accessor :data

  def self.csv_filename(year,month,attribute)
    month = "0"+month.to_s if month < 10
    return "data_"+year.to_s+"_"+month.to_s+".csv_"+attribute+".csv"
  end

  def self.from_data(hash)
      set = AttributeValueSet.new
      set.data = hash
      return set
  end
  
  def self.from_csv_file(filename)
    set = AttributeValueSet.new
    
    set.data = Hash.new
    
    # load into memory
    all_rows = CSV.read(filename)
    row_index = 0
    all_rows.each do |row|
      if row_index > 0  # first row has titles
	attr = row[0].to_s
	set.data[attr] = {:articles=>0, :words=>0}
	set.data[attr][:articles] = row[1].to_i rescue false
	set.data[attr][:words] = row[2].to_i rescue false
      end
      row_index += 1
    end
    
    return set
  end
  
  def value_count
    return @data.length
  end
    
  def filter(regex)
    newset = @data.reject do |attribute, info|
      attribute.match(/^#{regex}$/) ? false : true
    end
    return AttributeValueSet.from_data(newset)
  end
  
  def self.aggregate_over_timespan(base_dir, year_range, month_range, attribute, regex)
    article_counts = Hash.new
    word_counts = Hash.new
    attr_values = []
    # collect values we care about from all the year files
    year_range.each do |year|
      article_counts[year] = Hash.new
      word_counts[year] = Hash.new
      month_range.each do |month|
        csv_name = AttributeValueSet.csv_filename(year,month,attribute)
        csv_path = File.join(base_dir,csv_name)
        if File.exists?(csv_path)
            article_counts[year][month] = Hash.new
            word_counts[year][month] = Hash.new
            print "  Loading #{csv_path}... "
            $stdout.flush
            csv = AttributeValueSet.from_csv_file(csv_path)
            print "done #{csv.value_count} values\n"
            csv.filter(regex).data.each_pair do |attr, info|
              attr_values << attr if not attr_values.include?(attr)
              article_counts[year][month][attr] = info[:articles]
              word_counts[year][month][attr] = info[:words]
            end
        end
      end
    end
    return article_counts, word_counts, attr_values.sort!
  end
    
end
