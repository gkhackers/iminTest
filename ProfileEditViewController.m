//
//  ProfileEditViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 15..
//  Copyright 2011 KTH. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "ProfileEditViewController.h"
#import "UIImageView+WebCache.h"
#import "ProfileUpdate.h"
#import "Uploader.h"
#import "ASIFormDataRequest.h"

@interface ProfileEditViewController(private)
- (void) presentSheet;
- (IBAction) presentSelectionSheet;
- (IBAction) getCameraPicture:(UIImagePickerControllerSourceType)sourceType;
- (IBAction) selectExistingPicture;
@end


#define DOCSFOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define PROGRESS_BAR	999
#if defined(APP_STORE_FINAL)
	#define TMP_IMG_PREFIX @"http://snsapi.paran.com"
#else
	#define TMP_IMG_PREFIX @"http://imindev.paran.com/sns"
#endif


@implementation ProfileEditViewController

@synthesize homeInfoDetailResult;
@synthesize profileUpdate;
@synthesize baseSheet;
@synthesize tmpProfileImageURL;

static const int kMAX_CHARACTER_LENGTH = 140;
static const int COVERVIEW_TAG = 10000;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    realtimeBadge = [[RealtimeBadge alloc] init];
    realtimeBadge.delegate = self;
    
	UIImage *image = [UIImage imageNamed:@"round_input_box.png"]; 
	UIImage *strImage = [image stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	textViewBgImage.image = strImage;
	profileImageChangeViewBgImage.image = [[UIImage imageNamed:@"round_setbox_off.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	birthBgImageView.image = [[UIImage imageNamed:@"round_setbox_off.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	realnameBgImage.image = strImage;
	
	[profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[UserContext sharedUserContext].userProfile]]
					 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
		
	[settingScrollView setContentSize:CGSizeMake(320, 530)];
	[settingScrollView setFrame:CGRectMake(0, 43, 320, 411-43)];
	[self.view addSubview:settingScrollView];
	
	// add picker view
	[birthdayArea setFrame:CGRectMake(0, 460, 320, 258)];
	[self.view addSubview:birthdayArea];
	
	realnameTextField.text = [homeInfoDetailResult objectForKey:@"realName"];
	introduceTextView.text = [homeInfoDetailResult objectForKey:@"prMsg"];
	textLengthRemain.text = [NSString stringWithFormat:@"%d", kMAX_CHARACTER_LENGTH - [introduceTextView.text length]];
	
	NSString* prBirth = [homeInfoDetailResult objectForKey:@"prBirth"];
	int prBirthTypeNo = [[homeInfoDetailResult objectForKey:@"prBirthType"] intValue];
	NSString* prBirthType = @"";
	
	switch (prBirthTypeNo) {
		case 0:
			prBirthType = @"";
			break;
		case 1:
			prBirthType = @"양력";
			break;
		case 2:
			prBirthType = @"음력";
			break;
		default:
			break;
	}
	if ([prBirth isEqualToString:@""] || [prBirth length] != 4 || [prBirthType isEqualToString:@""]) {
		birthdayLabel.text = @"설정하기";
	} else {
		NSString* birthString = [NSString stringWithFormat:@"%@월 %@일", [prBirth substringToIndex:2], [prBirth substringFromIndex:2]];
		birthdayLabel.text = [NSString stringWithFormat:@"%@ %@", prBirthType, birthString];
	}
	isOpenPrBirthSwith.on = [[homeInfoDetailResult objectForKey:@"isOpenPrBirth"] boolValue];
	
	if ([prBirth isEqualToString:@""]) {
		isOpenPrBirthSwith.enabled = NO;
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[homeInfoDetailResult release];
	[baseSheet release];
	[tmpProfileImageURL release];
	[profileUpdate release];
    [realtimeBadge release];
    
    [super dealloc];
}

- (IBAction) popVC:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Keyboard event 처리
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	[settingScrollView setContentOffset:CGPointMake(0, 115) animated:YES];
	return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView {
	textLengthRemain.text = [NSString stringWithFormat:@"%d", kMAX_CHARACTER_LENGTH - [introduceTextView.text length]];
	if ([introduceTextView.text length] > kMAX_CHARACTER_LENGTH) {
		textLengthRemain.textColor = [UIColor redColor];
	} else {
		textLengthRemain.textColor = RGB(0x01, 0x81, 0xb0);
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[settingScrollView setContentOffset:CGPointMake(0, 80) animated:YES];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark IBAction 처리
- (IBAction) changeProfileImage
{
	[self presentSelectionSheet];
}

- (IBAction) closeKeyboard
{
	[realnameTextField resignFirstResponder];
	[introduceTextView resignFirstResponder];
	[self disappearBirthdayPickerView];
}

- (IBAction) showBirthdayPickerView
{
	[introduceTextView resignFirstResponder];
	int type = 0;
	int month = 0;
	int day = 0;
	
	if (![birthdayLabel.text isEqualToString:@"설정하기"]) {
		NSArray* birthdayComponents = [birthdayLabel.text componentsSeparatedByString:@" "];

		type = [[birthdayComponents objectAtIndex:0] isEqualToString:@"양력"] ? 0 : 1;
		month = [[[[birthdayComponents objectAtIndex:1] componentsSeparatedByString:@"월"] objectAtIndex:0] intValue] - 1;
		day = [[[[birthdayComponents objectAtIndex:2] componentsSeparatedByString:@"일"] objectAtIndex:0] intValue] - 1;
	}

	[birthdayPickerView selectRow:type inComponent:0 animated:YES];
	[birthdayPickerView selectRow:month inComponent:1 animated:YES];
	[birthdayPickerView selectRow:day inComponent:2 animated:YES];
	
	[UIView beginAnimations:nil context:nil];
	[birthdayArea setFrame:CGRectMake(0, 460-258, 320, 258)];
	[UIView commitAnimations];
}

- (IBAction) disappearBirthdayPickerView
{
	[UIView beginAnimations:nil context:nil];
	[birthdayArea setFrame:CGRectMake(0, 460, 320, 258)];
	[UIView commitAnimations];
}

- (IBAction) saveBirthdayInfo
{
	birthdayLabel.text = [NSString stringWithFormat:@"%@ %d월 %d일",
					  [birthdayPickerView selectedRowInComponent:0] == 0 ? @"양력" : @"음력",
					  [birthdayPickerView selectedRowInComponent:1]+1,
					  [birthdayPickerView selectedRowInComponent:2]+1];
	MY_LOG(@"birthday string = %@", birthdayLabel.text);
	
	isOpenPrBirthSwith.enabled = YES;
	[self disappearBirthdayPickerView];
}

- (IBAction) requestProfileUpdate
{
	
	if ([realnameTextField.text length] > 5) {
		[CommonAlert alertWithTitle:@"안내" message:@"이름은 다섯 자까지 입력가능해요~!"];
		return;
	}
	
	if ([introduceTextView.text length] > 140) {
		[CommonAlert alertWithTitle:@"안내" message:@"자기 소개가 너무 길어요~!"];
		return;
	}
	
	
	self.profileUpdate = [[[ProfileUpdate alloc] init] autorelease];
	profileUpdate.delegate = self;
	
	if (tmpProfileImageURL != nil && ![tmpProfileImageURL isEqualToString:@""]) {
		tmpProfileImageURL = [tmpProfileImageURL stringByReplacingOccurrencesOfString:TMP_IMG_PREFIX withString:@""];
		[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:tmpProfileImageURL forKey:@"profileImg"]];
	} else {
		// 프로필 이미지 변동이 없을 경우에는 그냥 이전 것을 쓴다.
		[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[homeInfoDetailResult objectForKey:@"profileImg"] 
																				   forKey:@"profileImg"]];
	}

	
	if (![realnameTextField.text isEqualToString:@""]) {
		[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:realnameTextField.text forKey:@"realName"]];
	} else {
		[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"" forKey:@"realName"]];
	}

	
	if (![birthdayLabel.text isEqualToString:@""] && ![birthdayLabel.text isEqualToString:@"설정하기"]) {
		NSArray* birthdayComponents = [birthdayLabel.text componentsSeparatedByString:@" "];
		
		if ([[birthdayComponents objectAtIndex:0] isEqualToString:@"양력"]) {
			[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"1" forKey:@"prBirthType"]];
		} else if ([[birthdayComponents objectAtIndex:0] isEqualToString:@"음력"]) {
			[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"2" forKey:@"prBirthType"]];
		}
		
		int month = [[[[birthdayComponents objectAtIndex:1] componentsSeparatedByString:@"월"] objectAtIndex:0] intValue];
		int day = [[[[birthdayComponents objectAtIndex:2] componentsSeparatedByString:@"일"] objectAtIndex:0] intValue];
		if (month > 0 && month < 13 && day > 0 && day < 32) {
			NSString* birthDayString = [NSString stringWithFormat:@"%02d%02d", month, day];
			[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:birthDayString forKey:@"prBirth"]];
		}
	}
	
	if (![introduceTextView.text isEqualToString:@""]) {
		[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:introduceTextView.text forKey:@"prMsg"]];
	} else {
		[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"" forKey:@"prMsg"]];
	}
	
	
	[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:isOpenPrBirthSwith.on ? @"1" : @"0" 
																			   forKey:@"isOpenPrBirth"]];
	
	[profileUpdate request];
}

