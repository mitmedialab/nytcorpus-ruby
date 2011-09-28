
A Ruby Parser for the NYT Corpus
================================

Structure
---------

By convention we suggest putting the corpus in a folder called `data`
within this folder (creating directories like `data/2007/05/20/` with
lots of xml files in them).

Running Scripts
---------------

To run a utility which aggregates data from files, the command is:
`ruby utilities/aggregate_data_from_files.rb <DATADIR>`

However, working with the raw data files is time-consuming, so we have a 
script that generates a metadata CSV.  This CSV contains a row for 
each article, with a column for each piece of metadata we care 
about.  To generate a CSV for a set of files:
`ruby utilties/write_metadata_csv_from_files.rb <DATADIR> <OUTPUT_CSV>`

Once you have a metadata CSV, you run a script to create a whole 
bunch of CSVs that describe the frequency of values in each piece 
of metadata:
`ruby utilities/write_freq_csv_from_metadata_csv.rb <METADATA_CSV> <OUTPUT_CSV_PREFIX>`

Batch Processing
----------------

Of course, you may also want to do the above for the entire corpus
(if you have a lot of time on your hands).  For this we have included 
some scripts in the `utilities/batch` directory.

To generate metadata CSV files for the each month in the corpus, run:
`ruby utilities/batch/write_all_metadata_csvs.rb <OUTPUT_DIR>`
This will read the corpus from the `data` directory and create ouput 
metadata CSV files like `data_2007_06.csv`.  This will take a *long*
time.

After that, to generate value frequency CSVs for each piece of metadata we care 
about, run this script:
`ruby utilities/batch/write_all_freq_csvs.rb <INPUT_DIR> <OUTPUT_DIR>`
Use the directory continaing all your metadata CSV files from the previous 
script as your input to this one. The new value frequency CSVs will be written
to the output directory.

Tests
-----

To run a test, the command is:
  ruby -Itest test/unit/article_test.rb


Dependencies
------------

Gems:
- hpricot
