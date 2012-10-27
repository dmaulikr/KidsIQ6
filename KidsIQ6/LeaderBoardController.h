//
//  LeaderBoardController.h
//  KidsIQ5
//
//  Created by Chan Komagan on 9/21/12.
//  Copyright (c) 2012 Chan Komagan. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface LeaderBoardController : UIViewController <UITableViewDelegate, UITextFieldDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *leaderList;
    IBOutlet UIButton *moreLeaders, *prevLeaders;
    IBOutlet UILabel *bottomLabel;
    
    NSMutableData *responseData;
    NSMutableArray *leaders, *columns, *nameList, *countryList, *scoreList, *fCountList, *fTCountList, *mCountList, *mTCountList, *sCountList, *sTCountList;
    NSMutableArray *copyNameList, *copyCountryList, *copyScoreList, *copyfCountList, *copyfTCountList, *copymCountList, *copymTCountList, *copysCountList, *copysTCountList;
    UITableViewCell *cell, *tvCell;
}

@property (nonatomic, retain) NSMutableData *responseData;

- (void)addColumn:(CGFloat)position;
-(IBAction)dismissView;
-(IBAction)loginScreen;
-(IBAction)showMoreLeaders;
-(IBAction)showPreviousLeaders;

@end
