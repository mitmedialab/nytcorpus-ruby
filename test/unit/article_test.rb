require 'config/environment'
require 'test/test_helper'

require 'app/models/article'

class TestArticle < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  def test_load_article
    article = Article.new(File.join(ROOT, "test", "fixtures", "bush_iraq_funding.xml"))
    assert !article.nil?
    assert_equal 1, article.bylines.size
    assert_equal "By DAVID E. SANGER; Thom Shanker contributed reporting from Washington, and Marc Santora from Baghdad.", article.bylines[0]
    assert_equal 1, article.locations.size
    assert_equal "Iraq", article.locations[0]
    #the following test is probably brittle, since XML parsers can't guarantee order
    assert_equal ["Top/News", "Top/News/World/Countries and Territories/Iraq", 
                  "Top/News/World", "Top/News/Washington/Campaign 2004/Candidates", 
                  "Top/News/World/Middle East", 
                  "Top/Features/Travel/Guides/Destinations/Middle East", 
                  "Top/Features/Travel/Guides/Destinations/Middle East/Iraq"], article.taxonomic_classifiers
    assert_equal 1, article.descriptors.size
    assert_equal "United States Armament and Defense", article.descriptors[0]
    assert_equal "20070107", article.publication_date
    assert_equal "Foreign Desk", article.news_desk
    assert_equal "WASHINGTON, Jan. 6", article.dateline
    assert_equal "1", article.page
    assert_equal "1", article.section
    assert_equal "5", article.column
  end
end
