//
//  SetAuthTokenExTest.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 7. 4..
//  Copyright 2011 KTH. All rights reserved.
//

@interface SetAuthTokenExTest : GHTestCase {

	NSDictionary* resultDictionary;
}

@end

@implementation SetAuthTokenExTest

// Run before each test method
- (void)setUp { 
	NSString* retString = @"{ \"func\":\"setAuthTokenEx\", \"result\":true, \"description\":\"성공\" , \"errCode\":\"0\", \"setAuthToken\":{ \"snsId\":\"100000065772\", \"nickname\":\"막강규니\", \"profileImg\":\"http://snsfile.paran.com/SNS_165862/201107/620001383384_1309782690518_thumb1.jpg.jpg\", \"currAppVer\":\"40\", \"appUpdateUrl\":\"http://anroid.app.update.url\" }, \"getDelivery\":{ \"data\": [ { \"cpCode\":\"51\", \"blogId\":\"superplan21\", \"userName\":\"290584993-2ws1e2piBYte4byo34s1dAb4yRPZvvDB1sAVtlyg\", \"isDelivery\":\"1\", \"isCpNeighbor\":\"1\" } , { \"cpCode\":\"52\", \"blogId\":\"100002300781158\", \"userName\":\"서상균\", \"isDelivery\":\"1\", \"isCpNeighbor\":\"1\" } ] }, \"feedCount\":{ \"postCnt\":0, \"cmtCnt\":2, \"neighborCnt\":0, \"systemCnt\":0, \"recmtCnt\":1, \"captainCnt\":0, \"badgeCnt\":0, \"eventCnt\":0, \"isNew\":\"1\" }, \"profileInfo\":{ \"phoneNo\":\"01092484397\", \"useNPhoneNo\":\"\" } }";

	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	
	resultDictionary = [(NSDictionary *)[jsonParser objectWithString:retString error:NULL] retain];
	[jsonParser release];
}

// Run after each test method
- (void)tearDown {
	[resultDictionary release];
}

// Run before the tests are run for this class
//- (void)setUpClass { }

// Run before the tests are run for this class
//- (void)tearDownClass { }

// Tests are prefixed by 'test' and contain no arguments and no return value
- (void)testA { 
	GHTestLog(@"Log with a test with the GHTestLog(...) for test specific logging.");
}

// Another test; Tests are run in lexical order
- (void)testB { }

// Override any exceptions; By default exceptions are raised, causing a test failure
//- (void)failWithException:(NSException *)exception { }


@end
