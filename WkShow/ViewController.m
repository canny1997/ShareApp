//
//  ViewController.m
//  WkShow
//
//  Created by TOPTEAM on 16/7/27.
//  Copyright © 2016年 TOPTEAM. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "DBPrivateHelperController.h"
#import "PBJVideoPlayerController.h"
#import "UIAlertView+Blocks.h"
#import "SAVideoRangeSlider.h"
#import <StoreKit/StoreKit.h>
#import "BTSimpleSideMenu.h"
#import "NSString+Height.h"
#import "ViewController.h"
#import "ZHActionSheet.h"
#import "JGActionSheet.h"
#import "ExportEffects.h"
#import "CMPopTipView.h"
#import "StickerView.h"
#import "WKCaptureVC.h"
#import "KGModal.h"
#define MaxVideoLength MAX_VIDEO_DUR
#define DemoVideoName @"Demo.mp4"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, PBJVideoPlayerControllerDelegate, SKStoreProductViewControllerDelegate, SAVideoRangeSliderDelegate, BTSimpleSideMenuDelegate,ZHActionSheetDelegate>
{
    CMPopTipView *_popTipView;
}

#pragma mark ==================================UI=======================================
@property (nonatomic, strong) UIView             *demoVideoContentView;
@property (nonatomic, strong) UIImageView        *demoPlayButton;
@property (nonatomic, strong) UIView             *view_capture;
@property (nonatomic, strong) UIButton           *btn_video;
@property (nonatomic, strong) UIScrollView       *videoContentView;
@property (nonatomic, strong) UIImageView        *playButton;
@property (nonatomic, strong) UIButton           *closeVideoPlayerButton;
@property (nonatomic, strong) UIView             *view_background;//背景
@property (nonatomic, strong) UIButton           *btn_show_demo;
@property (nonatomic, strong) UILabel            *videoRangeLabel;
@property (nonatomic, strong) SAVideoRangeSlider *videoRangeSlider;
@property (nonatomic, strong) BTSimpleSideMenu   *sideMenu;

#pragma mark =================================Data======================================
@property (nonatomic,   copy) NSURL              *url_videoPick;
@property (nonatomic,   copy) NSString           *audioPickFile;
@property (nonatomic, strong) NSMutableArray     *marr_gif;

#pragma mark =================================Other=====================================
@property (nonatomic, strong) PBJVideoPlayerController *demoVideoPlayerController;
@property (nonatomic, strong) PBJVideoPlayerController *videoPlayerController;
@property (nonatomic)         CFTimeInterval            startTime;

@end

@implementation ViewController

#pragma mark - Authorization Helper
- (void)popupAlertView{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:GBLocalizedString(@"Private_Setting_Audio_Tips") delegate:nil cancelButtonTitle:GBLocalizedString(@"IKnow") otherButtonTitles:nil, nil];
    //"Private_Setting_Audio_Tips" = "软件正常工作时，需要使用手机的麦克风权限，请打开权限，通过系统'设置' -> '隐私' -> '麦克风'. "
    //"IKnow" = "我知道了"
    [alertView show];
}

- (void)popupAuthorizationHelper:(id)type
{
    DBPrivateHelperController *privateHelper = [DBPrivateHelperController helperForType:[type longValue]];
    privateHelper.snapshot = [self snapshot];
    privateHelper.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:privateHelper animated:YES completion:nil];
}

