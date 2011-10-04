require 'config/environment'
require 'test/test_helper'

require 'app/models/attribute_value_set'

class TestAttributeValueSet< Test::Unit::TestCase

  def setup
    @base_dir = "test/fixtures"
    @attribute = "tc"
  end

  def teardown
  end
 
  def test_filename
    csv_name = AttributeValueSet.csv_filename(1987,1,@attribute)
    assert_equal csv_name, "data_1987_01.csv_tc.csv"
  end
 
  def test_load_csv
    (1987..1987).each do |year|
     (1..2).each do |month|
       csv_name = AttributeValueSet.csv_filename(year,month,@attribute)
       csv_path = File.join(@base_dir,csv_name)
       set = AttributeValueSet.from_csv_file(csv_path)
       assert_not_nil set
     end
    end
  end
  
  def test_length
    csv_name = AttributeValueSet.csv_filename(1987,1,@attribute)
    csv_path = File.join(@base_dir,csv_name)
    dataset = AttributeValueSet.from_csv_file(csv_path)
    assert_equal dataset.value_count, 5
    csv_name = AttributeValueSet.csv_filename(1987,2,@attribute)
    csv_path = File.join(@base_dir,csv_name)
    dataset = AttributeValueSet.from_csv_file(csv_path)
    assert_equal dataset.value_count, 2
  end

  def test_filter
    csv_name = AttributeValueSet.csv_filename(1987,2,@attribute)
    csv_path = File.join(@base_dir,csv_name)
    dataset = AttributeValueSet.from_csv_file(csv_path)
    assert_equal dataset.value_count, 2
    prefix = "Top/Item2.*"
    new_dataset = dataset.filter(prefix)
    assert_equal new_dataset.value_count, 1
  end

end
