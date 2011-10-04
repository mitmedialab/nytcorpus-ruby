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
  
end
