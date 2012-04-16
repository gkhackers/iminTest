//
//  UtilsTest.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 6. 20..
//  Copyright 2011 KTH. All rights reserved.
//

#import "RegexKitLite.h"

@interface RegexKitLiteTest : GHTestCase {}
@end

@implementation RegexKitLiteTest

- (void) testPullUrlsFromString {

	NSString* searchString = @"여기 가보세요 정말 좋아요. http://abc.com/?1234 시간나면 여기도 abc.com/~choipd ㅋㅋ";
    NSString* regexString  = @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?≪≫“”‘’]))";
    NSArray* matchArray   = NULL;
    
    matchArray = [searchString componentsMatchedByRegex:regexString];
    
    MY_LOG(@"matchArray: %@", matchArray);
    
    NSArray* expectArray = [NSArray arrayWithObjects:@"http://abc.com/?1234", @"abc.com/~choipd", nil];
    
    GHAssertEqualObjects(matchArray, expectArray, @"mis match");
}


@end
