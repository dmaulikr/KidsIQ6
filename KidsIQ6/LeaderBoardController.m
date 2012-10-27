//
//  LeaderBoardController.m
//  KidsIQ5
//
//  Created by Chan Komagan on 8/20/12.
//  Copyright (c) 2012 KidsIQ. All rights reserved.
//

#import "LeaderBoardController.h"
#import "NameViewController.h"
#import "ASIFormDataRequest.h"
#import "LeaderBoardDetailController.h"

@interface LeaderBoardController()
@property (nonatomic, strong) NSString *nsURL;
@end;

@implementation LeaderBoardController

NSIndexPath *currentSelection;
@synthesize nsURL;
@synthesize responseData;
NSDictionary *res;
NSString *name, *score, *country;
int fCount, mCount, sCount, fTCount, mTCount, sTCount;
NSMutableArray *leaders;
int row, page = 0, totalItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"LeaderBoardController.xib" bundle:nibBundleOrNil];
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
    page = 1;
    totalItems = 0;
    moreLeaders.hidden = TRUE;
    prevLeaders.hidden = TRUE;
    // leaders = [[NSMutableArray alloc] init];
    copyNameList = nameList = [[NSMutableArray alloc] init];
    copyCountryList = countryList = [[NSMutableArray alloc] init];
    copyScoreList = scoreList = [[NSMutableArray alloc] init];
    copyfCountList = fCountList = [[NSMutableArray alloc] init];
    copyfTCountList = fTCountList = [[NSMutableArray alloc] init];
    copymCountList = mCountList = [[NSMutableArray alloc] init];
    copymTCountList = mTCountList = [[NSMutableArray alloc] init];
    copysCountList = sCountList = [[NSMutableArray alloc] init];
    copysTCountList = sTCountList = [[NSMutableArray alloc] init];

    leaderList.scrollEnabled = YES;
    [leaderList setBackgroundColor:UIColor.clearColor]; // Make the table view transparent
    [leaderList setDelegate:self];
    [leaderList setDataSource:self];
    [self receiveData];
}

-(void)receiveData
{
    nsURL = @"http://www.komagan.com/KidsIQ/leaders.php?format=json&getleaders2=1";
    self.responseData = [NSMutableData data];
    NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: nsURL]];
    [[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    NSError *myError = nil;
    res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];

    //[leaderList beginUpdates];
    for(NSDictionary *res1 in res) {
        name = [res1 objectForKey:@"name"];        
        score = [res1 objectForKey:@"score"];
        country = [res1 objectForKey:@"country"];
        NSString *space = @"       ";
       // NSString *row = [name stringByAppendingString:[space stringByAppendingString:[country stringByAppendingString:[space stringByAppendingString:score]]]];
        //NSLog(@"%@", [res1 objectForKey:@"fTCount"]);
        [nameList addObject:name];
        [countryList addObject:country];
        [scoreList addObject:score];
        [fCountList addObject:[res1 objectForKey:@"fCount"]];
        [fTCountList addObject:[res1 objectForKey:@"fTCount"]];
        [mCountList addObject:[res1 objectForKey:@"mCount"]];
        [mTCountList addObject:[res1 objectForKey:@"mTCount"]];
        [sCountList addObject:[res1 objectForKey:@"sCount"]];
        [sTCountList addObject:[res1 objectForKey:@"sTCount"]];
        //[leaders addObject:row];
        totalItems++;
    }
    //[leaderList endUpdates];
    [leaderList reloadData];
    if (totalItems > 0) [self reset];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.responseData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(IBAction)dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) reset {
    
    NSLog(@"we are on page = %d", page);

    if(page*6 > (totalItems-1))
    {
        moreLeaders.hidden = TRUE;
        page--;
        if(page < 0) page = 0;
    }
    else{
        moreLeaders.hidden = FALSE;
        bottomLabel.hidden = FALSE;
    }
}

-(IBAction)showMoreLeaders {
   
   // NSLog(@"page count in more = %d", page);
    nameList = [NSArray arrayWithArray:[copyNameList subarrayWithRange:NSMakeRange(page*6, [copysCountList count]-page*6)]];
    scoreList = [NSArray arrayWithArray:[copyScoreList subarrayWithRange:NSMakeRange(page*6, [copysCountList count]-page*6)]];
    countryList = [NSArray arrayWithArray:[copyCountryList subarrayWithRange:NSMakeRange(page*6, [copysCountList count]-page*6)]];
    fCountList = [NSArray arrayWithArray:[copyfCountList subarrayWithRange:NSMakeRange(page*6, [copysCountList count]-page*6)]];
    mCountList = [NSArray arrayWithArray:[copymCountList subarrayWithRange:NSMakeRange(page*6, [copysCountList count]-page*6)]];
    sCountList = [NSArray arrayWithArray:[copysCountList subarrayWithRange:NSMakeRange(page*6, [copysCountList count]-page*6)]];
    prevLeaders.hidden = FALSE;
    page++;
    [self reset];
    [leaderList reloadData];
}

