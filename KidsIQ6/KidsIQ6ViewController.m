//
//  KidsIQ6ViewController.m
//  KidsIQ6
//
//  Created by Chan Komagan on 9/17/12.
//  Copyright (c) 2012 Chan Komagan. All rights reserved.
//

#import "KidsIQ6ViewController.h"
#import "NameViewController.h"
#import "QuitController.h"
#import "ResultController.h"
#import "QuartzCore/QuartzCore.h"

@interface KidsIQ6ViewController ()
@property (nonatomic, strong) NSString *nsURL;
@property (nonatomic, strong) NSString *selectedChoice;
@property (nonatomic, strong) NSString *correctChoice;
@end

@implementation KidsIQ6ViewController
@synthesize nsURL = _nsURL;
@synthesize responseData;
@synthesize selectedChoice = _selectedChoice;
@synthesize correctChoice = _correctChoice;
@synthesize usedNumbers;
@synthesize mainTimer;
NSInteger _id = -1;
NSInteger _score = 0;
NSInteger _noOfQuestions = 1;
int count = 1;
int category;
NSDictionary *res;
NSString *titleText;
NSString *scoreText;
NSString *finalScoreText;
NSString *btnPressed;
bool reset;
int counter, hours, minutes, seconds, secondsLeft, noOfSecs, fCount, fTCount, mCount, mTCount, sCount, sTCount;
UIColor *greenColor;
UIColor *redColor;
@synthesize name, country, paidFlag, level, maxQuestions, myCounterLabel;

-(void)showLoginViewController {
    
    nameLabel.text = name;
}

-(IBAction)showQuitController {
    QuitController *quitView = [[QuitController alloc] initWithNibName:@"QuitController" bundle:nil];
    quitView.mainTimer = mainTimer;
    quitView.name = name;
    quitView.country = country;
    [self presentModalViewController:quitView animated:true];
}

