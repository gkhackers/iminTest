//
//  ReplyCellData.m
//  ImIn
//
//  Created by choipd on 10. 5. 17..
//  Copyright 2010 edbear. All rights reserved.
//

#import "ReplyCellData.h"
#import "Utils.h"
#import "const.h"

@implementation ReplyCellData

@synthesize cmtID;
@synthesize parentID;
@synthesize postID;
@synthesize snsID;
@synthesize nickName;
@synthesize profileImgURL;
@synthesize comment;
@synthesize device;
@synthesize isBlind;
@synthesize isPolicePerm;
@synthesize imgURL;
@synthesize regDate;
@synthesize description;
@synthesize status;
@synthesize bizType;
@synthesize userType;

- (id) initWithDictionary: (NSDictionary*) jsonData
{
	self = [super init];
	if (self != nil) {
		self.cmtID = [jsonData objectForKey:@"cmtId"];
		self.parentID = [jsonData objectForKey:@"parentId"];
		self.postID = [jsonData objectForKey:@"postId"];
		self.snsID = [jsonData objectForKey:@"snsId"];
		self.nickName = [jsonData objectForKey:@"nickname"];
		self.profileImgURL = [jsonData objectForKey:@"profileImg"];
		self.comment = [jsonData objectForKey:@"comment"];
		
		self.device = [jsonData objectForKey:@"deviceName"];

		self.comment = [jsonData objectForKey:@"comment"];
        self.bizType = [jsonData objectForKey:@"bizType"];
        self.userType = [jsonData objectForKey:@"userType"];
		
		NSString* imgUrlTmp = [jsonData objectForKey:@"imgUrl"];
		
		if ([imgUrlTmp isEqualToString:@""] || nil == imgUrlTmp) {
			self.imgURL = @"";
		} else {
			MY_LOG(@"post image URL(before) : %@", imgUrlTmp);
			//self.postImgURL = [imgUrl stringByReplacingOccurrencesOfString:@"imindev" withString:@"opdev"];
			self.imgURL = imgUrlTmp;
			MY_LOG(@"comment image url : %@", self.imgURL);			
		}
		NSString* regDateString = [jsonData objectForKey:@"regDate"];
		NSString* timeDesc = [Utils getDescriptionWithString:regDateString];
		
		NSString* comma = @"";
		if (![self.device isEqualToString:@""]) {
			comma = @",";
		}
		self.description = [NSString stringWithFormat:@"%@%@ %@", timeDesc, comma, self.device];
		
	}
	return self;
}

- (BOOL) isBrandUser
{
    return ([bizType isEqualToString:@"BT0001"] || [bizType isEqualToString:@"BT0002"]) && [userType isEqualToString:@"UB0001"];
}


@end