- (UIImage *)snapshot
{
    id <UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    UIGraphicsBeginImageContextWithOptions(appDelegate.window.bounds.size, NO, appDelegate.window.screen.scale);
    [appDelegate.window drawViewHierarchyInRect:appDelegate.window.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

#pragma mark - File Helper
- (AVURLAsset *)getURLAsset:(NSString *)filePath{
    
    NSURL *videoURL = getFileURL(filePath);
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    
    return asset;
}

#pragma mark - Delete Temp Files
- (void)deleteTempDirectory{
    
    NSString *dir = NSTemporaryDirectory();
    deleteFilesAt(dir, @"mov");
}

- (void)showCustomActionSheetByNav:(UIBarButtonItem *)barButtonItem withEvent:(UIEvent *)event{
    
    UIView *anchor = [event.allTouches.anyObject view];
    [self action_showCustomActionSheetByView:anchor];
}

#pragma mark - SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition{
    
    self.startTime = leftPosition;
    if (self.startTime < 0.5)
    {
        self.startTime = 0.5f;
    }
}

#pragma mark - PBJVideoPlayerControllerDelegate
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer{
    //NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer{
    
}


- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer{
    
    if (videoPlayer == _videoPlayerController)
    {
        _playButton.alpha = 1.0f;
        _playButton.hidden = NO;
        
        [UIView animateWithDuration:0.1f animations:^{
            _playButton.alpha = 0.0f;
        } completion:^(BOOL finished)
         {
             _playButton.hidden = YES;
         }];
    }
    else if (videoPlayer == _demoVideoPlayerController)
    {
        _demoPlayButton.alpha = 1.0f;
        _demoPlayButton.hidden = NO;
        
        [UIView animateWithDuration:0.1f animations:^{
            _demoPlayButton.alpha = 0.0f;
        } completion:^(BOOL finished)
         {
             _demoPlayButton.hidden = YES;
         }];
    }
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    if (videoPlayer == _videoPlayerController)
    {
        _playButton.hidden = NO;
        
        [UIView animateWithDuration:0.1f animations:^{
            _playButton.alpha = 1.0f;
        } completion:^(BOOL finished)
         {
             
         }];
    }
    else if (videoPlayer == _demoVideoPlayerController)
    {
        _demoPlayButton.hidden = NO;
        
        [UIView animateWithDuration:0.1f animations:^{
            _demoPlayButton.alpha = 1.0f;
        } completion:^(BOOL finished)
         {
             
         }];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 1.
    [self dismissViewControllerAnimated:NO completion:nil];
    
    NSLog(@"info = %@",info);
    
    // 2.
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"])
    {
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        [self setPickedVideo:url];
    }
    else
    {
        NSLog(@"Error media type");
        return;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)setPickedVideo:(NSURL *)url
{
    [self setPickedVideo:url checkVideoLength:YES];
}

- (void)setPickedVideo:(NSURL *)url checkVideoLength:(BOOL)checkVideoLength
{
    if (!url || (url && ![url isFileURL]))
    {
        NSLog(@"Input video url is invalid.");
        return;
    }
    
    if (checkVideoLength)
    {
        if (getVideoDuration(url) > MaxVideoLength)
        {
            NSString *ok = GBLocalizedString(@"OK");
            NSString *error = GBLocalizedString(@"Error");
            NSString *fileLenHint = GBLocalizedString(@"FileLenHint");
            NSString *seconds = GBLocalizedString(@"Seconds");
            NSString *hint = [fileLenHint stringByAppendingFormat:@" %.0f ", MaxVideoLength];
            hint = [hint stringByAppendingString:seconds];
            UIAlertView* alert = [[UIAlertView alloc]
                                                          initWithTitle:error
                                                                message:hint
                                                               delegate:nil
                                                      cancelButtonTitle:ok
                                                      otherButtonTitles: nil];
            [alert show];
            
            return;
        }
    }
    
    _url_videoPick = url;
    NSLog(@"Pick background video is success: %@", _url_videoPick);
    
    [self reCalcVideoSize:[url relativePath]];
    
    // Setting
    [self defaultVideoSetting:url];
    
    // Hint to next step
    if ([self getAppRunCount] < 6 && [self getNextStepRunCondition])
    {
        if (_popTipView)
        {
            NSString *hint = GBLocalizedString(@"UsageNextHint");
            _popTipView.message = hint;
            [_popTipView autoDismissAnimated:YES atTimeInterval:5.0];
            [_popTipView presentPointingAtBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
        }
    }
}

#pragma mark - 选择相册
- (void)pickBackgroundVideoFromPhotosAlbum
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // Only movie
        NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        picker.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 点击拍照
- (void)pickBackgroundVideoFromCamera
{
    WKCaptureVC *captureVC = [[WKCaptureVC alloc] init];
    [captureVC setCallback:^(BOOL success, id result)
     {
         if (success)
         {
             NSURL *fileURL = result;
             [self setPickedVideo:fileURL checkVideoLength:NO];
         }
         else
         {
             NSLog(@"Video Picker Failed: %@", result);
         }
     }];
    
    [self presentViewController:captureVC animated:YES completion:^{
        NSLog(@"PickVideo present");
    }];
}

#pragma mark - BTSimpleSideMenuDelegate
-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"Item Cliecked : %ld", (long)index);
    
    NSInteger styleIndex = index+1;
    [self initEmbededGifView:styleIndex];
    
    if (styleIndex != NSNotFound)
    {
        NSString *musicFile = [NSString stringWithFormat:@"Theme_%lu.m4a", (long)styleIndex];
        _audioPickFile = musicFile;
    }
    else
    {
        _audioPickFile = nil;
    }
    
    // Hint to next step
    if ([self getAppRunCount] < 6 && [self getNextStepRunCondition])
    {
        if (_popTipView)
        {
            NSString *hint = GBLocalizedString(@"UsageNextHint");
            _popTipView.message = hint;
            [_popTipView autoDismissAnimated:YES atTimeInterval:5.0];
            [_popTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        }
    }
}

- (void)initEmbededGifView:(NSInteger)styleIndex
{
    // Only 1 embeds gif is supported now
    [self clearEmbeddedGifArray];
    
    NSString *imageName = [NSString stringWithFormat:@"Theme_%lu.gif", (long)styleIndex];
    StickerView *view = [[StickerView alloc] initWithFilePath:getFilePath(imageName)];
    CGFloat ratio = MIN( self.videoContentView.width / view.width, self.videoContentView.height / view.height);
    [view setScale:ratio];
    view.center = CGPointMake(self.videoContentView.width/2, self.videoContentView.height/2);
    [_videoContentView addSubview:view];
    
    [StickerView setActiveStickerView:view];
    
    if (!_marr_gif)
    {
        _marr_gif = [NSMutableArray arrayWithCapacity:1];
    }
    [_marr_gif addObject:view];
    
    [view setDeleteFinishBlock:^(BOOL success, id result) {
        if (success)
        {
            if (_marr_gif && [_marr_gif count] > 0)
            {
                if ([_marr_gif containsObject:result])
                {
                    [_marr_gif removeObject:result];
                }
            }
        }
    }];
    
    [[ExportEffects sharedInstance] setGifArray:_marr_gif];
}

-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu selectedItemTitle:(NSString *)title
{
    NSLog(@"Menu Clicked, Item Title : %@", title);
}

#pragma mark - getNextStepCondition
- (BOOL)getNextStepRunCondition
{
    BOOL result = TRUE;
    if (!_url_videoPick)
    {
        result = FALSE;
    }
    
    return result;
}

#pragma mark - Default Setting
- (void)defaultVideoSetting:(NSURL *)url
{
    [self showVideoPlayView:YES];
    
    [self playDemoVideo:[url absoluteString] withinVideoPlayerController:_videoPlayerController];
}

#pragma mark - playDemoVideo
- (void)playDemoVideo:(NSString*)inputVideoPath withinVideoPlayerController:(PBJVideoPlayerController*)videoPlayerController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        videoPlayerController.videoPath = inputVideoPath;
        [videoPlayerController playFromBeginning];
    });
}

