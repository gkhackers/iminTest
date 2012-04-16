//
//  ImagePickerHandler.h
//  CameraUpgrade
//
//  Created by Myungjin Choi on 11. 12. 20..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImagePickerFinishedDelegate <NSObject>
@optional
- (void) returnWithData:(NSDictionary*) data;
- (void) returnImage:(UIImage*) image;
@end

@interface ImagePickerHandler : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (assign) id <ImagePickerFinishedDelegate> delegate;
@end

