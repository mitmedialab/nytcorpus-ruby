require 'config/environment'
require 'csv'

class ValueFrequencyCsv
  
  def self.canoncial_filename(year,month,attribute)
    month = "0"+month.to_s if month < 10
    return "data_"+year.to_s+"_"+month.to_s+".csv_"+attribute+".csv"
  end

  def initialize(filename)
    @data = Hash.new
    
    # load into memory
    all_rows = CSV.read(filename)
    row_index = 0
    all_rows.each do |row|
      if row_index > 0  # first row has titles
	attr = row[0].to_s
	@data[attr] = {:articles=>0, :words=>0}
	@data[attr][:articles] = row[1].to_i rescue false
	@data[attr][:words] = row[2].to_i rescue false
      end
      row_index += 1
    end
  end
  
  def attribute_count
    return @data.length
  end
    
  def get_matching(regex)
    @data.delete_if do |attribute, info|
      attribute.match(/^#{regex}$/) ? false : true
    end
  end
  
end
