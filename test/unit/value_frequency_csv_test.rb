require 'config/environment'
require 'test/test_helper'

require 'app/models/value_frequency_csv'

class TestValueFrequencyCsv < Test::Unit::TestCase

  def setup
    @base_dir = "test/fixtures"
    @attribute = "tc"
  end

  def teardown
  end
 
  def test_filename
    csv_name = ValueFrequencyCsv.canoncial_filename(1987,1,@attribute)
    assert_equal csv_name, "data_1987_01.csv_tc.csv"
  end
 
  def test_load_csv
    (1987..1987).each do |year|
     (1..2).each do |month|
       csv_name = ValueFrequencyCsv.canoncial_filename(year,month,@attribute)
       csv_path = File.join(@base_dir,csv_name)
       csv = ValueFrequencyCsv.new(csv_path)
     end
    end
  end
  
  def test_attribute_count
    csv_name = ValueFrequencyCsv.canoncial_filename(1987,1,@attribute)
    csv_path = File.join(@base_dir,csv_name)
    csv = ValueFrequencyCsv.new(csv_path)
    assert_equal csv.attribute_count, 5
    csv_name = ValueFrequencyCsv.canoncial_filename(1987,2,@attribute)
    csv_path = File.join(@base_dir,csv_name)
    csv = ValueFrequencyCsv.new(csv_path)
    assert_equal csv.attribute_count, 2
  end

  def test_get_by_prefix
    csv_name = ValueFrequencyCsv.canoncial_filename(1987,2,@attribute)
    csv_path = File.join(@base_dir,csv_name)
    csv = ValueFrequencyCsv.new(csv_path)
    assert_equal csv.attribute_count, 2
    prefix = "Top/Item2.*"
    hash = csv.get_matching(prefix)
    assert_equal hash.length, 1
  end

end
