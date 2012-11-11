//
//  ResultController.m
//  KidsIQ5
//
//  Created by Chan Komagan on 7/28/12.
//  Copyright (c) 2012 KidsIQ. All rights reserved.
//

#import "ResultController.h"
#import "KidsIQ6ViewController.h"
#import "NameViewController.h"
#import "LeaderBoardController.h"
#import "ASIFormDataRequest.h"
#import "SLViewController.h"

@interface ResultController()
@property (nonatomic, strong) NSString *nsURL;
@end

@implementation ResultController
@synthesize name, titleText, score, country, paidFlag, maxQuestions, nsURL, responseData, fCount, mCount, sCount, fTCount, mTCount, sTCount;
@synthesize player = _player;
bool reset = NO;
NSString *paid = @"N";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [_player stop];
    nameLabel.text =  [@"Hi there, " stringByAppendingString:[name stringByAppendingString:@""]];
    titleLabel.text = titleText;
    scoreLabel.text = [@"Your score is: " stringByAppendingString:score];
    [self sendRequest];
    [super viewDidLoad];
}

- (void)sendRequest
{
    nsURL = @"http://www.komagan.com/KidsIQ/leaders.php?format=json&adduser2=1";
    self.responseData = [NSMutableData data];
    if (paidFlag) {paid = @"Y";}
    NSURL *url = [NSURL URLWithString:nsURL];
    NSLog(@"%@", name);
    NSLog(@"%@", score);
    NSLog(@"Paid user or no? %@", paid);

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:name forKey:@"name"];
    [request setPostValue:score forKey:@"score"];
    [request setPostValue:country forKey:@"country"];
    [request setPostValue:paid forKey:@"paid"];
    [request setPostValue:[NSNumber numberWithInt:fCount] forKey:@"fCount"];
    [request setPostValue:[NSNumber numberWithInt:fTCount] forKey:@"fTCount"];
    [request setPostValue:[NSNumber numberWithInt:mCount] forKey:@"mCount"];
    [request setPostValue:[NSNumber numberWithInt:mTCount] forKey:@"mTCount"];
    [request setPostValue:[NSNumber numberWithInt:sCount] forKey:@"sCount"];
    [request setPostValue:[NSNumber numberWithInt:sTCount] forKey:@"sTCount"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Request failed: %@",[request error]);
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"Submitted form successfully");
    NSLog(@"Response was:");
    NSLog(@"%@",[request responseString]);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)loginScreen {
    
    NameViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]  instantiateViewControllerWithIdentifier:@"NameViewController"];
    vc.maxQuestions = 0;
    [self presentModalViewController:vc animated:false];
    
}

-(IBAction)leaderBoardScreen {
    
    LeaderBoardController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]  instantiateViewControllerWithIdentifier:@"LeaderBoardController"];
    [self presentModalViewController:vc animated:false];
}

-(IBAction)FBScreen {
    SLViewController *fbView = [[SLViewController alloc] initWithNibName:@"SLViewController" bundle:nil];
    fbView.nameText = name;
    fbView.scoreText = score;
    [self presentModalViewController:fbView animated:false];
}

-(IBAction)dismissView {
    
    KidsIQ6ViewController *quiView = [[KidsIQ6ViewController alloc] initWithNibName:@"KidsIQ6ViewController" bundle:nil];
    [self dismissModalViewControllerAnimated:YES];
    quiView.maxQuestions = maxQuestions;
    [self presentModalViewController:quiView animated:false];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation != UIDeviceOrientationLandscapeLeft) &&
	(orientation != UIDeviceOrientationLandscapeRight);
}

@end
