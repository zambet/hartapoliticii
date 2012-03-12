#!/usr/bin/python
# -*- coding: UTF-8 -*-

'''
Created on March 11, 2012


@author: zambet
'''

import codecs
import re
import sys

def get_ministrii(data):
  """Each Ministru appears in a div as below:
     <div class="cab-right">
			<h5><a href="/marko-bela__l1a103794.html" title="Markó Béla" class="ministere">Markó Béla</a></h5>
			<p>Viceprim-Ministru</p>
     </div>
  """
  ministrii = re.findall('<div class="cab-right">\s*<h5><a.*?>(.*?)</a></h5>\s*<p>(.*?)</p>\s*</div>', data)
  return ministrii;

print '== Step 1 in the pipeline, html -> txt'

if len(sys.argv) <= 1:
  print "Usage: python s01_cabinet_parse.py input_file output_file"
  sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

f = open(input_file)
data = f.read()
f.close()


ministrii = get_ministrii(data);

out = codecs.open(output_file, 'w', 'utf-8')

for ministru in ministrii:
  out.write(ministru[1]+"\n")
  out.write(ministru[0]+"\n")

print '-- done.'
out.close()

