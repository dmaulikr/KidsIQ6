//
//  QuitController.m
//  KidsIQ5
//
//  Created by Chan Komagan on 8/20/12.
//  Copyright (c) 2012 KidsIQ. All rights reserved.
//

#import "QuitController.h"
#import "NameViewController.h"


@interface QuitController()
@end;

@implementation QuitController

@synthesize name, country, mainTimer, player = _player;

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
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(IBAction)dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)loginScreen {
    [self.mainTimer invalidate];
    [_player stop];
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]  instantiateViewControllerWithIdentifier:@"NameViewController"];
    
    [self presentModalViewController:vc animated:false];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation != UIDeviceOrientationLandscapeLeft) &&
	(orientation != UIDeviceOrientationLandscapeRight);
}

@end
