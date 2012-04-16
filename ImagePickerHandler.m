//
//  ImagePickerHandler.m
//  CameraUpgrade
//
//  Created by Myungjin Choi on 11. 12. 20..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import "ImagePickerHandler.h"
#import <MobileCoreServices/MobileCoreServices.h>
//#import "UIImage+Resize.h"

#define kRESIZE_WITH 720
#define kRESIZE_HEIGHT 960

@implementation ImagePickerHandler
@synthesize delegate;

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"finish. picker = %@, info = %@ ", picker, info);
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        NSDictionary* aDictionary = nil;
        
        NSDictionary* pickerControllerMediaMetaData = [info objectForKey:@"UIImagePickerControllerMediaMetadata"];
        if (pickerControllerMediaMetaData) {
            // 메타 데이터 있다면 촬영한 것으로 생각
//            NSInteger orientation = [[[info objectForKey:@"UIImagePickerControllerMediaMetadata"] objectForKey:@"Orientation"] intValue];
//            CGSize imageSize;
//            if (orientation == 1 || orientation == 3) {
//                // 가로로 누운 경우
//                imageSize = CGSizeMake(kRESIZE_HEIGHT, kRESIZE_WITH);
//            } else {
//                imageSize = CGSizeMake(kRESIZE_WITH, kRESIZE_HEIGHT);
//            }
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
            //            1.7.0 에서는 리사이즈 하지 않기로 결정함
            //            imageToSave = [imageToSave resizedImage:imageSize interpolationQuality:kCGInterpolationHigh]; 
            aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageToSave, @"imageToSave", @"camera", @"source", nil];
        } else {
            // 앨범에서 가져온 케이스로 생각
            //            imageToSave = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            //            UIImageOrientation orientaion = [imageToSave imageOrientation];
            //            NSLog(@"ortation = %d", orientaion);
            //            
            //            switch (orientaion) {
            //                case UIImageOrientationUp:
            //                case UIImageOrientationDown:
            //                case UIImageOrientationUpMirrored:
            //                case UIImageOrientationDownMirrored:
            //                    imageSize = CGSizeMake(kRESIZE_HEIGHT, kRESIZE_WITH);
            //                    break;
            //                    
            //                case UIImageOrientationLeft:
            //                case UIImageOrientationRight:
            //                case UIImageOrientationLeftMirrored:
            //                case UIImageOrientationRightMirrored:
            //                    imageSize = CGSizeMake(kRESIZE_WITH, kRESIZE_HEIGHT);
            //                    break;
            //                default:
            //                    break;
            //            }
            //            1.7.0 에서는 리사이즈 하지 않기로 결정함
            //            imageToSave = [imageToSave resizedImage:imageSize interpolationQuality:kCGInterpolationHigh];
            aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageToSave, @"imageToSave", @"album", @"source", nil];
        }
        
        if ([self.delegate respondsToSelector:@selector(returnWithData:)]) {
            [self.delegate performSelector:@selector(returnWithData:) withObject:aDictionary];
        }
        
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
		[CommonAlert alertWithTitle:@"안내" message:@"동영상 파일을 업로드 하실 수 없습니다."];
        
        //        NSString *moviePath = [[info objectForKey:
        //                                UIImagePickerControllerMediaURL] path];
        //        
        //        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
        //            UISaveVideoAtPathToSavedPhotosAlbum (
        //                                                 moviePath, nil, nil, nil);
        //        }
    }
    
    [picker dismissModalViewControllerAnimated: YES];
    [picker release];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel. picker = %@", picker);
    
    [picker dismissModalViewControllerAnimated: YES];
    [picker release];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"willShowVC");
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"didShowVC");
}

@end