#pragma mark -
#pragma mark PicakerView delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString* toRet = @"";
	
	switch (component) {
		case 0:
			toRet = (row == 0) ? @"양력" : @"음력";
			break;
		case 1:
			toRet = [NSString stringWithFormat:@"%d월", row+1];
			break;
		case 2:
			toRet = [NSString stringWithFormat:@"%d일", row+1];
			break;
		default:
			break;
	}
	return toRet;
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//	
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	MY_LOG(@"didSelectRow: %d inComponent: %d", row, component);
	if (component == 1) {
		[pickerView reloadComponent:2];
	}
	
}
#pragma mark -
#pragma mark pickerView data source

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView 
{
	return 3; // 양음력, 월, 일
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	int rows = 0;
	switch (component) {
		case 0:
			rows = 2;
			break;
		case 1:
			rows = 12;
			break;
		case 2:
			switch ([birthdayPickerView selectedRowInComponent:1]+1) {
				case 1:
				case 3:
				case 5:
				case 7:
				case 8:
				case 10:
				case 12:
					rows = 31;
					break;
				case 2:
					rows = 29;
					break;
				default:
					rows = 30;
					break;
			}
			break;
		default:
			break;
	}
	return rows;
}

#pragma mark -
#pragma mark ImInProtocol delegate
- (void) apiDidLoad:(NSDictionary *)result 
{

	if ([[result objectForKey:@"func"] isEqualToString:@"profileUpdate"]) {
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Filled Out Profile" withInfo:nil];
        
		[UserContext sharedUserContext].userProfile = [result objectForKey:@"profileImg"];
        NSArray* badgeList = [result objectForKey:@"data"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdateCompleted" object:self userInfo:result];
        
        realtimeBadge.badgeList = badgeList;
        
        if ([badgeList count] > 0) {
            [realtimeBadge downloadImageWithArray:badgeList];
        } else {
            [self.navigationController popViewControllerAnimated:YES];            
        }
	}	
}

- (void) apiFailed
{
	
}

- (void) badgeDownloadCompleted
{
    [[ApplicationContext sharedApplicationContext] badgeAcquisitionViewShow:realtimeBadge.badgeList];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark 이미지 소스 선택
/**
 @brief 이미지 소스 선택
 @return void
 */
- (void) presentSelectionSheet {
	
	UIActionSheet* selectionSheet = nil;
	if ([UIImagePickerController isSourceTypeAvailable:
		 UIImagePickerControllerSourceTypeCamera]) {
		selectionSheet = [[[UIActionSheet alloc]
						  initWithTitle:nil 
						  delegate:self 
						  cancelButtonTitle:@"취소" 
						  destructiveButtonTitle:nil
						  otherButtonTitles:@"사진찍기", @"앨범에서 가져오기", nil] autorelease];
		
	} else {
		selectionSheet = [[[UIActionSheet alloc]
						  initWithTitle:nil 
						  delegate:self 
						  cancelButtonTitle:@"취소" 
						  destructiveButtonTitle:nil
						  otherButtonTitles:@"앨범에서 가져오기", nil] autorelease];
	}
	
	[selectionSheet showInView:self.view.window];
}

/**
 @brief 프로필 사진 관리에서 사진가져오는 버튼 클릭
 @return void
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	if ([UIImagePickerController isSourceTypeAvailable:
		 UIImagePickerControllerSourceTypeCamera]) {
		if (buttonIndex == 0) { //사진찍기
			[self getCameraPicture:UIImagePickerControllerSourceTypeCamera];
		}  else if (buttonIndex == 1) { //포토 라이브러리에서 불러오기
			[self selectExistingPicture];
		}
	} else {
		if (buttonIndex == 0) {
			[self selectExistingPicture];	
		}
	}
}

/**
 @brief 프로필 사진 업로드 시 하단 프로그래스 view
 @return void
 */
- (void) presentSheet
{
	
	self.baseSheet = [[[UIActionSheet alloc] 
				 initWithTitle:@"잠시만 기다려 주세요"
				 delegate:self 
				 cancelButtonTitle:nil
				 destructiveButtonTitle: nil
					  otherButtonTitles: nil] autorelease];

	baseSheet.title = @"사진을 업로드중입니다.";
	
	UIProgressView *progbar = [[[UIProgressView alloc] initWithFrame:CGRectMake(50.0f, 30.0f, 220.0f, 20.0f)] autorelease];	
	progbar.tag = PROGRESS_BAR;
	[progbar setProgressViewStyle: UIProgressViewStyleDefault];
	[progbar setProgress:0];
	
	[baseSheet addSubview:progbar];
	[baseSheet showInView:self.view];
}

#pragma mark -
#pragma mark 파일 업로드
/**
 @brief 파일 업로드
 @return void
 */
- (void) onUploadDone:(ASIFormDataRequest *)request
{
	MY_LOG(@"UploadSuccess");
	[baseSheet dismissWithClickedButtonIndex:0 animated:YES];
	
	NSDictionary* results = [request.responseString objectFromJSONString];
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	if ([resultNumber intValue] == 0) { //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
		return;
	}
	self.tmpProfileImageURL = [NSString stringWithFormat:@"%@%@", TMP_IMG_PREFIX, [results objectForKey:@"imgUrl"]];
	//MY_LOG(@"self.tmpProfileImageURL = %@", self.tmpProfileImageURL);
	//[CommonAlert alertWithTitle:@"알림" message:self.tmpProfileImageURL];
	[profileImageView setImageWithURL:[NSURL URLWithString:tmpProfileImageURL]
					 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
	
}

- (void) onUploadError:(ASIFormDataRequest *)request
{
	MY_LOG(@"Error~~~");
	if(upload != nil)
	{
		[upload release];
		upload = nil;
	}
	[baseSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) onProgress:(Uploader*)up
{
	NSString* logFileTrans = [[NSString alloc] initWithFormat:@"Transfer : %d/%d", [up getTransFileByte],[up getTransTotalFileByte]];
	MY_LOG(@"%@", logFileTrans);
	[logFileTrans release];
	
	//amountDone += 1.0f;
	UIProgressView *progbar = (UIProgressView *)[baseSheet viewWithTag:PROGRESS_BAR];
	float progressPercent = (float)[up getTransFileByte] / (float)[up getTransTotalFileByte];
	MY_LOG(@"ProgressPercent : %f",progressPercent);
    [progbar setProgress: progressPercent];	
}

#pragma mark -
#pragma mark Camera control
/**
 @brief 프로필 사진 등록시 '사진찍기'
 @return IBAction
 */
- (IBAction) getCameraPicture:(UIImagePickerControllerSourceType)sourceType {
	if (![UIImagePickerController isSourceTypeAvailable:
		  UIImagePickerControllerSourceTypeCamera]) {
		[CommonAlert alertWithTitle:@"알림" message:@"본 장치에서는 카메라를 지원하지 않습니다."];
		return;
	}
	
	UIImagePickerController* picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = YES;
	picker.sourceType = sourceType;
	[[ViewControllers sharedViewControllers].settingViewController presentModalViewController:picker animated:YES];
	[picker release];
}

/**
 @brief 프로필 사진 등록시 '앨범에서 가져오기' 선택시
 @return IBAction
 */
- (IBAction)selectExistingPicture {
	if ([UIImagePickerController isSourceTypeAvailable:
		 UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController* picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.allowsEditing = YES;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[[ViewControllers sharedViewControllers].settingViewController presentModalViewController:picker animated:YES];
		[picker release];
	} else {
		UIAlertView* alert = [[UIAlertView alloc]
							  initWithTitle:@"사진 앨범 접근시 에러발생"
							  message:@"본 장치는 사진 앨범을 지원하지 않습니다."
							  delegate:nil
							  cancelButtonTitle:@"확인"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


#pragma mark -
#pragma mark 이미지 Picker에서 선택했을 때
/**
 @brief 프로필 사진 등록시 '저장된 사진앨범에서'를 선택했을때
 @return IBAction
 */
- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	// 카메라 쪽 버그로 보여지는 view를 날려버리는 현상에 대한 대처 방법으로 메인 프라자 뷰를 갱신하도록 함.
//	UIPlazaViewController* plaza = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
//	plaza.needToUpdate = YES;
	
	
	if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *) kUTTypeMovie]) {
		[CommonAlert alertWithTitle:@"안내" message:@"동영상 파일을 업로드 하실 수 없습니다."];
		[picker dismissModalViewControllerAnimated:YES];
		return;
	}
	UIImage* imageToReturn = nil;
	
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera ||
		picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum || 
		picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
		imageToReturn = [info objectForKey:UIImagePickerControllerEditedImage];
	} else {
		imageToReturn = [info objectForKey:UIImagePickerControllerOriginalImage];
	}
	
	//retrive home directory path
	NSArray *userDomainPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [userDomainPaths objectAtIndex:0];
	NSString *imagePath = [documentsDirectoryPath stringByAppendingPathComponent:@"imageToUpload.png"];
	
	//save image
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(imageToReturn)];
	[imageData writeToFile:imagePath atomically:YES];
	
	// 여기서 이미지를 업로딩 한다.
	[self presentSheet];
	NSArray *keys = [NSArray arrayWithObjects:@"svcId", @"at", @"av", @"ts", @"s", @"device", nil];
	NSArray *objects = [NSArray arrayWithObjects:SNS_IPHONE_SVCID, @"1", [UserContext sharedUserContext].snsID, 
						[Utils ts], [Utils sWithAv:[UserContext sharedUserContext].snsID], SNS_DEVICE_MOBILE_APP, nil];
	NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	if(upload != nil)
	{
		[upload release];
		upload = nil;
	}
	UIProgressView *progbar = (UIProgressView *)[baseSheet viewWithTag:PROGRESS_BAR];
	upload = [[Uploader alloc] initWithURL:[NSURL URLWithString:PROTOCOL_TMP_IMG_UPLOAD] 
								  filePath:imagePath
								  delegate:self
							  doneSelector:@selector(onUploadDone:)
							 errorSelector:@selector(onUploadError:)
                              progressView:progbar
								parameters:params];

	[picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}



@end
