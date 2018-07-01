from lxml import html
from utils import HtmlUtils
from httpclient import HttpClient
from disp_filter import get_dispensary_filter
from potGuide_helpers import PotGuideDispInfoExtractor
from runner import run
import json
import sys

class PotGuideDispensaryScraper(object):
    def __init__(self, http_client, potguide_store_info_extractor, dispensary_filter):
        self._http_client = http_client
        self._disp_store_extractor = potguide_store_info_extractor
        self._dispensary_filter = dispensary_filter
        self._state_url = 'https://potguide.com/{0}/marijuana-stores/'

    def produce(self, state_name):
        resp, host = self._get_state_response(state_name)
        if resp.success:
            city_urls = self._get_city_urls(resp.content, host)
            for city_url in city_urls:
                res = self._http_client.get(city_url)
                if res.success:
                    html_doc = html.fromstring(res.content)
                    store_urls = HtmlUtils.get_elements(html_doc, '//div[contains(@class,"-listing")]//*[self::h3 or self::h4]/a/@href')
                    for url in store_urls:
                        yield host + url, host
            
    def _get_state_response(self, state_name):
        state_url_templates = [('https://potguide.com','/{0}/marijuana-stores/'), ('https://www.{0}potguide.com','/where-to-buy-marijuana/')]
        resp = {}
        host = ''
        for state_url_parts in state_url_templates:
            resp = self._http_client.get(state_url_parts[0].format(state_name.lower()) + state_url_parts[1].format(state_name.lower()))
            if resp.success: 
                host = state_url_parts[0].format(state_name.lower())
                break
        return resp, host
        
    
    def _get_city_urls(self, page_html, host):
        html_doc = html.fromstring(page_html);
        city_nodes = HtmlUtils.get_elements(html_doc, '(//div[@id="maincolumn"]//ul[@class="dropdown-menu"])[1]/li/a')
        result = []
        for node in city_nodes:
            city_name = HtmlUtils.get_element_value(node, './text()')
            if self._dispensary_filter.match_city(city_name):
                result.append(host + HtmlUtils.get_element_value(node, './@href'))
        return result
    
    def consume(self, store_url_and_host):
        res = self._http_client.get(store_url_and_host[0])
        if res.success:
            return self._disp_store_extractor.get_store_info((res.content, store_url_and_host[1]))

def scrape(arr):
    dispFilter = get_dispensary_filter(arr)
    potguide_scraper = PotGuideDispensaryScraper(HttpClient(), PotGuideDispInfoExtractor(), dispFilter)
    result = run(dispFilter.get_state_names(), potguide_scraper.produce, potguide_scraper.consume)
    return json.dumps(result)

if __name__ == "__main__":
    print (scrape(sys.argv[1:]))