-(IBAction)showPreviousLeaders {
    
    [self reset];
    page--;

    //x NSLog(@"page count in prev = %d", page);
    nameList = [NSArray arrayWithArray:[copyNameList subarrayWithRange:NSMakeRange(page*6, 6)]];
    scoreList = [NSArray arrayWithArray:[copyScoreList subarrayWithRange:NSMakeRange(page*6, 6)]];
    countryList = [NSArray arrayWithArray:[copyCountryList subarrayWithRange:NSMakeRange(page*6, 6)]];
    fCountList = [NSArray arrayWithArray:[copyfCountList subarrayWithRange:NSMakeRange(page*6, 6)]];
    mCountList = [NSArray arrayWithArray:[copymCountList subarrayWithRange:NSMakeRange(page*6, 6)]];
    sCountList = [NSArray arrayWithArray:[copysCountList subarrayWithRange:NSMakeRange(page*6, 6)]];
    [leaderList reloadData];
    if(page <= 0)
    {
        moreLeaders.hidden = FALSE;
        prevLeaders.hidden = TRUE;
        page++;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    cell = [leaderList dequeueReusableCellWithIdentifier:nil];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    
    UILabel *cellLabelS1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, cell.frame.size.width, cell.frame.size.height)];
    
    [cellLabelS1 viewWithTag:1];
    cellLabelS1.text = [nameList objectAtIndex:indexPath.row];
    cellLabelS1.font = [UIFont boldSystemFontOfSize: 20.0];
    [cellLabelS1 setBackgroundColor:UIColor.clearColor]; // Make the table view transparent
    [cell addSubview:cellLabelS1];
    
    UILabel *cellLabelS2 = [[UILabel alloc] initWithFrame:CGRectMake(122, 0, cell.frame.size.width, cell.frame.size.height)];

    [cellLabelS2 viewWithTag:2];
    cellLabelS2.text = [scoreList objectAtIndex:indexPath.row];
    cellLabelS2.font = [UIFont systemFontOfSize: 15.0];
    [cellLabelS2 setBackgroundColor:UIColor.clearColor]; // Make the table view transparent
    [cell addSubview:cellLabelS2];

    UILabel *cellLabelS3 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, cell.frame.size.width, cell.frame.size.height)];
    
    [cellLabelS3 viewWithTag:2];
    cellLabelS3.text = [countryList objectAtIndex:indexPath.row];
    cellLabelS3.font = [UIFont systemFontOfSize: 15.0];
    [cellLabelS3 setBackgroundColor:UIColor.clearColor]; // Make the table view transparent
    [cell addSubview:cellLabelS3];
    
    /*if(indexPath.row == 0)
    {
        [tableView
         selectRowAtIndexPath:indexPath
         animated:TRUE
         scrollPosition:UITableViewScrollPositionNone
         ];

    }*/
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([nameList count] >= 6)
    {
        return 6;
    }
    else {
        bottomLabel.hidden = TRUE;
        return [nameList count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [leaderList reloadData];
    NSUInteger row = [indexPath row];
    name = [nameList objectAtIndex:row];
    country = [countryList objectAtIndex:row];
    score = [scoreList objectAtIndex:row];
    fCount = [[fCountList objectAtIndex:row] intValue];
    fTCount = [[fTCountList objectAtIndex:row] intValue];
    mCount = [[mCountList objectAtIndex:row] intValue];
    mTCount = [[mTCountList objectAtIndex:row] intValue];
    sCount = [[sCountList objectAtIndex:row] intValue];
    sTCount = [[sTCountList objectAtIndex:row] intValue];
    [self performSegueWithIdentifier:@"showLeaderBoard" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLeaderBoard"]) {
        LeaderBoardDetailController *leaderDetailView = segue.destinationViewController;
        leaderDetailView.name = name;
        leaderDetailView.country = country;
        leaderDetailView.scoreDetail = score;
        leaderDetailView.fCount = fCount;
        leaderDetailView.mCount = mCount;
        leaderDetailView.sCount = sCount;
        leaderDetailView.fTCount = fTCount;
        leaderDetailView.mTCount = mTCount;
        leaderDetailView.sTCount = sTCount;
        //NSString *scoresub = [score substringToIndex:[score length] - 1];
        //leaderDetailView.scoreDetail = [scoresub floatValue];
    }
}

-(IBAction)loginScreen {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]  instantiateViewControllerWithIdentifier:@"NameViewController"];
    [self presentModalViewController:vc animated:false];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation != UIDeviceOrientationLandscapeLeft) &&
	(orientation != UIDeviceOrientationLandscapeRight);
}

@end
