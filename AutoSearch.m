//
//  AutoSearch.m
//  ImIn
//
//  Created by ja young park on 11. 12. 20..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "AutoSearch.h"
#import "NSString+URLEncoding.h"

@implementation AutoSearch
@synthesize data;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    [data release];
    [super dealloc];
}


- (NSString*) url
{
	NSString* toReturn = [NSString stringWithFormat:@"http://autosearch.paran.com/imin/ac_imin.php?Query=%@&test=test", [[data objectForKey:@"Query"] URLEncodedString]];
    //NSString* toReturn = @"http://autosearch.paran.com/imin/ac_imin.php";
    
    MY_LOG(@"AutoSearch API URL: %@", toReturn);
	return toReturn;
}

#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"autoSearch\",\"result\":\"true\",\"description\":\"성공\",\"errCode\":\"0\",\"resultcount\":\"10\",\"Query\":\"abc\",\"forward\":[\"abcmart강남본점\",\"abcdefg\",\"abcd마트과이점\",\"abcmart\",\"abc2층창고\",\"abcde\",\"abc\",\"abcccc\",\"abcabc\",\"abcmart구월동점\"],\"initsyllable\":[]}";
}
#endif


@end

