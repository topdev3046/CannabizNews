from disp_filter import get_dispensary_filter
from jsonutils import loadJson, try_get_list
from weedmaps_helpers import WeedMapsDespensaryExtractor
from runner import run
from httpclient import HttpClient
import json
import sys

class WeedMapsDispensaryScraper(object):
    def __init__(self, dispesary_filter, http_client, weedmaps_disp_extractor):
        self._dispensary_filter = dispesary_filter
        self._http_client = http_client
        self._weedmaps_disp_extractor = weedmaps_disp_extractor

        self._url = "https://api-g.weedmaps.com/wm/v2/listings?filter%5Bplural_types%5D%5B%5D=dispensaries&filter%5Bregion_slug%5Bdispensaries%5D%5D={0}&page_size={1}&page={2}"

    def produce(self, state):
        current_index = 1
        page_size = 150
        should_continue = True
        while should_continue:
            url = self._url.format(state.replace(' ', '-'), page_size, current_index)
            response = self._http_client.get(url)
            should_continue = response.success
            if response.success:
                json_data = loadJson(response.content)
                listings = try_get_list(json_data, "data", "listings")
                total_listings = try_get_list(json_data, "meta", "total_listings")
                should_continue = (page_size * current_index) <  total_listings[0] if len(total_listings) > 0 else 0
                if len(listings) == 0:
                    break
                for l in listings[0]:
                    url_list = try_get_list(l, "slug")
                    city_list = try_get_list(l, "city")
                    if len(url_list) > 0 and len(city_list) > 0 and self._dispensary_filter.match_city(city_list[0]):
                        yield url_list[0]
                current_index = current_index + 1

    def consume(self, item_from_poroduce):
        result = {}
        
        url_details = "https://api-g.weedmaps.com/wm/v2/listings/dispensaries/" + item_from_poroduce
        response = self._http_client.get(url_details)
        if response.success:
            json_data = loadJson(response.content)        
            result =  self._weedmaps_disp_extractor.get_details(json_data)
            
        result['menu'] =  self._weedmaps_disp_extractor.get_menu(self._get_menu_source(item_from_poroduce))
        
        return result
    
    def _get_menu_source(self, url_slug):
        current_index = 1
        page_size = 150
        result = {}
        should_continue = True
        total_items = 0
        while should_continue:
            url_menu = "https://api-g.weedmaps.com/wm/v2/listings/dispensaries/{0}/menu_items?page={1}&page_size={2}".format(url_slug, current_index, page_size)
            response = self._http_client.get(url_menu)
            should_continue = response.success
            if response.success:
                if current_index == 1:
                    result = loadJson(response.content)
                    total_items = result['meta']['total_menu_items']
                else:
                    data = try_get_list(loadJson(response.content), 'data', 'menu_items')
                    result['data']['menu_items'].extend(data[0] if len(data) > 0 else [])
            should_continue = total_items > page_size*current_index
            current_index = current_index + 1
        
        return result
        
        
def scrape(arr):
    dispFilter = get_dispensary_filter(arr)
    wmScraper = WeedMapsDispensaryScraper(dispFilter, HttpClient(), WeedMapsDespensaryExtractor())
    result = run(dispFilter.get_state_names(), wmScraper.produce, wmScraper.consume)

    return json.dumps(result)

if __name__ == "__main__":
     #scrape(sys.argv[1:])
     print (scrape(sys.argv[1:]))