#pragma mark - StopAllVideo
- (void)stopAllVideo
{
    if (_videoPlayerController.playbackState == PBJVideoPlayerPlaybackStatePlaying)
    {
        [_videoPlayerController stop];
    }
}



#pragma mark - reCalc on the basis of video size & view size
- (void)adjustVideoRangeSlider:(BOOL)referVideoContentView
{
    CGFloat gap = 5;
    CGRect referRect = _videoContentView.frame;
    if (!referVideoContentView)
    {
        referRect = _view_capture.frame;
    }
    _videoRangeLabel.frame = CGRectMake(CGRectGetMinX(_videoRangeLabel.frame), CGRectGetMinY(referRect) - gap - CGRectGetHeight(_videoRangeLabel.frame), CGRectGetWidth(_videoRangeLabel.frame), CGRectGetHeight(_videoRangeLabel.frame));
    _videoRangeSlider.frame = CGRectMake(CGRectGetMaxX(_videoRangeLabel.frame) + gap, CGRectGetMinY(_videoRangeLabel.frame), CGRectGetWidth(_videoRangeSlider.frame), CGRectGetHeight(_videoRangeSlider.frame));
}

- (void)reCalcVideoSize:(NSString *)videoPath
{
    CGFloat statusBarHeight = iOS7AddStatusHeight;
    CGFloat navHeight = 0; //CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGSize sizeVideo = [self reCalcVideoViewSize:videoPath];
    _videoContentView.frame =  CGRectMake(CGRectGetMidX(self.view.frame) - sizeVideo.width/2, CGRectGetMidY(self.view.frame) - sizeVideo.height/2 + statusBarHeight + navHeight, sizeVideo.width, sizeVideo.height);
    _videoPlayerController.view.frame = _videoContentView.bounds;
    _playButton.center = _videoPlayerController.view.center;
    _closeVideoPlayerButton.center = _videoContentView.frame.origin;
    
    if (_url_videoPick)
    {
        [self createVideoRangeSlider:_url_videoPick];
        [self adjustVideoRangeSlider:YES];
        
        [self.view bringSubviewToFront:_sideMenu];
        [_sideMenu show];
    }
}

- (CGSize)reCalcVideoViewSize:(NSString *)videoPath
{
    CGSize resultSize = CGSizeZero;
    if (isStringEmpty(videoPath))
    {
        return resultSize;
    }
    
    UIImage *videoFrame = getImageFromVideoFrame(getFileURL(videoPath), kCMTimeZero);
    if (!videoFrame || videoFrame.size.height < 1 || videoFrame.size.width < 1)
    {
        return resultSize;
    }
    
    NSLog(@"reCalcVideoViewSize: %@, width: %f, height: %f", videoPath, videoFrame.size.width, videoFrame.size.height);
    
    CGFloat statusBarHeight = 0; //iOS7AddStatusHeight;
    CGFloat navHeight = 0; //CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGFloat gap = 15;
    CGFloat height = CGRectGetHeight(self.view.frame) - navHeight - statusBarHeight - 2*gap;
    CGFloat width = CGRectGetWidth(self.view.frame) - 2*gap;
    if (height < width)
    {
        width = height;
    }
    else if (height > width)
    {
        height = width;
    }
    CGFloat videoHeight = videoFrame.size.height, videoWidth = videoFrame.size.width;
    CGFloat scaleRatio = videoHeight/videoWidth;
    CGFloat resultHeight = 0, resultWidth = 0;
    if (videoHeight <= height && videoWidth <= width)
    {
        resultHeight = videoHeight;
        resultWidth = videoWidth;
    }
    else if (videoHeight <= height && videoWidth > width)
    {
        resultWidth = width;
        resultHeight = height*scaleRatio;
    }
    else if (videoHeight > height && videoWidth <= width)
    {
        resultHeight = height;
        resultWidth = width/scaleRatio;
    }
    else
    {
        if (videoHeight < videoWidth)
        {
            resultWidth = width;
            resultHeight = height*scaleRatio;
        }
        else if (videoHeight == videoWidth)
        {
            resultWidth = width;
            resultHeight = height;
        }
        else
        {
            resultHeight = height;
            resultWidth = width/scaleRatio;
        }
    }
    
    resultSize = CGSizeMake(resultWidth, resultHeight);
    return resultSize;
}

