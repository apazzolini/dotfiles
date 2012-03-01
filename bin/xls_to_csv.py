#! /usr/bin/env python

import xlrd
import csv

book = xlrd.open_workbook('partseed.xls')

# Assuming the fist sheet is of interest 
sheet = book.sheet_by_index(0)

# Many options here to control how quotes are handled, etc.
csvWriter = csv.writer(open('partseed.csv', 'w'), delimiter='|') 

for i in range(sheet.nrows):
      csvWriter.writerow(sheet.row_values(i))
