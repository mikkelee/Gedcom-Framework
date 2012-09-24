#!/usr/bin/env python

"""
Just a quick script to help create the ansel2utf16 map in EncodingHelpers.h
"""

f = open('Gedcom/ans2uni.out')

charmap = dict()

for line in iter(f):
	if line[0] == '#':
		continue
	(map, comment) = line.strip().split('#')
	(anselcode, utf16code) = map.split('=')
	charmap[int(anselcode, 16)] = { "utf16": utf16code, "comment": comment }
	#print anselcode, utf16code, comment

#print charmap

print 'static const unichar ansel2utf16[] = {'
for i in range(0,256):
	if charmap.has_key(i):
		print '\n\t0x%s, // %s' % (charmap[i]['utf16'], charmap[i]['comment'])
	else:
		print ('\t%d, ' % i),
print '\n};'