#pragma mark - getOutputFilePath
- (NSString*)getOutputFilePath
{
    NSString* mp4OutputFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"outputMovie.mov"];
    return mp4OutputFile;
}

#pragma mark - Progress callback
- (void)retrievingProgress:(id)progress title:(NSString *)text
{
    if (progress && [progress isKindOfClass:[NSNumber class]])
    {
        NSString *title = text ?text :GBLocalizedString(@"SavingVideo");
        NSString *currentPrecentage = [NSString stringWithFormat:@"%d%%", (int)([progress floatValue] * 100)];
        ProgressBarUpdateLoading(title, currentPrecentage);
    }
}

#pragma mark AppStore Open
- (void)showAppInAppStore:(NSString *)appId
{
    Class isAllow = NSClassFromString(@"SKStoreProductViewController");
    if (isAllow)
    {
        // > iOS6.0
        SKStoreProductViewController *sKStoreProductViewController = [[SKStoreProductViewController alloc] init];
        sKStoreProductViewController.delegate = self;
        [self presentViewController:sKStoreProductViewController
                           animated:YES
                         completion:nil];
        [sKStoreProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: appId}completionBlock:^(BOOL result, NSError *error)
         {
             if (error)
             {
                 NSLog(@"%@",error);
             }
             
         }];
    }
    else
    {
        // < iOS6.0
        NSString *appUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8", appId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrl]];
        
        //        UIWebView *callWebview = [[UIWebView alloc] init];
        //        NSURL *appURL =[NSURL URLWithString:appStore];
        //        [callWebview loadRequest:[NSURLRequest requestWithURL:appURL]];
        //        [self.view addSubview:callWebview];
    }
}




#pragma mark - SKStoreProductViewControllerDelegate
// Dismiss contorller
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSUserDefaults
#pragma mark - AppRunCount
- (void)addAppRunCount
{
    NSUInteger appRunCount = [self getAppRunCount];
    NSInteger limitCount = 6;
    if (appRunCount < limitCount)
    {
        ++appRunCount;
        NSString *appRunCountKey = @"AppRunCount";
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        [userDefaultes setInteger:appRunCount forKey:appRunCountKey];
        [userDefaultes synchronize];
    }
}

- (NSUInteger)getAppRunCount
{
    NSUInteger appRunCount = 0;
    NSString *appRunCountKey = @"AppRunCount";
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if ([userDefaultes integerForKey:appRunCountKey])
    {
        appRunCount = [userDefaultes integerForKey:appRunCountKey];
    }
    
    NSLog(@"getAppRunCount: %lu", (unsigned long)appRunCount);
    return appRunCount;
}


- (void)createVideoRangeSlider:(NSURL *)videoUrl
{
    [self clearVideoRangeSlider];
    
    CGFloat height = 45, width = 160, gap = 10;
    CGFloat fontHeight = 15;
    NSString *text = GBLocalizedString(@"Position");
    CGFloat labelWidth = [text maxWidthForText:text height:fontHeight font:[UIFont systemFontOfSize:fontHeight]];
    
    _videoRangeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(_videoContentView.frame) - (width + gap + labelWidth)/2, CGRectGetMinY(_videoContentView.frame) - gap - height, labelWidth, height)];
    _videoRangeLabel.font = [UIFont systemFontOfSize:fontHeight];
    _videoRangeLabel.text = text;
    [self.view addSubview:_videoRangeLabel];
    
    _videoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_videoRangeLabel.frame) + gap, CGRectGetMinY(_videoRangeLabel.frame), width, height) videoUrl:videoUrl];
    _videoRangeSlider.delegate = self;
    _videoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
    [_videoRangeSlider setPopoverBubbleSize:120 height:60];
    _videoRangeSlider.minGap = 4;
    _videoRangeSlider.maxGap = 4;
    // Purple
    _videoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.768 green: 0.665 blue: 0.853 alpha: 1];
    _videoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.535 green: 0.329 blue: 0.707 alpha: 1];
    [self.view addSubview:_videoRangeSlider];
}


- (void)createNavigationBar
{
    NSString *fontName = GBLocalizedString(@"FontName");
    CGFloat fontSize = 20;
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0 green:0.7 blue:0.8 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                     shadow,
                                                                     NSShadowAttributeName,
                                                                     [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                                                                     nil]];
    
    self.title = GBLocalizedString(@"FunVideoCrop");
}


