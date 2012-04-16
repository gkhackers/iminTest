//
//  AutoCompletion.m
//  ImIn
//
//  Created by KYONGJIN SEO on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AutoCompletion.h"
#import "NSString+URLEncoding.h"

@implementation AutoCompletion
@synthesize data;
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{	\"func\": \"autoCompletion\", \"result\": \"true\", \"resultcount\": \"3\", \"description\": \"성공\", \"errCode\": \"0\", \"data\": [ { \"poiName\": \"STARPAIKS_coffee\", \"poiKey\": \"U1000004535100\", \"poiAddr\": \"서울특별시_동작구_신대방2동\", \"pointX\": \"193206\", \"pointY\": \"443411\", \"category\": \"2007003000,\", \"poiPhoneNo\": \"0\" }, { \"poiName\": \"angel_in-us_coffee\", \"poiKey\": \"U1000003925800\", \"poiAddr\": \"서울특별시_관악구_신림5동\", \"pointX\": \"193700\", \"pointY\": \"442461\", \"category\": \"2007004000,\", \"poiPhoneNo\": \"0\" }, { \"poiName\": \"coffeeoda\", \"poiKey\": \"U1000000121800\", \"poiAddr\": \"서울특별시_관악구_신사동\", \"pointX\": \"192777\", \"pointY\": \"442251\", \"category\": \"2007003000,\", \"poiPhoneNo\": \"0\" } ] }";
}
#endif

- (NSString*) url
{
	
#ifdef APP_STORE_FINAL	
	NSString* toReturn = [NSString stringWithFormat:@"http://211.113.41.128:8080/as_imin.php?colnum=1&query=%@&colname1=poi&kma1=1&case1=0&x=%@&y=%@&poi=4&weight=0.0&page=1&psize=1&range=2000&category", [[data objectForKey:@"query"] URLEncodedString], [data objectForKey:@"x"], [data objectForKey:@"y"]];    //TODO:확인
#else
	NSString* toReturn = [NSString stringWithFormat:@"http://211.113.41.128:8080/as_test.php?colnum=1&query=%@&colname1=poi&kma1=1&case1=0&x=%@&y=%@&poi=4&weight=0.0&page=1&psize=1&range=2000&category", [[data objectForKey:@"query"] URLEncodedString], [data objectForKey:@"x"], [data objectForKey:@"y"]];
#endif
	
	return toReturn;
}

@end
