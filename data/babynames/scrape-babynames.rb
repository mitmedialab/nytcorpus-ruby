#scraper requires the SSN scraped babynames dataset from infochimps
#www.infochimps.com/datasets/popular-baby-names-by-year-top-1000-us-social-security-administr
require 'nokogiri'

for year in (1880..2009)

  f = File.open("babynames/top-1000-#{year}-num.html")
  html = f.read

  doc = Nokogiri::HTML(html)
  for v in doc.search("table[@bordercolor='#aaabbb'] tr[@align='right']")
    cells = v.search('td')
#    data = {
#      'year' => year,
#      'rank' => cells[0].inner_html,
#      'male_name' => cells[1].inner_html,
#      'male_count' => cells[2].inner_html,
#      'female_name' => cells[3].inner_html,
#      'female_count' => cells[4].inner_html
#k    }
      print "M" + ","
      print year.to_s + "," #year
      print cells[0].inner_html + "," #rank
      print cells[1].inner_html + "," #male name
      print cells[2].inner_html.gsub(",","") + "\n" #male count
      print "F" + ","
      print year.to_s + "," #year
      print cells[0].inner_html + "," #rank
      print cells[3].inner_html + "," #female name
      print cells[4].inner_html.gsub(",","") + "\n" #female count
  end
end

