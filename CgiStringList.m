//
//  CgiStringList.m
//  testThread
//
//  Created by mandolin on 08. 07. 28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CgiStringList.h"
#import "Utils.h"
//#import <Foundation/Foundation.h>

@implementation CgiStringList
@synthesize mTable;

- (id) init:(NSString*) delemeter {
	self = [super init];
	if (self != nil) {
		//mTable = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 10 );
		mTable =[[NSMutableDictionary alloc]initWithCapacity:20];
		m_strDelemeter = delemeter;
	}
	return self;
}

- (id) init {
	self = [super init];
	if (self != nil) {
		//mTable = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 10 );
		mTable =[[NSMutableDictionary alloc]initWithCapacity:20];
		m_strDelemeter = @"&";
	}
	return self;
}

- (void) dealloc {
	// MY_LOG(@"Free Map Table")
	//NSFreeHashTable(mTable);
	[mTable release];
	[super dealloc];
}

- (void)setMapString:(NSString*)key keyvalue:(NSString*)value {
	//MY_LOG(@"setMapString Key : %@ Value: %@ dictionarySize:%d",key, value, [mTable count]);
	NSString *encodeKey = [self urlencode:key];
	NSString *encodeValue = [self urlencode:value];
	
	//NSMapInsert(mTable, encodeKey, encodeValue);
	
	[mTable setValue:encodeValue forKey:encodeKey];
}

- (NSString*) getValue : (NSString*)key {
	//MY_LOG(@"getValue key :%@",key);
	//void*  value = NSMapGet(mTable, key);

	void* value = [mTable objectForKey:key];
	NSString* resultValue = [NSString stringWithFormat:@"%@", value];
//	MY_LOG(@"ResultValue : %@", resultValue);
	if ([resultValue isEqualToString:@"(null)"])
		resultValue = @"";
	NSString* decodeResultValue = [self urldecode:resultValue];
	NSArray *listItems = [decodeResultValue componentsSeparatedByString:@"\n"];
	NSArray *listItems2 = [[listItems objectAtIndex:0] componentsSeparatedByString:@"\r"];
	return [listItems2 objectAtIndex:0];
}

- (void) setCgiString : (NSString*)cgiStr {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//MY_LOG(@"CgiStr :", cgiStr);
    // m_strDelemeter = @"&";
	NSArray *listItems = [cgiStr componentsSeparatedByString:m_strDelemeter];
	int i;
	NSString* item;
	for (i=0;i<[listItems count];i++)
	{
		//MY_LOG(@"PacketItem : %@", [listItems objectAtIndex:i]);
		item = [listItems objectAtIndex:i];
		if (![item isEqualToString:@""])
		{
			
			NSArray *subItems = [item componentsSeparatedByString:@"="];
			if ([subItems count] >= 2)
			{
				int idx;
				NSString* subItemResult=@"";
				for(idx=1;idx<[subItems count];idx++)
				{
					if (idx == [subItems count]-1)
					{
						subItemResult = [subItemResult stringByAppendingString:[subItems objectAtIndex:idx]];
					}
					else
					{
						subItemResult = [subItemResult stringByAppendingString:[subItems objectAtIndex:idx]];
						subItemResult = [subItemResult stringByAppendingString:@"="];
					}
				}
				[self setMapString:[subItems objectAtIndex:0] keyvalue:subItemResult];
				//[self setMapString:[subItems objectAtIndex:0] keyvalue:[subItems objectAtIndex:1]];
				///NSString* testvalue = [subItems objectAtIndex:0];
				//MY_LOG(@"Log~~~~~ %@",[self getValue:testvalue]);
			}

		}
	}
	
	
	[pool release];
}

- (NSString*) description {
	
	// 암호화 루틴 추가
	//NSString* sign = [NSString stringWithFormat:@"%@%@%@%@",userID.text,@"paran.com",SNS_CONSUMER_KEY,SNS_SIGNATURE];
	//[self setMapString:@"signature" keyvalue:[Utils digest:sign]];

	
	NSString* resultStr = @"";
	NSString* packet;
	for (id key in mTable)
	{
//		MY_LOG(@"key: %@, value: %@", key, [mTable objectForKey:key]);
		packet = [NSString stringWithFormat:@"%@=%@%@",key, [mTable objectForKey:key],m_strDelemeter];
		resultStr = [resultStr stringByAppendingString:packet];
	}
	return [resultStr stringByAppendingString:[Utils encryptStringWithAv:[mTable objectForKey:@"av"]]];
}



- (NSString *) urlencode: (NSString *) orgStr
{
	if (orgStr == nil || [orgStr isEqualToString:@""]) return @"";
	
    /*NSArray *escapeChars = [NSArray arrayWithObjects:@"%", @";" , @"/" , @"?" , @":" ,
		@"@" , @"&" , @"=" , @"+" ,
		@"$" , @"," , @"[" , @"]",
		@"#", @"!", @"'", @"(", 
		@")", @"*", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%25", @"%3B" , @"%2F" , @"%3F" ,
		@"%3A" , @"%40" , @"%26" ,
		@"%3D" , @"%2B" , @"%24" ,
		@"%2C" , @"%5B" , @"%5D", 
		@"%23", @"%21", @"%27",
		@"%28", @"%29", @"%2A", nil];*/
	NSArray *escapeChars = [NSArray arrayWithObjects:
							@"%", @";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,	@"$" ,
							@"," , @"[" , @"]",	@"#", @"!",
							@"'", @"(",	@")",  
							@"•",@"£",@"¥",@"￦",@"€",nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:
							 @"%25", @"%3B" , @"%2F" , @"%3F" , @"%3A" ,
							 @"%40" , @"%26" , @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", @"%23", @"%21", 
							 @"%27", @"%28", @"%29",
							 @"%C2%B7",@"%EF%BF%A1",@"%EF%BF%A5",@"%EF%BF%A6",@"%E2%88%88", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [orgStr mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	[temp release];
	
    return out;
}

- (NSString *) urldecode: (NSString *) encodeStr
{
	if (encodeStr == nil || [encodeStr isEqualToString:@""]) return @"";
	NSArray *escapeChars = [NSArray arrayWithObjects:
							@"%", @";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,	@"$" ,
							@"," , @"[" , @"]",	@"#", @"!",
							@"'", @"(",	@")",  
							@"•",@"£",@"¥",@"￦",@"€",nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:
							 @"%25", @"%3B" , @"%2F" , @"%3F" , @"%3A" ,
							 @"%40" , @"%26" , @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", @"%23", @"%21", 
							 @"%27", @"%28", @"%29",
							 @"%C2%B7",@"%EF%BF%A1",@"%EF%BF%A5",@"%EF%BF%A6",@"%E2%88%88", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [encodeStr mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [replaceChars objectAtIndex:i]
							  withString:[escapeChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	//MY_LOG(@"UrlDecodeResult : %@",out);
	[temp release];
    return out;
}
@end
