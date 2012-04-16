//
//  AutoSearchCell.m
//  ImIn
//
//  Created by ja young park on 12. 2. 2..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AutoSearchCell.h"
//#import "NSAttributedString+Attributes.h"

@implementation AutoSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {	
	[mappingText release];
    [resultText release];

	[super dealloc];
}


- (void) populateCellWithData:(NSString*) inputText : (NSString*) outputText {
    int length = [inputText length];
    
    if ([outputText length] < length) {
        resultText.frame = CGRectMake(10, 8, 280, 20);
        resultText.text = outputText;
        return;
    }
    
    NSRange mappingTextRange = [outputText rangeOfString:inputText options:1 range:NSMakeRange(0,length)];
    if (mappingTextRange.location != NSNotFound) { // 만약 맵핑된 글자가 있으면
        NSString* temp= [outputText substringToIndex:length];
        float mappingTextWidth = 0;
        float resultTextWidth = 0;
        mappingText.text = temp;
        
        mappingTextWidth = [Utils getWrapperSizeWithLabel:mappingText fixedWidthMode:NO fixedHeightMode:NO].width;
        
        mappingText.frame = CGRectMake(10, 8, mappingTextWidth, 20);
        temp= [outputText substringFromIndex:length];
        resultText.text = temp;
        resultTextWidth = [Utils getWrapperSizeWithLabel:resultText fixedWidthMode:NO fixedHeightMode:NO].width;
        resultText.frame = CGRectMake(mappingTextWidth+10, 8, resultTextWidth, 20);
    } else {
        resultText.frame = CGRectMake(10, 8, 280, 20);
        resultText.text = outputText;  
    }
    return;

    //MY_LOG(@"inputText = %@, outputText = %@, inputText lenght = %d, mappingRange = %d", inputText, outputText, length, mappingTextRange.location+1);
}

@end
