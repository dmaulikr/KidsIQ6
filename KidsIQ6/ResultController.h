//
//  ResultController.h
//  KidsIQ5
//
//  Created by Chan Komagan on 7/28/12.
//  Copyright (c) 2012 KidsIQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ResultController : UIViewController <NSURLConnectionDelegate>
{
    IBOutlet UILabel *responseText;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *scoreLabel;
    IBOutlet UIButton *startoverBtn;
    IBOutlet UIButton *publishButton;
    NSMutableData *responseData;
	UIButton *_logoutButton;
	NSString *_facebookName;
	BOOL _posting;
}

@property (nonatomic, strong) NSString *name, *titleText, *score, *country;
@property Boolean paidFlag;

@property int maxQuestions, fCount, fTCount, mCount, mTCount, sCount, sTCount;
@property (nonatomic, retain) NSMutableData *responseData;

-(IBAction)dismissView;
-(IBAction)loginScreen;
-(IBAction)leaderBoardScreen;
-(IBAction)FBScreen;

@end
