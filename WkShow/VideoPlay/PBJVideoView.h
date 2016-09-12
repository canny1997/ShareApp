

#import <UIKit/UIKit.h>

// PBJVideoPlayerController provides this class via viewController.view, no need to allocate directly

@class AVPlayer;
@class AVPlayerLayer;
@interface PBJVideoView : UIView

@property (nonatomic, assign) AVPlayer *player;
@property (nonatomic, readonly, assign) AVPlayerLayer *playerLayer;

// defaults to AVLayerVideoGravityResizeAspect
@property (nonatomic, readwrite, copy) NSString *videoFillMode;

@end
