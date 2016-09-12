

#import <UIKit/UIKit.h>
#import "PBJVideoView.h"

typedef NS_ENUM(NSInteger, PBJVideoPlayerPlaybackState)
{
    PBJVideoPlayerPlaybackStateStopped = 0,
    PBJVideoPlayerPlaybackStatePlaying,
    PBJVideoPlayerPlaybackStatePaused,
    PBJVideoPlayerPlaybackStateFailed,
};

typedef NS_ENUM(NSInteger, PBJVideoPlayerBufferingState)
{
    PBJVideoPlayerBufferingStateUnknown = 0,
    PBJVideoPlayerBufferingStateReady,
    PBJVideoPlayerBufferingStateDelayed,
};


@protocol PBJVideoPlayerControllerDelegate;
@interface PBJVideoPlayerController : UIViewController
{
    
}

@property (nonatomic, retain) id<PBJVideoPlayerControllerDelegate> delegate;

@property (nonatomic, retain) PBJVideoView *videoView;

@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic) BOOL playbackLoops;
@property (nonatomic, readonly) NSTimeInterval maxDuration;

@property (nonatomic, readonly) PBJVideoPlayerPlaybackState playbackState;
@property (nonatomic, readonly) PBJVideoPlayerBufferingState bufferingState;

- (void)playFromBeginning;
- (void)playFromCurrentTime;
- (void)pause;
- (void)stop;

- (void)clearView;

@end

@protocol PBJVideoPlayerControllerDelegate <NSObject>
@required
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer;
- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer;

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer;
- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer;

@end
