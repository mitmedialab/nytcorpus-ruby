require 'config/environment'
require 'app/models/article'
require 'ftools'
require 'pp'

dirname = ARGV[0]

article_data = {:bylines => 0,
                :locations => 0,
                :taxonomic_classifiers => 0, 
                :descriptors => 0,
                :publication_dates => 0,
                :news_desks => 0,
                :datelines => 0,
                :pages => 0,
                :sections => 0,
                :columns => 0}
total_articles = 0
counter = 0
print "0000: "

Dir.glob(File.join(dirname, "**", "*.xml")).each do |filename|
  if filename != "." and filename != ".."
    article = Article.new(filename)
    total_articles += 1 if article
    article_data[:bylines]     += 1 if article.bylines.size > 0
    article_data[:locations]   += 1 if article.locations.size > 0
    article_data[:descriptors] += 1 if article.descriptors.size > 0
    article_data[:news_desks]  += 1 if article.news_desk
    article_data[:datelines]   += 1 if article.dateline
    article_data[:pages]       += 1 if article.page
    article_data[:sections]    += 1 if article.section
    article_data[:columns]     += 1 if article.column
    article_data[:publication_dates] += 1 if article.publication_date
    article_data[:taxonomic_classifiers] += 1 if article.taxonomic_classifiers.size > 0
 
    counter += 1
    print "." if counter % 20 == 0
    $stdout.flush
    print "\n#{counter}: " if counter % 1000 == 0
  end
end

puts
puts "Total Files: #{counter}"
puts "Parsed Articles: #{total_articles}"
puts
article_data.each_pair do |key, value|
  printf "%3d" % (value.to_f/total_articles.to_f*100.to_f).to_i
  print "%  #{value} : #{key} \n"
end

