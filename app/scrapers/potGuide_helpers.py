from lxml import html
from utils import HtmlUtils
import re
import json
from HTMLParser import HTMLParser

class PotGuideDispInfoExtractor(object):
    
    def get_store_info(self, store_html_and_host):
        html_doc = html.fromstring(store_html_and_host[0])
        if self._has_menu(html_doc):
            return self._extract_all_info(store_html_and_host)
        
    def _has_menu(self, html_doc):
        return len(HtmlUtils.get_elements(html_doc, '//div[contains(@id,"cpg-menu")]')) > 0
        
    def _extract_all_info(self, store_html_and_host):
        html_doc = html.fromstring(store_html_and_host[0])
        store_info = {}
        
        map_store = self._get_map_store_obj(store_html_and_host[0])
        store_info['name']  = map_store['name']
        store_info['url']  = store_html_and_host[1] + map_store['url']
        store_info['contact'] = self._get_contact_info((map_store, store_html_and_host[1]))
        store_info['social_media'] = self._get_social_media_info(html_doc)
        store_info['hours'] = self._get_hours(html_doc)
        store_info['menu'] = self._get_menu_info(html_doc)
        
        return store_info
    
    def _get_map_store_obj(self, store_html):
        map_store_string = re.search('mapStore\s*:\s(\{(.|\n)*?\})', store_html).groups(0)[0]
        map_store_json_string = re.sub(r'\s*(.*?)(\s*:\s*)\'(.*)\'', r'"\1"\2"\3"', map_store_string)
        
        try:
            return json.loads(HTMLParser().unescape(map_store_json_string).replace('\\',''))
        except ValueError:
            return {}
        
    def _get_contact_info(self, map_store_and_host):
        contact_info = {}
        contact_info['address'] = map_store_and_host[0]['address']
        contact_info['city'] = map_store_and_host[0]['city']
        contact_info['state'] = map_store_and_host[0]['state']
        contact_info['zip'] = map_store_and_host[0]['zip']
        contact_info['phone'] = map_store_and_host[0]['phone']
        contact_info['website'] = map_store_and_host[0]['website']
        contact_info['lat']  = map_store_and_host[0]['lat']
        contact_info['lon']  = map_store_and_host[0]['lng']
        contact_info['logo']  = map_store_and_host[1] + map_store_and_host[0]['logo']
        
        return contact_info
        
    def _get_social_media_info(self, html_doc):
        social_media_info = {}
        social_media_info['facebook'] = HtmlUtils.get_element_value(html_doc, '//div[@class="brand-page"]//ul[contains(@class,"list-unstyled")]//a/i[contains(@class,"facebook")]/parent::a/@href')
        social_media_info['twitter'] = HtmlUtils.get_element_value(html_doc, '//div[@class="brand-page"]//ul[contains(@class,"list-unstyled")]//a/i[contains(@class,"twitter")]/parent::a/@href')
        social_media_info['instagram'] = HtmlUtils.get_element_value(html_doc, '//div[@class="brand-page"]//ul[contains(@class,"list-unstyled")]//a/i[contains(@class,"instagram")]/parent::a/@href')
        social_media_info['google-plus'] = HtmlUtils.get_element_value(html_doc, '//div[@class="brand-page"]//ul[contains(@class,"list-unstyled")]//a/i[contains(@class,"google-plus")]/parent::a/@href')
        
        return social_media_info
        
    def _get_hours(self, html_doc):
        hours_nodes = HtmlUtils.get_elements(html_doc, '//table[@class="table table-striped"]')
        if len(hours_nodes) > 0:
           return self._get_hours_info(hours_nodes[0])
        return {}
        
        
    def _get_hours_info(self, hours_node):
        hours_info = {}
        day_nodes = HtmlUtils.get_elements(hours_node, './/tr')
        for day_node in day_nodes:
            key = HtmlUtils.get_element_value(day_node, './td[contains(text(),"day")]/text()').lower()
            value = HtmlUtils.get_element_value(day_node,'.//strong/text()')
            hours_info[key] = value
        return hours_info
        
    def _get_menu_info(self, html_doc):
        category_nodes = HtmlUtils.get_elements(html_doc, '//div[@class="panel panel-default"]')
        categories = {}
        for category_node in category_nodes:
            category_name = HtmlUtils.get_element_value(category_node, './/h2[@class="panel-title"]/a/text()')
            if category_name != '':
                categories[category_name] = self._get_category_from_menu_info(category_node)
                
        return categories
    
    def _get_category_from_menu_info(self, category_node):
        item_nodes = HtmlUtils.get_elements(category_node, './/div[@class="menu-item"]')
        items_info = []
        for item_node in item_nodes:
            item_name = HtmlUtils.get_element_value(item_node, './/h3[@class="menu-item-name"]/text()')
            if item_name != '':
                info = {}
                info['name'] = item_name
                info['prices'] = self._get_menu_item_prices_info(item_node)
                items_info.append(info)
        
        return items_info
        
    def _get_menu_item_prices_info(self, item_node):
        price_nodes = HtmlUtils.get_elements(item_node, './/div[contains(@class,"menu-item-prices hidden")]//li[not(contains(@class,"price-empty")) and contains(@class, "rounded gram-price")]')
        price_infos = []
        for price_node in price_nodes:
            unit = HtmlUtils.get_element_value(price_node, './/div[@class="unit"]/text()')
            if unit != '':
                info = {}
                info[unit] = HtmlUtils.get_element_value(price_node, './/div[@class="price rounded"]/text()')
                price_infos.append(info)
                
        return price_infos