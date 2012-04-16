//
//  Utils.h
//  ImIn
//
//  Created by choipd on 10. 5. 11..
//  Copyright 2010 edbear. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CgiStringList.h"

/**
 @brief 각종 유틸리티 함수 모음
 */

@interface Utils : NSObject {

}
+ (CGSize) getWrapperSizeWithLabel:(UILabel*) aLable;
+ (CGSize) getWrapperSizeWithLabel:(UILabel*) aLabel 
					fixedWidthMode:(BOOL) fixedWidth
				   fixedHeightMode:(BOOL) fixedHeight;

+ (NSDate*) convertToUTC:(NSDate*)sourceDate;
+ (NSDate*) convertToLocale:(NSDate *)sourceDate;
+ (NSString*) getDescriptionWithString:(NSString*) regDateString;
+ (NSString*) getSimpleDateWithString:(NSString*) regDateString;
+ (NSDate*) getDateWithString:(NSString*) regDateString;
+ (NSDate*) getDateWithString:(NSString *)regDateString withStyle:(NSString*)style;
+ (NSString*) stringFromDate:(NSDate*)aDate;
+ (NSString*) stringFromDate:(NSDate *)aDate withStyle:(NSString*)style;
+ (NSString*) stringFromDevice:(NSString*)deviceID;
+ (int) calcDistanceFromX:(int)fromx fromY:(int)fromy toX:(int)tox toY:(int)toy;
/// 암호화
+ (NSString*) digest:(NSString*)input;
+ (NSString*) encryptString;
+ (NSString*) encryptStringWithAv:(NSString*) av;
+ (NSString*) getISO8601Date;
+ (NSString*) headerString;
+ (NSString*) getNormalDate;
+ (NSString*) ts;
+ (NSString*) s;
+ (NSString*) sWithAv:(NSString*) av;

+ (NSDictionary*) getPhoneBook;
+ (NSString*) getPhoneAndNameWithMd5:(NSString*) md5;
+ (NSString*) getNameWithMd5:(NSString*) md5;

+ (NSString*) addDashToPhoneNumber:(NSString*)phoneNo;

+ (NSString*) getTimeIntervalSinceServerTimeNow:(NSTimeInterval) interval;

+ (NSString*) md5:(NSString *) plain;
+ (NSString*) lastFeedDate;

/// 이미지 캐시
+ (void) requestImageCacheWithURL:(NSString*) urlString 
						 delegate:(id)aDelegate 
					 doneSelector: (SEL)aDoneSelector 
					errorSelector: (SEL)anErrorSelector
				 cacheHitSelector: (SEL)anCacheHitSelector;

+ (UIImage*) imageWithURL: (NSString*) url;

+ (NSString*) get53ImageFrom:(NSString*)baseURL;
+ (NSString*) get84ImageFrom:(NSString*)baseURL;
+ (NSString*) get84BgImageFrom:(NSString*)baseURL;
+ (NSString*) get168ImageFrom:(NSString*)baseURL;
+ (NSString*) get252ImageFrom:(NSString*)baseURL;
+ (UIImage*) getImageFromBaseUrl:(NSString*)baseUrl withSize:(NSString*)size withType:(NSString*)type;

/// 거리 계산
+ (float) getDistanceFrom:(CGPoint) point1 to:(CGPoint) point2;
+ (float) getDistanceToHereFrom:(CGPoint) aPoint;

+ (UIView*) createNoticeViewWithDictionary:(NSDictionary*) data;

+ (BOOL) isValidNeighborRecomWithArray:(NSArray*) list;
+ (BOOL) isBrandUser:(NSDictionary*) data;
+ (NSString*) convertImgSize70to38:(NSString*) oriImg;
+ (NSString*) convertImgSize70to47:(NSString*) oriImg;
@end
