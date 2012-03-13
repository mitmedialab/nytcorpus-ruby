require 'csv'

def write_names_csv filename, hash
  CSV.open(filename, "wb") do |csv|
    hash.each do |name, value|
      csv << [name, value]
    end
  end
end

def year_modifier year
  year = year.to_i
  if year >= 1960 and year <= 1980
    return 1
  elsif year > 1980
    top = 1960 / 10
    bottom = year / 10
    return 1.0 - (top - bottom).to_f/10.0
  elsif year < 1960
    top = year / 10
    bottom = 1980 / 10
    return 1.0 - (top - bottom).to_f/10.0
  end
end

male = {}
female ={}

CSV.foreach("babynames.csv") do |row|
  year = row[1].to_i
  count = row[4].to_i
  name = row[3]
  modified_count = count * year_modifier(year)
  if(row[0]=="M")
    if !male.has_key? name
      male[name] = modified_count
    else
      male[name] = male[name] + modified_count
    end
  elsif(row[0]=="F")
    if !female.has_key? name
     female[name] = modified_count
    else
      female[name] = female[name] + modified_count
    end
  end
end

write_names_csv "female_names.csv", female
write_names_csv "male_names.csv", male
