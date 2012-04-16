
#import <UIKit/UIKit.h>

@interface TrivialZoomingViewController : UIViewController {
	UIImageView *_imageView;
	NSString* imageURL;
}

@property (nonatomic, retain) NSString* imageURL;

@end