- (void)showbutton {
    submit.enabled = TRUE;
    [submit setTitle: @"Next" forState: UIControlStateNormal];
	[submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[submit setBackgroundColor:[UIColor brownColor]];
}

- (IBAction)choicea:(id)sender {
    
    [self resetAllChoices];
    choicea = (UIButton *)sender;
    [answerA setTextColor:[UIColor blueColor]];
    [choicea setBackgroundColor:[UIColor blueColor]];
    _selectedChoice = answerA.text;
	btnPressed = @"choicea";
    [self showbutton];
}

- (IBAction)choiceb:(id)sender {
	
    [self resetAllChoices];
    choiceb = (UIButton *)sender;
    [answerB setTextColor:[UIColor blueColor]];
    [choiceb setBackgroundColor:[UIColor blueColor]];
    _selectedChoice = answerB.text;
	btnPressed = @"choiceb";
    [self showbutton];
}

- (IBAction)choicec:(id)sender {
    
    [self resetAllChoices];
    choicec = (UIButton *)sender;
    [answerC setTextColor:[UIColor blueColor]];
    [choicec setBackgroundColor:[UIColor blueColor]];
    _selectedChoice = answerC.text;
	btnPressed = @"choicec";
    [self showbutton];
}

- (IBAction)choiced:(id)sender {
    
    [self resetAllChoices];
    choiced = (UIButton *)sender;
    [answerD setTextColor:[UIColor blueColor]];
    [choiced setBackgroundColor:[UIColor blueColor]];
    _selectedChoice = answerD.text;
	btnPressed = @"choiced";
    [self showbutton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    hours = minutes = seconds = 0;
    if ( [mainTimer isValid]){
        [mainTimer invalidate], mainTimer=nil;
    }
    //NSLog(@"iq viwq %@", country);
    mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                 target:self
                                               selector:@selector(advanceTimer:)
                                               userInfo:nil
                                                repeats:YES];
    while(_id < 0)
    {
        _id = [self generateRandomNumber];
    }
    [self trackScore]; //initialize the score counter
	if(_noOfQuestions <= maxQuestions)
	{
		submit.enabled = FALSE;
		[submit setTitle: @"Select" forState: UIControlStateNormal];
		[submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[submit setBackgroundColor:[UIColor darkGrayColor]];
        
		_nsURL = [@"http://www.komagan.com/KidsIQ/index.php?format=json&quiz2=1&question_id=" stringByAppendingFormat:@"%d ", _id];
		self.responseData = [NSMutableData data];
		
		NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: _nsURL]];
		//NSLog(@"request established");
		//NSLog(@"didReceiveResponse");
		[[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
        
	}
	else{
		[self showResults];
        return;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.responseData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"connectionDidFinishLoading");
    //NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    NSError *myError = nil;
    res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    NSMutableArray *answers = [[NSMutableArray alloc] init];
    
    for(NSDictionary *res1 in res) {
        NSString *preText = [NSString stringWithFormat:@"%d", _noOfQuestions];
        preText = [preText stringByAppendingFormat:@") "];
        question.text = [preText stringByAppendingString:[res1 objectForKey:@"question"]];
        category = [[res1 objectForKey:@"category"] intValue];
        NSString *answer = [res1 objectForKey:@"choice_text"];
        [answers addObject :answer];
        
        NSString *rightChoice = [res1 objectForKey:@"is_right_choice"];
        
        if ([rightChoice isEqualToString:@"1"]) {
            _correctChoice = answer;
        }
        if([question.text isEqualToString:@""]) [self disableAllChoices];
    }
    
    if ([res count] ==0)
    {
        [self showResults];
        return;
    }
    
    answerA.text = [answers objectAtIndex:0];
    answerB.text = [answers objectAtIndex:1];
    answerC.text = [answers objectAtIndex:2];
    answerD.text = [answers objectAtIndex:3];
}

- (void)resetAllChoices
{
    [answerA setTextColor:[UIColor blackColor]];
    [choicea setBackgroundColor:[UIColor blackColor]];
    [answerB setTextColor:[UIColor blackColor]];
    [choiceb setBackgroundColor:[UIColor blackColor]];
    [answerC setTextColor:[UIColor blackColor]];
    [choicec setBackgroundColor:[UIColor blackColor]];
    [answerD setTextColor:[UIColor blackColor]];
    [choiced setBackgroundColor:[UIColor blackColor]];
    choicea.enabled = YES;
    choiceb.enabled = YES;
    choiceb.enabled = YES;
    choiced.enabled = YES;
}

- (void)resetAll /* restart the quiz */
{
    _id = -1;
    _score = 0;
    fCount = mCount = sCount = fTCount = mTCount = sTCount = 0;
    reset = YES;  //reset the first set of questions
    _noOfQuestions = 1;
    greenColor = [UIColor colorWithRed:60.0f/255.0f green:179.0f/255.0f blue:113.0f/255.0f alpha:1.0f];
    [self setCounter];
    [mainTimer invalidate];
    [self viewDidLoad];
}

- (void)disableAllChoices
{
    for (UIView *view in self.view.subviews){
		view.userInteractionEnabled = NO;
		self->submit.userInteractionEnabled = YES;
	}
}

- (void)enableAllChoices
{
    for (UIView *view in self.view.subviews)
		view.userInteractionEnabled=YES;
}

- (IBAction)checkAnswer
{
    [self calculateTCount:category];
    if([submit.titleLabel.text isEqual:@"Next"])
    {
        if ([_selectedChoice isEqualToString:_correctChoice]) {
			[self highlightCorrect];
            [self calculateCount:category];
            _score++;
        }
        else {
            [self highlightWrong];
        }
        _noOfQuestions++;
        _id = [self generateRandomNumber];
		[submit setBackgroundColor:[UIColor purpleColor]];
		[submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self disableAllChoices];
        [self resetAllChoices];
        [self enableAllChoices];
        [self trackScore];
        [mainTimer invalidate];
        [self viewDidLoad];
        return;
    }
}

- (IBAction)skipQuestion
{
    _id = [self generateRandomNumber];
    _noOfQuestions++;
    [self resetAllChoices];
    [self trackScore];
	result.text =@"";
    [mainTimer invalidate];
    [self calculateTCount:category];
    [self viewDidLoad];
}

- (void)trackScore
{
    scoreText = [NSString stringWithFormat:@"%d",_score];
    scoreText = [scoreText stringByAppendingString:@ "/"];
    scoreText = [scoreText stringByAppendingString:[NSString stringWithFormat:@"%d",maxQuestions]];
    [score setText: scoreText];
}

- (void)calculatescore
{
    float tally;
    if (_noOfQuestions > 0)
    {
        tally = (float)_score / (float)maxQuestions;
        tally = roundf (tally * 100) / 100.0;
        
        if(tally > 0.90)
        {
            titleText = @"You are practically a genius.";
        }
        if((tally > 0.70) && (tally <= 0.90))
        {
            titleText = @"That is a great score!";
        }
        if((tally > 0.49) && (tally <= 0.70))
        {
            titleText = @"Think you can do better?!?";
        }
        if(tally <= 0.49)
        {
            titleText = @"Poor. You better start over.";
        }
    }
    finalScoreText = [NSString stringWithFormat:@"%.0f", round(tally*100)];
    finalScoreText = [finalScoreText stringByAppendingString: @"%"];
}

- (void) calculateCount:(int)qCount
{
    if(qCount == 1) fCount++;
    if(qCount == 2) mCount++;
    if(qCount == 3) sCount++;
}

- (void) calculateTCount:(int)category
{
    if(category == 1) { fTCount++; }
    if(category == 2) { mTCount++; }
    if(category == 3) { sTCount++; }
    NSLog(@"%d, %d, %d", fTCount, mTCount, sTCount);
}

-(void)highlightCorrect
{
	if([btnPressed isEqual:@"choicea"])
	{
		[choicea setBackgroundColor:greenColor];
		[answerA setTextColor:greenColor];
	}
	
	if([btnPressed isEqual:@"choiceb"])
	{
		[choiceb setBackgroundColor:greenColor];
		[answerB setTextColor:greenColor];
	}
    
	if([btnPressed isEqual:@"choicec"])
	{
		[choicec setBackgroundColor:greenColor];
		[answerC setTextColor:greenColor];
	}
    
	if([btnPressed isEqualToString:@"choiced"])
	{
		[choiced setBackgroundColor:greenColor];
		[answerD setTextColor:greenColor];
	}
}

-(void)highlightWrong
{
	if([btnPressed isEqual:@"choicea"])
	{
		[choicea setBackgroundColor:[UIColor redColor]];
		[answerA setTextColor:[UIColor redColor]];
	}
	
	if([btnPressed isEqual:@"choiceb"])
	{
		[choiceb setBackgroundColor:[UIColor redColor]];
		[answerB setTextColor:[UIColor redColor]];
	}
	
	if([btnPressed isEqual:@"choicec"])
	{
		[choicec setBackgroundColor:[UIColor redColor]];
		[answerC setTextColor:[UIColor redColor]];
	}
	
	if([btnPressed isEqualToString:@"choiced"])
	{
		[choiced setBackgroundColor:[UIColor redColor]];
		[answerD setTextColor:[UIColor redColor]];
	}
}

-(void)showResults
{
    [self calculatescore];
    
    ResultController *resultView = [[ResultController alloc] initWithNibName:@"ResultController" bundle:nil];
    resultView.name = name;
    resultView.titleText = titleText;
    resultView.score = finalScoreText;
    resultView.country = country;
    resultView.paidFlag = paidFlag;
    resultView.fCount = fCount;
    resultView.fTCount = fTCount;
    resultView.mCount = mCount;
    resultView.mTCount = mTCount;
    resultView.sCount = sCount;
    resultView.sTCount = sTCount;
	resultView.maxQuestions = maxQuestions;
    resultView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [mainTimer invalidate];
    [self presentModalViewController:resultView animated:true];
    [self resetAll];
}

-(int)generateRandomNumber
{
    int randomNumber = -1;
    randomNumber = (arc4random() % 70) + 1;
    NSLog(@"numberWithSet : %@ \n\n",usedNumbers);
    bool myIndex = [usedNumbers containsObject:[NSNumber numberWithInt: randomNumber]];
    if (myIndex == false)
    {
        [usedNumbers addObject:[NSNumber numberWithInt:randomNumber]];
        count++;
        return randomNumber;
    }
    else{
        NSLog(@"number already there : %d", randomNumber);
        return -1;
    }
    return randomNumber;
}

- (void)setCounter
{
    if(level == 1) noOfSecs = 10; //basic
    if(level == 2) noOfSecs = 7; //intermediate
    if(level == 3) noOfSecs = 5; //advanced
    counter = (maxQuestions*noOfSecs)+1;
    NSLog(@"total secs = %d", counter);
}

- (void)advanceTimer:(NSTimer *)timer
{
    counter--;
    if (counter <= 0) { [timer invalidate]; [self showResults];}
    
    if(counter > 0 ){
        minutes = (counter % 3600) / 60;
        seconds = (counter %3600) % 60;
        myCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    else{
        counter = 16925;
    }
}

- (void)viewDidUnload
{
    [mainTimer invalidate];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    nameLabel.text = name;
    usedNumbers = [NSMutableSet setWithCapacity:maxQuestions];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ResultControllerScreen"]) {
        
    }
}

-(IBAction)dismissView {
    [mainTimer invalidate];
    [self dismissModalViewControllerAnimated:YES];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation != UIDeviceOrientationLandscapeLeft) &&
	(orientation != UIDeviceOrientationLandscapeRight);
}

@end
