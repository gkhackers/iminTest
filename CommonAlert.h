//
//  CommonAlert.h
//  ImIn
//
//  Created by choipd on 10. 4. 29..
//  Copyright 2010 edbear. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 네트워크 접속 오류 알림창 공통 모듈
 */
@interface CommonAlert : NSObject {
}
+ (void) alertWithTitle:(NSString*)title message:(NSString*)msg;

@end
