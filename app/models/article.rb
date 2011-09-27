require 'config/environment'
require 'hpricot'
require 'ftools'

class Article
  attr_accessor :publication_date, :bylines, :dateline, 
                :descriptors, :taxonomic_classifiers, :locations,
                :page, :section, :column, :news_desk

  def initialize(filename)
    @bylines = []
    @locations = []
    @descriptors = []
    @taxonomic_classifiers = []

    file = File.open(filename) 
    if file
      @doc = Hpricot::XML(file.read)

      (@doc/'byline').each do |byline|
        @bylines << byline.inner_html
      end

      (@doc/'location').each do |location|
        @locations << location.inner_html
      end

      (@doc/"classifier[@type='taxonomic_classifier']").each do |classifer|
        @taxonomic_classifiers << classifer.inner_html
      end
    
      (@doc/"classifier[@type='descriptor']").each do |descriptor|
        @descriptors << descriptor.inner_html
      end
   
      pubdata = (@doc/"pubdata")
      @publication_date = pubdata[0].attributes["date.publication"][0..7] if pubdata.size > 0

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
    end
  end
end
