from json.decoder import JSONDecodeError
import os, json, tempfile, shutil

class Cache:

    def __init__(self, cache_location):
        self.file = cache_location
        with open(cache_location, 'a+') as cache_file:
            cache_file.seek(0) # a+ mode has cursor at end
            try:
                self.cache = json.load(cache_file)
            except JSONDecodeError:
                self.cache = {}
        
    def unique(self, value):
        '''Returns 0 (False) if value isn't in cache object, stores value.
        Otherwise Returns value of key in cache 1 (True).
        '''
        if value in self.cache:
            return self.cache[value]
        else:
            self.cache[value] = 1
            return 0

    def save(self):
        '''Saves the current cache object to a tmp file, and then copies it
        over to the original cache file.
        '''
        with tempfile.NamedTemporaryFile(mode="w+") as tmpfile:
            json.dump(self.cache, tmpfile)
            shutil.copyfile(tmpfile.name, self.file)
            
