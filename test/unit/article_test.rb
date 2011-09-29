require 'config/environment'
require 'test/test_helper'

require 'app/models/article'

class TestArticle < Test::Unit::TestCase

  def setup
  end

  def teardown
  end
 
  def load_article(filename)
    Article.new(File.join(ROOT, "test", "fixtures", filename))
  end

  def test_load_article
    article = load_article "bush_iraq_funding.xml"
    assert !article.nil?
    assert_equal 1, article.bylines.size
    assert_equal "By DAVID E. SANGER; Thom Shanker contributed reporting from Washington, and Marc Santora from Baghdad.", article.bylines[0]
    assert_equal 1, article.locations.size
    assert_equal "Iraq", article.locations[0]
    #the following test is probably brittle, since XML parsers can't guarantee order
    assert_equal ["Top",
                  "Top/News",
                  "Top/News/World",
                  "Top/News/World/Countries and Territories",
                  "Top/News/World/Countries and Territories/Iraq", 
                  "Top/News/Washington",
                  "Top/News/Washington/Campaign 2004",
                  "Top/News/Washington/Campaign 2004/Candidates", 
                  "Top/News/World/Middle East", 
                  "Top/Features",
                  "Top/Features/Travel",
                  "Top/Features/Travel/Guides",
                  "Top/Features/Travel/Guides/Destinations",
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
    assert_equal "Bush Plan for Iraq Requests More Troops and More Jobs", article.headline

    article = load_article "article_no_fields.xml"
    assert_equal 0, article.bylines.size
    assert_equal 0, article.locations.size
    assert_equal 0, article.descriptors.size
    assert_nil article.publication_date
    assert_nil article.news_desk
    assert_nil article.dateline
    assert_nil article.page
    assert_nil article.section
    assert_nil article.column
  end
end
