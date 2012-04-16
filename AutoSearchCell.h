//
//  AutoSearchCell.h
//  ImIn
//
//  Created by ja young park on 12. 2. 2..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "OHAttributedLabel.h"

/**
 @brief 직접찍기 자동완성검색 결과 셀
 */
@interface AutoSearchCell : UITableViewCell {
    IBOutlet UILabel* mappingText;
    IBOutlet UILabel* resultText;
}

- (void) populateCellWithData:(NSString*) inputText : (NSString*) outputText ;

@end
