//
//  LoginTests.m
//  ImIn
//
//  Created by park ja young on 11. 4. 27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OAuthWebViewController.h"

@interface LoginTests : GHTestCase {}
@end

@implementation LoginTests

- (void) testReturnToken {
	//NSString* retString = @"atkey=7f7d73914b31c8a2ea9667b38828a242636fed04&expiredt=202106251147256&userno=620018904754&iddomain=jjai22@naver.com&idtype=1&usernm=jjai22%40&nickname=jjai22%40&&oauth=201106291045554%16620018904754%16twitter.com%16imindev%16284275004%16jjai22%16%B8%DA%C2%F0%BF%A9%C0%DA%16%16%16%16284275004-MDSeU7FRdZfhP53kD9JJTsnGpjDhZ0pX9mQi7scO%16mM7nLanng9PUwyLn95xRxAsqADXkVfCrmvRaJREXR9Q%16201106291045544";
	NSString* msgString = @"expiredt=202106251147256&userno=620018904754&iddomain=jjai22@naver.com&idtype=1&usernm=jjai22%40&nickname=jjai22%40&&oauth=201106291045554%16620018904754%16twitter.com%16imindev%16284275004%16jjai22%16%B8%DA%C2%F0%BF%A9%C0%DA%16%16%16%16284275004-MDSeU7FRdZfhP53kD9JJTsnGpjDhZ0pX9mQi7scO%16mM7nLanng9PUwyLn95xRxAsqADXkVfCrmvRaJREXR9Q%16201106291045544&atkey=7f7d73914b31c8a2ea9667b38828a242636fed04";
	NSString* key = @"7f7d73914b31c8a2ea9667b38828a242636fed04";
	OAuthWebViewController* webVC = [[[OAuthWebViewController alloc] initWithNibName:@"OAuthWebViewController" bundle:nil] autorelease];
	
	NSString* retString = [webVC parsedString:msgString findString:@"atkey="];
	
	GHAssertEqualObjects(retString, key, @"mis match");
}

- (void) testUpdateDelivery {
	
	NSDictionary* retDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"51", @"cpCode", 
																   @"twitter", @"blogId", 
																   @"twitterName", @"userName",
																   @"1", @"isDelivery",
																   @"1", @"isCpNeighbor",
																   nil],
																 [NSDictionary dictionaryWithObjectsAndKeys:@"50", @"cpCode", 
																  @"me2day", @"blogId", 
																  @"me2dayName", @"userName",
																  @"0", @"isDelivery",
																  @"1", @"isCpNeighbor",
																  nil],
																 [NSDictionary dictionaryWithObjectsAndKeys:@"52", @"cpCode", 
																  @"facebook", @"blogId", 
																  @"fbName", @"userName",
																  @"1", @"isDelivery",
																  @"0", @"isCpNeighbor",
																  nil], nil], @"data", nil];
	
	UserContext* uc = [UserContext sharedUserContext];
	[uc updateDeliveryWithDictionary:retDictionary];
	
	GHAssertNotNULL(uc.cpTwitter, @"트위터 내보내기 설정");
	GHAssertEqualStrings(uc.cpTwitter.blogId, @"twitter", @"twitter blogId failed");
	GHAssertEqualStrings(uc.cpTwitter.cpCode, @"51", @"twitter cpCode failed");
	GHAssertEqualStrings(uc.cpTwitter.userName, @"twitterName", @"twitter userName failed");
	GHAssertEquals(uc.cpTwitter.isDelivery, YES, @"twitter isDelivery failed");
	GHAssertEquals(uc.cpTwitter.isConnected, YES, @"twitter isConnected failed");
	GHAssertEquals(uc.cpTwitter.isCpNeighbor, YES, @"twitter isCpNeighbor failed");
	
	
	GHAssertNotNULL(uc.cpFacebook, @"페이스북 내보내기 설정");
	GHAssertEqualStrings(uc.cpFacebook.blogId, @"facebook", @"facebook blogId failed");
	GHAssertEqualStrings(uc.cpFacebook.cpCode, @"52", @"facebook cpCode failed");
	GHAssertEqualStrings(uc.cpFacebook.userName, @"fbName", @"facebook userName failed");
	GHAssertEquals(uc.cpFacebook.isDelivery, YES, @"facebook isDelivery failed");
	GHAssertEquals(uc.cpFacebook.isConnected, YES, @"facebook isConnected failed");
	GHAssertEquals(uc.cpFacebook.isCpNeighbor, NO, @"facebook isCpNeighbor failed");
	
	GHAssertNotNULL(uc.cpMe2day, @"미투데이 내보내기 설정");
	GHAssertEqualStrings(uc.cpMe2day.blogId, @"me2day", @"me2day blogId failed");
	GHAssertEqualStrings(uc.cpMe2day.cpCode, @"50", @"me2day cpCode failed");
	GHAssertEqualStrings(uc.cpMe2day.userName, @"me2dayName", @"twitter userName failed");
	GHAssertEquals(uc.cpMe2day.isDelivery, NO, @"me2day isDelivery failed");
	GHAssertEquals(uc.cpMe2day.isConnected, YES, @"me2day isConnected failed");
	GHAssertEquals(uc.cpMe2day.isCpNeighbor, YES, @"me2day isCpNeighbor failed");
	
}

- (void) testLoginType {
	NSString* oAuth = @""; // nil, @"123456"
	UserContext* uc = [UserContext sharedUserContext];
	//[uc callSetAuthTokenEx
}
@end