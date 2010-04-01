# -*- coding: iso-8859-1 -*-
"""
	MoinMoin Macro (developed for 1.9.2)

    Retrieves tagged files using the NNTagging.framework
	and the Python Wrapper pynntagging.

    @copyright: 2010 nudge:nudge GbR
    @license: GNU GPL, see COPYING for details
"""

from pynntagging.nntagging import NNTagging
import urllib

Dependencies = []

def execute(macro, args):
	nntagging = NNTagging()
	tagNames = args.split(',')
	tags = [nntagging.tagForName(tagName) for tagName in tagNames] 
	files = nntagging.executeQueryForTags(tags)
	paths = [nnfile.path() for nnfile in files]
	
	out = '\n<div class="punakea"><b>Files for "' + ', '.join(tagNames) + '"</b>\n<br/ >\n<ul>\n'
	
	for path in paths:
		name = path.split('/')[-1]
		encodedpath = path.replace(' ','%20')
		link = '<a href="file://' + encodedpath + '">' + name + '</a>'
		out += '<li>' + link + '</li>\n'
		
	out += '</ul>\n'
	
	punakea_link = 'punakea://' + '/'.join(tagNames)
	click_here = '<a href="' + punakea_link + '">Show "' + ', '.join(tagNames) + '" in Punakea</a>'
	
	out += '<br />\n' + click_here
	out += '</div>\n'
	
	return out