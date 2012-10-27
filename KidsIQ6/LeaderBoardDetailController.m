//
//  LeaderBoardDetailController.m
//  KidsIQ5
//
//  Created by Chan Komagan on 10/15/12.
//  Copyright (c) 2012 Chan Komagan. All rights reserved.
//

#import "LeaderBoardDetailController.h"

@interface LeaderBoardDetailController ()

@end

@implementation LeaderBoardDetailController

@synthesize name, country, scoreDetail, fCount, mCount, sCount, fTCount, mTCount, sTCount;
NSString *flagUrl = @"http://www.komagan.com/KidsIQ/flags/";
NSString *format = @".gif";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //NSLog(@"score %i", fTCount);
    NSLog(@"fcount %f", (float)fCount/fTCount);
    scoreLabel.text = scoreDetail;
    fCountLabel.text = [[[NSString stringWithFormat:@"%d",fCount] stringByAppendingString:@" of " ] stringByAppendingString:[NSString stringWithFormat:@"%d",fTCount]];
    mCountLabel.text = [[[NSString stringWithFormat:@"%d",mCount] stringByAppendingString:@" of " ] stringByAppendingString:[NSString stringWithFormat:@"%d",mTCount]];
    sCountLabel.text = [[[NSString stringWithFormat:@"%d",sCount] stringByAppendingString:@" of " ] stringByAppendingString:[NSString stringWithFormat:@"%d",sTCount]];
    fCountView.progress = (float)fCount/fTCount;
    mCountView.progress = (float)mCount/mTCount;
    sCountView.progress = (float)sCount/sTCount;
    
    nameLabel.text = name;
    
    id path = [self getFlags:country];
    NSURL *url = [NSURL URLWithString:path];
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:imgData];
    [imageView setImage:image];
}

- (NSString*)getFlags:(NSString*)countryname
{
    countryname = [countryname stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    id path =  [flagUrl stringByAppendingFormat:countryname];
    path = [path stringByAppendingString:format];
    return path;
}

-(IBAction)dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
