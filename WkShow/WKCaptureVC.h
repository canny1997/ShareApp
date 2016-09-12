//
//  WKCaptureVC.h
//  WkShow
//
//  Created by TOPTEAM on 16/8/23.
//  Copyright © 2016年 TOPTEAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CaptureDefine.h"
#import "CameraRecorder.h"
@interface WKCaptureVC : UIViewController<CameraRecorderDelegate, UIAlertViewDelegate>
{
    
}

@property (copy, nonatomic) GenericCallback callback;
@end
