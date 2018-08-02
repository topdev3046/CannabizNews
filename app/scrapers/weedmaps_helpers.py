import re
from lxml import html
from jsonutils import *

class WeedMapsDespensaryExtractor(object):

    def get_details(self, details_obj):
        result = {}
        listingLst = try_get_list(details_obj, 'data','listing')
        if len(listingLst) == 0:
            return result

        listing = listingLst[0]
        
        self._fill_details(result,listing)
        result['contact'] = self._get_contact(listing)
        result['region'] = self._get_region(listing)
        result['social_media'] = self._get_social_media(listing)
        result['hours_of_operation'] = self._get_hours_info(listing)
        
        return result
    
    def _fill_details(self,result, listing):
        result['name'] = get_key_or_default(listing, 'name')
        result['url'] = get_key_or_default(listing, 'web_url')
        result['reviews_count'] = get_key_or_default(listing, 'reviews_count')
        result['rating'] = get_key_or_default(listing, 'rating')
        result['min_age'] = get_key_or_default(listing, 'min_age')
        result['intro_body'] = get_key_or_default(listing, 'intro_body')
        result['description'] = get_key_or_default(listing, 'description')
        result['first_time_announcement'] = get_key_or_default(listing, 'first_time_announcement')
        result['announcement'] = get_key_or_default(listing, 'announcement')
        result['member_since'] = get_key_or_default(listing, 'member_since')
        
        result['avatar_url'] = ''
        logo_list = try_get_list(listing, 'avatar_image')
        
        if len(logo_list)>0:
            result['avatar_url'] = get_key_or_default(logo_list[0],'small_url')

    def _get_contact(self, listing):
        result = {}
        
        result['website'] = get_key_or_default(listing, 'website')
        result['city'] = get_key_or_default(listing, 'city')
        result['email'] = get_key_or_default(listing, 'email')
        result['zip'] = get_key_or_default(listing, 'zip_code')
        result['lon'] = get_key_or_default(listing, 'longitude')
        result['phone'] = get_key_or_default(listing, 'phone_number')
        result['state'] = get_key_or_default(listing, 'state')
        result['address'] = get_key_or_default(listing, 'address')
        result['lat'] = get_key_or_default(listing, 'latitude')
        result['website'] = get_key_or_default(listing, 'website')
        result['country'] = get_key_or_default(listing,'country')
        
        return result
        
    def _get_region(self, listing):
        result = {}
        
        region_list = try_get_list(listing, 'region')
        
        if len(region_list) > 0:
            result['name'] = get_key_or_default(region_list[0],'name')
            result['path'] = 'https://weedmaps.com/dispensaries/in/' + get_key_or_default(region_list[0], 'region_path')
        
        return result
        
    def _get_social_media(self, listing):
        result = {}
        
        info_list = try_get_list(listing, 'social')
        if len(info_list) > 0:
            facebook_id = get_key_or_default(info_list[0], 'facebook_id')
            twitter_id = get_key_or_default(info_list[0], 'twitter_id')
            instagram_id = get_key_or_default(info_list[0],'instagram_id')
            
            result['facebook'] = self._reconstruc_social_url(facebook_id, 'https://www.facebook.com/') if facebook_id else ''
            result['twitter'] = self._reconstruc_social_url(twitter_id, 'https://twitter.com/') if twitter_id else ''
            result['instagram'] = self._reconstruc_social_url(instagram_id, 'https://www.instagram.com/') if instagram_id else ''
        
        return result
        
    def _reconstruc_social_url(self, unkonw_url, absolute_url):
        return unkonw_url if unkonw_url.startswith('http') else absolute_url + unkonw_url

    def _get_hours_info(self, listing):
        return get_key_or_default(listing, 'business_hours', {})
    
    def get_menu(self, menu_obj):
        result = {}
         
        result['info'] = {}
        result['items'] = []
        
        info_list = try_get_list(menu_obj, "meta")
        
        if len(info_list):
            result['info'] = self._get_menu_info(info_list[0])
       
        items_list = try_get_list(menu_obj, 'data', 'menu_items')
        if len(items_list) > 0:
            result['items'] = self._group_dic_by_key(self._get_menu_items(items_list[0]), "category")
        
        return result


    def _get_menu_info(self, menu_meta):
        result = {}
        
        result['last_updated'] = get_key_or_default(menu_meta, 'updated_at')
        return result
        
    def _get_menu_items(self, items):
        result = []
        for item in items:
            result.append(self._get_menu_item(item))
            
        return result
        
    def _get_menu_item(self, item):
        result = {}
        
        result['name'] = get_key_or_default(item,'name')
        result['is_online_orderable'] = get_key_or_default(item,'is_online_orderable')
        result['avatar_image'] = self._get_first_key_or_empty(item, 'avatar_image', 'large_url')
        result['category'] = self._get_first_key_or_empty(item, 'category', 'name')
        result['prices'] = self._get_prices(item)
        return result
        
    def _get_first_key_or_empty(self, item, *args):
        lst = try_get_list(item, *args)
        
        return lst[0] if len(lst) > 0 else ''
        
    def _get_prices(self, item):
        prices = item['prices']
        
        if prices and 'grams_per_eighth' in prices:
            del prices['grams_per_eighth']
        
        result = []
        for key, value in prices.iteritems():
            if type(value) is list:
                for v in value:
                    result.append(self._get_price(v, key))
            else:
                result.append(self._get_price(value, key))
        
        return result
        
    def _get_price(self, priceObj, unit):
        result = {}
        result['price'] = priceObj['price']
        result['unit'] = priceObj['units'] + ' ' + unit
        
        return result
    
    def _group_dic_by_key(self, items, key):
        result = {}
        
        for item in items:
            if not item[key] in result:
                result[item[key]] = []
            result[item[key]].append(item)
        
        return result
        
def get_key_or_default(dic, key, default=''):
    return dic[key] if key in dic else default