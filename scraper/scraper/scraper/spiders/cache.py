from json.decoder import JSONDecodeError
import os, json, hashlib

class Cache:

    def __init__(self, cache_location):
        self.file = cache_location
        with open(cache_location, 'a+', encoding='utf-8') as cache_file:
            cache_file.seek(0) # a+ mode has cursor at end
            try:
                self.cache = json.load(cache_file)
            except JSONDecodeError:
                self.cache = {}
        
    def unique(self, value):
        '''Returns 0 (False) if value isn't in cache object, stores value.
        Otherwise Returns value of key in cache 1 (True).
        '''
        hashed = hashlib.md5(value.encode('utf-8')).hexdigest()
        if hashed in self.cache:
            return self.cache[hashed]
        else:
            self.cache[hashed] = 1
            return 0

    def save(self):
        '''Saves the current cache object to a tmp file, and then copies it
        over to the original cache file.
        '''
        with open(self.file, 'w', encoding='utf-8') as cache_file:
            try:
                json.dump(self.cache, cache_file)
                return True
            except Exception as e:
                print("Error saving cache file:")
                print(e)
                return False
                
            