- (void)createPopTipView
{
    NSArray *colorSchemes = [NSArray arrayWithObjects:
                             [NSArray arrayWithObjects:[NSNull null], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0 blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor darkGrayColor], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
                             nil];
    NSArray *colorScheme = [colorSchemes objectAtIndex:foo4random()*[colorSchemes count]];
    UIColor *backgroundColor = [colorScheme objectAtIndex:0];
    UIColor *textColor = [colorScheme objectAtIndex:1];
    
    NSString *hint = GBLocalizedString(@"UsageHint");
    _popTipView = [[CMPopTipView alloc] initWithMessage:hint];
    if (backgroundColor && ![backgroundColor isEqual:[NSNull null]])
    {
        _popTipView.backgroundColor = backgroundColor;
    }
    if (textColor && ![textColor isEqual:[NSNull null]])
    {
        _popTipView.textColor = textColor;
    }
    
    _popTipView.animation = arc4random() % 2;
    _popTipView.has3DStyle = NO;
    _popTipView.dismissTapAnywhere = YES;
    [_popTipView autoDismissAnimated:YES atTimeInterval:5.0];
    
    [_popTipView presentPointingAtView:_playButton inView:_view_background animated:YES];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
    }
    return self;
}

- (void)dealloc{
    NSLog(@"dealloc");
    [self clearEmbeddedGifArray];
}




#pragma mark - Touchs
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // Deselect
    [StickerView setActiveStickerView:nil];
    [_sideMenu hide];
}











#pragma mark - showDemoVideo
- (void)showDemoVideo:(NSString *)videoPath
{
    CGFloat statusBarHeight = iOS7AddStatusHeight;
    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGSize size = [self reCalcVideoViewSize:videoPath];
    _demoVideoContentView =  [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - size.width/2, CGRectGetMidY(self.view.frame) - size.height/2 - navHeight - statusBarHeight, size.width, size.height)];
    [self.view addSubview:_demoVideoContentView];
    
    // Video player of destination
    _demoVideoPlayerController = [[PBJVideoPlayerController alloc] init];
    _demoVideoPlayerController.view.frame = _demoVideoContentView.bounds;
    _demoVideoPlayerController.view.clipsToBounds = YES;
    _demoVideoPlayerController.videoView.videoFillMode = AVLayerVideoGravityResizeAspect;
    _demoVideoPlayerController.delegate = self;
    //    _demoVideoPlayerController.playbackLoops = YES;
    [_demoVideoContentView addSubview:_demoVideoPlayerController.view];
    
    _demoPlayButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button"]];
    _demoPlayButton.center = _demoVideoPlayerController.view.center;
    [_demoVideoPlayerController.view addSubview:_demoPlayButton];
    
    // Popup modal view
    [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeLeft];
    [[KGModal sharedInstance] showWithContentView:_demoVideoContentView andAnimated:YES];
    
    [self playDemoVideo:videoPath withinVideoPlayerController:_demoVideoPlayerController];
}

#pragma mark ==================================UI=======================================
/**
 *  初始化属性
 */
-(void)setProperty{
    self.view.backgroundColor = [UIColor whiteColor];
    _url_videoPick = nil;
    _marr_gif = nil;
    _startTime = 1.0f;
}

#pragma mark-导航栏上的按钮构建
- (void)createNav{
    
//    self.navigationController.navigationBar.barTintColor=[UIColor cyanColor];
    
    NSString *fontName = GBLocalizedString(@"FontName");
    CGFloat fontSize = 18;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:GBLocalizedString(@"Export") style:UIBarButtonItemStylePlain target:self action:@selector(action_Export)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:GBLocalizedString(@"Theme") style:UIBarButtonItemStylePlain target:self action:@selector(action_ThemeBtn:)];
    [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
}
#pragma mark-createUI
- (void)createUI{
    /**
     *  设置背景
     */
    _view_background = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_view_background];
    UIImageView *ImgV_backgournd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"18.jpg"]];
    ImgV_backgournd.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [_view_background addSubview:ImgV_backgournd];
    
    /**
     *  中间按钮
     */
    [self createContentView];
    
    /**
     *  <#Description#>
     */
    [self createVideoPlayView];
    
    /**
     *  底部栏创建
     */
    [self createBottomBar];
    
    /**
     *  创建左边菜单
     */
    [self createSideMenu];
    
}


