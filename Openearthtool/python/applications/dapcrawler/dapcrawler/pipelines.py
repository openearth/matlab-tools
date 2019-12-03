# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/topics/item-pipeline.html

#class DapcrawlerPipeline(object):
#    def process_item(self, spider, item):
#        return item

import simplejson

class JsonWriterPipeline(object):

    def __init__(self):
        self.file = open('items.jl', 'wb')

    def process_item(self, item, spider):
        line = simplejson.dumps(dict(item)) + "\n"
        self.file.write(line)
        return item
