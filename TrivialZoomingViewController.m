
#import "TrivialZoomingViewController.h"
#import "UIImageView+WebCache.h"


@interface TrivialZoomingViewController () <UIScrollViewDelegate>

@property (nonatomic, retain) UIImageView *imageView;

@end


@implementation TrivialZoomingViewController

@synthesize imageView=_imageView;
@synthesize imageURL;

- (void)loadView {
	UIScrollView *scrollView = [[[UIScrollView alloc] init] autorelease];
	scrollView.delegate = self;
	self.imageView = [[UIImageView alloc] init];
	[self.imageView setImageWithURL:[NSURL URLWithString:self.imageURL] 
				   placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
	CGSize imageSize = [self.imageView.image size];
	
	
	if(imageSize.width < 320) {
		imageSize.width = 320;
	}
	
	if (imageSize.height < 480) {
		imageSize.height = 480;
	}
	
	self.imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
	
	[scrollView addSubview:self.imageView];
	scrollView.contentSize = imageSize;
	scrollView.minimumZoomScale = 0.1;
	scrollView.maximumZoomScale = 10;
	self.view = scrollView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.imageView = nil;
	self.imageURL = nil;
}

- (void)dealloc {
	self.imageView = nil;
	self.imageURL = nil;
    [super dealloc];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

#pragma mark -
#pragma mark 터치 이벤트 받아서 pop시켜주기
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	MY_LOG(@"touchesBegan");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	MY_LOG(@"touchesMoved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	MY_LOG(@"touchesEnded");
}
@end