#pragma mark - Create 中间按钮
- (void)createContentView{
    
    CGFloat statusBarHeight = 0; //iOS7AddStatusHeight;
    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGFloat gap = 15, len = MIN((CGRectGetHeight(self.view.frame) - navHeight - statusBarHeight - 2*gap), (CGRectGetWidth(self.view.frame) - navHeight - statusBarHeight - 2*gap));
    CGFloat WIDTH = len*0.7;
    
    _view_capture =  [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - WIDTH/2, CGRectGetMidY(self.view.frame) - WIDTH/2-50, WIDTH, WIDTH)];
    [_view_capture setBackgroundColor:[UIColor clearColor]];
    [_view_background addSubview:_view_capture];
    
    _btn_video = [[UIButton alloc] initWithFrame:_view_capture.frame];
    [_view_background addSubview:_btn_video];
    [_btn_video setBackgroundColor:[UIColor clearColor]];
    //设置圆角
    _btn_video.layer.cornerRadius = _btn_video.frame.size.width / 2;
    //将多余的部分切掉
    _btn_video.layer.masksToBounds = YES;
    _btn_video.layer.borderWidth   = 1.0;
    _btn_video.layer.borderColor   = [UIColor whiteColor].CGColor;
    UIImage *addFileImage = [UIImage imageNamed:@"19.jpg"];
    [_btn_video setImage:addFileImage forState:UIControlStateNormal];
    [_btn_video addTarget:self action:@selector(action_showCustomActionSheetByView:) forControlEvents:UIControlEventTouchUpInside];
    
}
#pragma mark -
- (void)createVideoPlayView{
    
    _videoContentView =  [[UIScrollView alloc] initWithFrame:_view_capture.frame];
    [_videoContentView setBackgroundColor:[UIColor clearColor]];
    [_view_background addSubview:_videoContentView];
    
    // Video player
    _videoPlayerController = [[PBJVideoPlayerController alloc] init];
    _videoPlayerController.delegate = self;
    _videoPlayerController.view.frame = _btn_video.bounds;
    _videoPlayerController.view.clipsToBounds = YES;
    
    [self addChildViewController:_videoPlayerController];
    [_videoContentView addSubview:_videoPlayerController.view];
    
    _playButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button"]];
    _playButton.center = _videoPlayerController.view.center;
    [_videoPlayerController.view addSubview:_playButton];
    
    // Close video player
    UIImage *imageClose = [UIImage imageNamed:@"close"];
    CGFloat width = 60;
    _closeVideoPlayerButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(_videoContentView.frame) - width/2, CGRectGetMinY(_videoContentView.frame) - width/2, width, width)];
    _closeVideoPlayerButton.center = _view_capture.frame.origin;
    [_closeVideoPlayerButton setImage:imageClose forState:(UIControlStateNormal)];
    [_closeVideoPlayerButton addTarget:self action:@selector(action_CloseVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_view_background addSubview:_closeVideoPlayerButton];
    
    _closeVideoPlayerButton.hidden = YES;
}
#pragma mark - 创建底部栏
- (void)createBottomBar{
    
    CGFloat statusBarHeight = 0; //iOS7AddStatusHeight;
    CGFloat navHeight = 0; //CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGFloat height = 30;
    /**
     *  底部栏
     */
    UIView  * view_bottom_bar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - height - navHeight - statusBarHeight, CGRectGetWidth(self.view.frame), height)];
    [view_bottom_bar setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:view_bottom_bar];
    
    /**
     *  给底部栏添加按钮
     */
    [self createBottomBarButtons:view_bottom_bar];
    
    /**
     *  示例按钮
     */
    CGFloat width = 60;
    _btn_show_demo = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - width/2, CGRectGetHeight(self.view.frame) - width, width, width)];
    UIImage *image = [UIImage imageNamed:@"demo"];
    [_btn_show_demo setImage:image forState:UIControlStateNormal];
    [_btn_show_demo addTarget:self action:@selector(action_show_Demo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn_show_demo];
}
#pragma mark - 创建底部栏按钮
- (void)createBottomBarButtons:(UIView *)containerView{
    
    // Recommend App
    UIButton *beautyTime = [[UIButton alloc] init];
    [beautyTime setTitle:GBLocalizedString(@"BeautyTime")
                forState:UIControlStateNormal];
    
    UIButton *photoBeautify = [[UIButton alloc] init];
    [photoBeautify setTitle:GBLocalizedString(@"PhotoBeautify")
                   forState:UIControlStateNormal];
    
    [photoBeautify setTag:1];
    [beautyTime setTag:2];
    
    CGFloat gap = 0, height = 30, width = 80;
    CGFloat fontSize = 16;
    NSString *fontName = @"迷你简启体"; // GBLocalizedString(@"FontName");
    photoBeautify.frame =  CGRectMake(gap, gap, width, height);
    [photoBeautify.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    [photoBeautify.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [photoBeautify setTitleColor:kLightBlue forState:UIControlStateNormal];
    [photoBeautify addTarget:self action:@selector(recommendAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    beautyTime.frame =  CGRectMake(CGRectGetWidth(containerView.frame) - width - gap, gap, width, height);
    [beautyTime.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    [beautyTime.titleLabel setTextAlignment:NSTextAlignmentRight];
    [beautyTime setTitleColor:kLightBlue forState:UIControlStateNormal];
    [beautyTime addTarget:self action:@selector(recommendAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:photoBeautify];
    [containerView addSubview:beautyTime];
}
#pragma mark - 创建左边菜单
- (void)createSideMenu
{
    _sideMenu = [[BTSimpleSideMenu alloc]initWithItemTitles:@[GBLocalizedString(@"Lightning"), GBLocalizedString(@"Fart"), GBLocalizedString(@"Fork"), GBLocalizedString(@"Kiss"), GBLocalizedString(@"ShutUp"), GBLocalizedString(@"Dance"), GBLocalizedString(@"Love"), GBLocalizedString(@"SayHi")]
                                              andItemImages:@[
                                                              [UIImage imageNamed:@"Theme_1.gif"],
                                                              [UIImage imageNamed:@"Theme_2.gif"],
                                                              [UIImage imageNamed:@"Theme_3.gif"],
                                                              [UIImage imageNamed:@"Theme_4.gif"],
                                                              [UIImage imageNamed:@"Theme_5.gif"],
                                                              [UIImage imageNamed:@"Theme_6.gif"],
                                                              [UIImage imageNamed:@"Theme_7.gif"],
                                                              [UIImage imageNamed:@"Theme_8.gif"],
                                                              ]
                                        addToViewController:self];
    _sideMenu.delegate = self;
}


#pragma mark =================================Action======================================
#pragma mark-导航栏上的按钮_action_Export
- (void)action_Export
{
    if (![self getNextStepRunCondition])
    {
        NSString *message = nil;
        message = GBLocalizedString(@"VideoIsEmptyHint");
        showAlertMessage(message, nil);
        return;
    }
    [_sideMenu hide];
    [StickerView setActiveStickerView:nil];
    
    if (_marr_gif && [_marr_gif count] > 0)
    {
        for (StickerView *view in _marr_gif)
        {
            [view setVideoContentRect:_videoContentView.frame];
        }
    }
    ProgressBarShowLoading(GBLocalizedString(@"Processing"));
    [[ExportEffects sharedInstance] setExportProgressBlock: ^(NSNumber *percentage) {
        // Export progress
        [self retrievingProgress:percentage title:GBLocalizedString(@"SavingVideo")];
    }];
    
    [[ExportEffects sharedInstance] setFinishVideoBlock: ^(BOOL success, id result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success)
            {
                ProgressBarDismissLoading(GBLocalizedString(@"Success"));
            }
            else
            {
                ProgressBarDismissLoading(GBLocalizedString(@"Failed"));
            }
            
            // Alert
            NSString *ok = GBLocalizedString(@"OK");
            [UIAlertView showWithTitle:nil
                               message:result
                     cancelButtonTitle:ok
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  
                                  if (buttonIndex == [alertView cancelButtonIndex])
                                  {
                                      NSLog(@"Alert Cancelled");
                                      [NSThread sleepForTimeInterval:0.5];
                                      // Demo result video
                                      if (!isStringEmpty([ExportEffects sharedInstance].filenameBlock()))
                                      {
                                          NSString *outputPath = [ExportEffects sharedInstance].filenameBlock();
                                          [self showDemoVideo:outputPath];
                                      }
                                  }
            }];
            
            [self showVideoPlayView:TRUE];
        });
    }];
    
    [[ExportEffects sharedInstance] addEffectToVideo:[_url_videoPick relativePath] withAudioFilePath:getFilePath(_audioPickFile) withAniBeginTime:_startTime];
}

#pragma mark-导航栏上的按钮_action_ThemeBtn
- (void)action_ThemeBtn:(UIBarButtonItem *)sender
{
    if (![self getNextStepRunCondition])
    {
        NSString *message = nil;
        message = GBLocalizedString(@"VideoIsEmptyHint");
        showAlertMessage(message, nil);
        return;
    }
    
    [self.view bringSubviewToFront:_sideMenu];
    [_sideMenu toggleMenu];
}
#pragma mark - 弹出选择框
- (void)action_showCustomActionSheetByView:(UIView *)anchor{
    UIView *locationAnchor = anchor;
    NSString *videoTitle = [NSString stringWithFormat:@"%@", GBLocalizedString(@"SelectVideo")];//选择背景视频
    JGActionSheetSection *sectionVideo = [JGActionSheetSection sectionWithTitle:videoTitle
                                                                        message:nil
                                                                   buttonTitles:@[
                                                                                  GBLocalizedString(@"Camera"),//拍摄
                                                                                  GBLocalizedString(@"PhotoAlbum")//相册
                                                                                  ]
                                                                    buttonStyle:JGActionSheetButtonStyleDefault];
    [sectionVideo setButtonStyle:JGActionSheetButtonStyleBlue forButtonAtIndex:0];
    [sectionVideo setButtonStyle:JGActionSheetButtonStyleBlue forButtonAtIndex:1];
    
    NSArray *sections = (iPad ? @[sectionVideo] : @[sectionVideo, [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[GBLocalizedString(@"Cancel")] buttonStyle:JGActionSheetButtonStyleCancel]]);
    
    JGActionSheet *sheet = [[JGActionSheet alloc] initWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath)
     {
         NSLog(@"indexPath: %ld; section: %ld", (long)indexPath.row, (long)indexPath.section);
         
         if (indexPath.section == 0)
         {
             if (indexPath.row == 0)
             {
                 // Check permission for Video & Audio
                 [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted)
                  {
                      if (!granted)
                      {
                          [self performSelectorOnMainThread:@selector(popupAlertView) withObject:nil waitUntilDone:YES];
                          return;
                      }
                      else
                      {
                          [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
                           {
                               if (!granted)
                               {
                                   [self performSelectorOnMainThread:@selector(popupAuthorizationHelper:) withObject:[NSNumber numberWithLong:DBPrivacyTypeCamera] waitUntilDone:YES];
                                   return;
                               }
                               else
                               {
                                   /**
                                    *  拍照
                                    */
                                   [self performSelectorOnMainThread:@selector(pickBackgroundVideoFromCamera) withObject:nil waitUntilDone:NO];
                               }
                           }];
                      }
                  }];
             }
             else if (indexPath.row == 1)
             {
                 // Check permisstion for photo album
                 ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
                 if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied)
                 {
                     [self performSelectorOnMainThread:@selector(popupAuthorizationHelper:) withObject:[NSNumber numberWithLong:DBPrivacyTypePhoto] waitUntilDone:YES];
                     return;
                 }
                 else
                 {
                     /**
                      *  相册
                      */
                     [self performSelector:@selector(pickBackgroundVideoFromPhotosAlbum) withObject:nil afterDelay:0.1];
                 }
             }
         }
         
         /**
          *  取消
          */
         [sheet dismissAnimated:YES];
     }];
    
    if (iPad)
    {
        [sheet setOutsidePressBlock:^(JGActionSheet *sheet)
         {
             [sheet dismissAnimated:YES];
         }];
        
        CGPoint point = (CGPoint){ CGRectGetMidX(locationAnchor.bounds), CGRectGetMaxY(locationAnchor.bounds) };
        point = [self.navigationController.view convertPoint:point fromView:locationAnchor];
        
        [sheet showFromPoint:point inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionTop animated:YES];
    }
    else
    {
        [sheet setOutsidePressBlock:^(JGActionSheet *sheet)
         {
             [sheet dismissAnimated:YES];
         }];
        
        [sheet showInView:self.navigationController.view animated:YES];
    }
}

