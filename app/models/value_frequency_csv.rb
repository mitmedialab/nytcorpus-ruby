require 'config/environment'
require 'csv'

class ValueFrequencyCsv
  attr_accessor :publication_date, :bylines, :dateline, 
                :descriptors, :taxonomic_classifiers, :locations,
                :page, :section, :column, :news_desk, :word_count

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
	@data[row[0]] = {:article=>row[1], :words=>row[2]}
      end
      row_index += 1
    end
  end
  
  def attribute_count
    return @data.length
  end
    
end
