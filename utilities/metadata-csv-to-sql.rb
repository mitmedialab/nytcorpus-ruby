require 'app/models/article'
require 'app/models/article_set'

input_file = ARGV[0]
table_name = ARGV[1]
output_file = ARGV[2]

# Write a big SQL insert file based on a metadata csv.
# For instance, I did the following to generate some topic specific files
#   grep -hi "iraq" analysis/rev2/metadata-csv/data_* > analysis/rev2/iraq-articles.csv
#   grep -hi "wall st" analysis/rev2/metadata-csv/data_* > analysis/rev2/wallstreet-articles.csv
#   grep -hi "afghanistan" analysis/rev2/metadata-csv/data_* > analysis/rev2/afghanistan-articles.csv
#   grep -hi "protest" analysis/rev2/metadata-csv/data_* > analysis/rev2/protest-articles.csv
#   grep -hi "china" analysis/rev2/metadata-csv/data_* > analysis/rev2/china-articles.csv
#   grep -hi "baseball" analysis/rev2/metadata-csv/data_* > analysis/rev2/baseball-articles.csv

set = ArticleSet.from_csv_file(input_file)
set.to_sql_insert_file(output_file, table_name)
