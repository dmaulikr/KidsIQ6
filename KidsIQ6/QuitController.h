//
//  QuitController.h
//  KidsIQ5
//
//  Created by Chan Komagan on 8/20/12.
//  Copyright (c) 2012 KidsIQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioToolbox.h"
#import "AVFoundation/AVFoundation.h"

@interface QuitController : UIViewController {
    IBOutlet UIButton *dismissYes;
    IBOutlet UIButton *dismissNo;
}

@property (nonatomic, retain) NSTimer *mainTimer;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *country;
@property (strong, nonatomic) AVAudioPlayer *player;

-(IBAction)dismissView;
-(IBAction)loginScreen;

@end
