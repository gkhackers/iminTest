//
//  UtilsTest.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 6. 20..
//  Copyright 2011 KTH. All rights reserved.
//

#import "Utils.h"

@interface UtilsTest : GHTestCase {}
@end

@implementation UtilsTest

- (void) testDistanceFromAToB {
	
	CGPoint pointA = CGPointMake(10000, 10000);
	CGPoint pointB = CGPointMake(20000, 20000);
	
	GHAssertEqualsWithAccuracy(14142.13562373095f, [Utils getDistanceFrom:pointA to:pointB], 0.001f, @"거리 계산 오차 발생");
}


- (void) testCurrDate {
    NSString* serverDate = @"2011.09.25 00:43:36";
    NSString* newDate = [Utils getDescriptionWithString:serverDate];
    GHAssertEqualStrings(newDate, @"2011.09.25", @"날짜 변환 버그");
}

@end
