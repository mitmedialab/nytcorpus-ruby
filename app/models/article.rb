require 'config/environment'
require 'hpricot'
require 'ftools'

class Article
  attr_accessor :publication_date, :bylines, :dateline, 
                :descriptors, :taxonomic_classifiers, :locations,
                :page, :section, :column, :news_desk, :word_count,
                :headline, :filename

  def self.from_xml_file(filename)
    a = Article.new
    a.load_from_xml_file(filename)
    return a
  end

  def self.from_metadata_csv_row(row)
    a = Article.new
    a.publication_date = row[0].to_s
    a.bylines = row[1].to_s
    a.dateline = row[2].to_s
    a.descriptors = row[3].to_s
    a.taxonomic_classifiers = row[4].to_s.split("|")
    a.locations = row[5].to_s
    a.page = row[6].to_s
    a.section = row[7].to_s
    a.column = row[8].to_s
    a.news_desk = row[9].to_s
    a.word_count = row[10].to_s
    a.headline = row[11].to_s
    a.filename = row[12].to_s
    return a
  end

  def self.metadata_keys()
  	[:@publication_date, :@bylines, :@dateline, 
                :@descriptors, :@taxonomic_classifiers, :@locations,
                :@page, :@section, :@column, :@news_desk, :@word_count,
                :@headline, :@filename]
  end
  
  def has_attribute_value?(attr_name, regex)
    count_attribute_values(attr_name, regex) > 0
  end
  
  def as_mysql_insert(table_name)
  	"INSERT INTO `#{table_name}` "+
  		"(`publication_date`, `byline`, `dateline`, `descriptors`, `taxonomic_classifiers`, "+
  		"`locations`, `page`, `section`, `news_column`, `news_desk`, `word_count`, `headline`, `filename`) " +
  		"VALUES ("+@publication_date+", \""+@bylines+"\", \""+@dateline+"\", \""+@descriptors+"\", \""+
  		@taxonomic_classifiers.join("|")+"\", \""+@locations+"\", \""+@page+"\", \""+@section+"\", \""+
  		@column+"\", \""+@news_desk+"\", "+@word_count+", \""+@headline+"\", \""+@filename+"\"); "
  end
  
  def count_attribute_values(attr_name, regex)
    matches = 0
    attr_value = self.instance_variable_get(attr_name)
    if attr_value.instance_of?(Array)
      attr_value.each do |attr_item_value|
        matches += 1 if attr_item_value.match(/^#{regex}$/)
      end
    else
      matches += 1 if attr_value.to_s.match(/^#{regex}$/)
    end
    matches
  end
  
  def metadata_as_array()
    metadata = Array.new
    Article.metadata_keys.each do |attr_name|
      attr_value = self.instance_variable_get(attr_name)
      if attr_value.instance_of?(Array)
      	attr_value = attr_value.join("|")
      end
      metadata.push(attr_value)
    end
    return metadata
  end
  
  # Special logic to handle the "Top/News/World/Countries and Territories/United States" tag
  def classified_as_world?
    tc_attribute = :@taxonomic_classifiers
    is_world = has_attribute_value?(tc_attribute , "Top/News/World")
    is_world_us = has_attribute_value?(tc_attribute, "Top/News/World/Countries and Territories/United States")
    world_countries_count = count_attribute_values(tc_attribute, "Top/News/World/Countries and Territories/.*")
    return false if not is_world
    (!is_world_us) || (is_world_us && world_countries_count>1)
  end
  
  def classified_as_united_states?
    tc_attribute = :@taxonomic_classifiers
    has_attribute_value?(tc_attribute , "Top/News/U\.S\.")
  end
  
  def front_page?
    (@section=="A") && (@page.to_i==1)
  end
  
  def load_from_xml_file(filename)
    
    @bylines = []
    @locations = []
    @descriptors = []
    @taxonomic_classifiers = []

    @filename = filename

    file = File.open(@filename) 
    if file
      @doc = Hpricot::XML(file.read)

      (@doc/'byline').each do |byline|
        @bylines << byline.inner_html
      end

      (@doc/'location').each do |location|
        @locations << location.inner_html
      end

      (@doc/"classifier[@type='taxonomic_classifier']").each do |classifer|
        terms = classifer.inner_html.split("/")
        terms.length.times do |i|
          @taxonomic_classifiers << terms[0..i].join("/")
        end
        
      end
    
      @taxonomic_classifiers.uniq!
    
      (@doc/"classifier[@type='descriptor']").each do |descriptor|
        @descriptors << descriptor.inner_html
      end
   
      pubdata = (@doc/"pubdata")
      @publication_date = pubdata[0].attributes["date.publication"][0..7] if pubdata.size > 0
      @word_count = pubdata[0].attributes["item-length"] if pubdata.size > 0

      news_desk = (@doc/"meta[@name='dsk']")
      @news_desk = news_desk[0].attributes["content"] if news_desk.size > 0

      dateline = (@doc/"dateline")
      @dateline = dateline[0].inner_html if dateline.size > 0

      page = (@doc/"meta[@name='print_page_number']")
      @page = page[0].attributes["content"] if page.size > 0 

      section = (@doc/"meta[@name='print_section']")
      @section = section[0].attributes["content"] if section.size > 0 

      column = (@doc/"meta[@name='print_column']")
      @column = column[0].attributes["content"] if column.size > 0
      
      headline = (@doc/"hedline"/"hl1")
      @headline = headline[0].inner_html if headline.size > 0
      
    end
  end
  
end
