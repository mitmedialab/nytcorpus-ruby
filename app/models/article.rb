require 'config/environment'
require 'hpricot'
require 'ftools'

class Article
  attr_accessor :publication_date, :bylines, :dateline, 
                :descriptors, :taxonomic_classifiers, :locations,
                :page, :section, :column, :news_desk, :word_count,
                :headline, :filename

  def initialize(filename)
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
  
  def self.metadata_keys()
  	[:@publication_date, :@bylines, :@dateline, 
                :@descriptors, :@taxonomic_classifiers, :@locations,
                :@page, :@section, :@column, :@news_desk, :@word_count,
                :@headline, :@filename]
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
  
end
