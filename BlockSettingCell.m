//
//  BlockSettingCell.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 21..
//  Copyright 2011 KTH. All rights reserved.
//

#import "BlockSettingCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "DenyGuestDelete.h"

@implementation BlockSettingCell

@synthesize denyGuestDelete;
@synthesize denyGuest;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[denyGuestDelete release];
	[denyGuest release];
    [super dealloc];
}

- (IBAction) unblock:(UIButton*) sender
{
	self.denyGuestDelete = [[[DenyGuestDelete alloc] init] autorelease];
	denyGuestDelete.delegate = self;
	[denyGuestDelete.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:sender.layer.name forKey:@"delDenySnsId"]];
	[denyGuestDelete request];
}

- (void) populateCellWithDictionary:(NSDictionary*)data
{
	self.denyGuest = data;
	[profileImageView setImageWithURL:[NSURL URLWithString:[data objectForKey:@"denyProfileImg"]]
					 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
	
	nickname.text = [data objectForKey:@"denyNickname"];
	unblockBtn.layer.name = [data objectForKey:@"denySnsId"];	
}

#pragma mark -
#pragma mark ImInProtocol

- (void) apiDidLoad:(NSDictionary *)result
{
	MY_LOG(@"차단 해지 완료");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"denyListChanged" object:nil userInfo:denyGuest];
}

- (void) apiFailed
{
	MY_LOG(@"차단 해지 실패");
}

@end