#pragma mark -关闭视频
- (void)action_CloseVideo:(UIView *)anchor
{
    [self showVideoPlayView:NO];
    
    [self clearEmbeddedGifArray];
    [self clearVideoRangeSlider];
    
    [_videoPlayerController clearView];
    _url_videoPick = nil;
    
    [self adjustVideoRangeSlider:NO];
}
#pragma mark - Show/Hide
- (void)showVideoPlayView:(BOOL)show
{
    if (show)
    {
        _videoContentView.hidden = NO;
        _closeVideoPlayerButton.hidden = NO;
        
        _btn_video.hidden = YES;
    }
    else
    {
        [self stopAllVideo];
        
        _btn_video.hidden = NO;
        
        _videoContentView.hidden = YES;
        _closeVideoPlayerButton.hidden = YES;
    }
}
#pragma mark - Clear
- (void)clearEmbeddedGifArray
{
    [StickerView setActiveStickerView:nil];
    
    if (_marr_gif && [_marr_gif count] > 0)
    {
        for (StickerView *view in _marr_gif)
        {
            [view removeFromSuperview];
        }
        
        [_marr_gif removeAllObjects];
        _marr_gif = nil;
    }
}
- (void)clearVideoRangeSlider
{
    if (_videoRangeLabel)
    {
        [_videoRangeLabel removeFromSuperview];
        _videoRangeLabel = nil;
    }
    
    if (_videoRangeSlider)
    {
        [_videoRangeSlider removeFromSuperview];
        _videoRangeSlider = nil;
    }
}
#pragma mark -
- (void)action_show_Demo
{
    NSString *demoVideoPath = getFilePath(DemoVideoName);
    [self showDemoVideo:demoVideoPath];
}
#pragma mark -跳转AppStore
- (void)recommendAppButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag)
    {
        case 1:
        {
            // Picture in Picture
            [self showAppInAppStore:@"1006401631"];
            break;
        }
        case 2:
        {
            // BeautyTime
            [self showAppInAppStore:@"1002437952"];
            break;
        }
        default:
            break;
    }
    
    [button setSelected:YES];
}
#pragma mark=================================生命周期======================================
- (void)viewDidLoad{
    [super viewDidLoad];
    /**
     *  初始化属性
     */
    [self setProperty];
    /**
     *  创建导航栏
     */
    [self createNav];
    /**
     *  createUI
     */
    [self createUI];
    
    
    
    NSInteger appRunCount = [self getAppRunCount], maxRunCount = 6;
    if (appRunCount < maxRunCount)
    {
        [self createPopTipView];
    }
    
    [self addAppRunCount];
    
    [self showVideoPlayView:NO];
    
    [self deleteTempDirectory];
    
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self createNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end































