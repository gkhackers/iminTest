//
//  AlbumPreviewViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 12. 28..
//  Copyright (c) 2011년 KTH. All rights reserved.
//



@interface AlbumPreviewViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *previewImageView;
@property (retain, nonatomic) UIImage* image;
@property (assign) id delegate;

- (IBAction)useThisImage:(id)sender;
- (IBAction)cancelThisImage:(id)sender;
@end
