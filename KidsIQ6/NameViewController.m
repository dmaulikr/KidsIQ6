//
//  NameViewController.m
//  KidsIQ6
//
//  Created by Chan Komagan on 11/8/12.
//  Copyright (c) 2012 KidsIQ. All rights reserved.
//

#import "NameViewController.h"
#import "KidsIQ6ViewController.h"
#import "SFHFKeychainUtils.h"
#import "SLViewController.h"
#import "AudioToolbox/AudioToolbox.h"
#import "AVFoundation/AVFoundation.h"

@interface NameViewController()
@property (nonatomic, strong) NSString *nsURL;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) AVAudioPlayer *player;
@end

@implementation NameViewController

@synthesize levelpicker, levelPickerView, maxQuestions, statusLabel, nsURL, responseData;
@synthesize spinner = _spinner;
NSString *newString;
NSDictionary *res;
bool paidFlag = FALSE;
BOOL nameExists;
NSString *levelSelection;
int challengeLevel = 1;
int noOfQuestions = 0;
float tableHeight = 50;
NSString *country;
bool countrySelected = FALSE;
SKProductsRequest *request;
NSSet *productId;
@synthesize player = _player;

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define LEGAL	@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define kStoredData @"KidsIQ"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) finishedSearching {
	[countryText resignFirstResponder];
	countryTableView.hidden = YES;
}

- (void)viewDidLoad
{
    productId = [NSSet setWithObjects:@"com.chan.KidsIQ", @"KidsIQIPhone", nil];
    self.spinner.hidden = TRUE;
    self.spinner.transform = CGAffineTransformMakeScale(1, 1);
    [self populateCountry];
    
    levelpicker = [NSArray arrayWithObjects:@"60",@"40",@"20",nil];

    challengeLevel = 1; noOfQuestions = 0;
    //noOfQuestions = maxQuestions;
    nameText = [[UITextField alloc] initWithFrame:CGRectMake(60, 70, 200, 40)];
    nameText.borderStyle = 3; // rounded, recessed rectangle
    nameText.autocorrectionType = UITextAutocorrectionTypeNo;
    nameText.textAlignment = UITextAlignmentCenter;
    nameText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nameText.returnKeyType = UIReturnKeyDone;
    nameText.font = [UIFont fontWithName:@"Trebuchet MS" size:30];
    nameText.textColor = [UIColor blackColor];
    nameText.delegate = self;
    [self.view addSubview:nameText];
    levelPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    levelPickerView.delegate = self;
    levelPickerView.showsSelectionIndicator = YES;
    [levelPickerView selectRow:2 inComponent:0 animated:YES];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(3.14/2);
    rotate = CGAffineTransformScale(rotate, 0.15, 1.0);
    [self.levelPickerView setTransform:rotate];
    [self.view addSubview:levelPickerView];
    self.levelPickerView.center = CGPointMake(160,260);
    [self loadUserSession];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSError *error = nil;
    [SFHFKeychainUtils deleteItemForUsername:@"KidsIQIPhone" andServiceName:kStoredData error:&error];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [nameOK setEnabled:NO];

}

-(void)validateTextField
{
    if(nameExists || (!countrySelected && countryText.text.length > 0))
    {
        if(nameExists) {
            statusLabel.text = [newString stringByAppendingString:@" Exists. Please enter another name"];
        }
        if (!countrySelected && countryText.text.length > 0)
        {
            statusLabel.text = @"Please select a valid country";
        }
    }
    else{
        statusLabel.text = @"";
    }
    // make sure all fields are have something in them
    if (nameText.text.length  > 0 && nameText.text.length <= 6 && countryText.text.length  > 0 && !nameExists && countrySelected) {
        nameOK.enabled = YES;
    }
    else {
        nameOK.enabled = NO;
        
    }
}

-(IBAction)dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showQuiz"]) {
        KidsIQ6ViewController *quizView = segue.destinationViewController;
        if ([nameText.text isEqualToString:@""]) {
            errorStatus.text = @"Please enter the name.";
            return;
        }
        [self saveUserSession];
        [quizView.mainTimer invalidate];
        quizView.name = nameText.text;
        quizView.country = country;
        quizView.maxQuestions = noOfQuestions;
        quizView.usedNumbers = [NSMutableSet setWithCapacity:noOfQuestions-1];
        quizView.paidFlag = paidFlag;
        quizView.level = challengeLevel; //1 is basic
        [quizView resetAll];
        NSError *error= [NSError errorWithDomain:@"Domain" code:0 userInfo:nil];
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Tabuk" ofType:@"mp3"];
        if ([[NSFileManager defaultManager] fileExistsAtPath : soundFilePath])
        {
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            _player.delegate = self;
            _player.volume = 0.3;
            [_player prepareToPlay];
            if (_player == nil)
                NSLog(@"%@", [error description]);
            else
                [_player play];
        }
        else
        {
            NSLog(@"error, file not found: %@", soundFilePath);
        }
        quizView.player = _player;
    }
    //NSLog(@"%i", noOfQuestions);
}

- (void)saveUserSession
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:nameText.text forKey:@"name"];
        //[standardUserDefaults setObject:country forKey:@"country"];
        [standardUserDefaults synchronize];
    }

}

- (void)loadUserSession
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults)
        nameText.text = [standardUserDefaults objectForKey:@"name"];
        //countryText.text = [standardUserDefaults objectForKey:@"country"];
        //countryText.text = [[standardUserDefaults objectForKey:@"country"] substringWithRange:NSMakeRange(0,5)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 3;
    noOfQuestions = 0;
    return numRows;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    levelSelection = [levelpicker objectAtIndex:row];
    //NSLog(@"You selected: %@", levelSelection);
    noOfQuestions = [levelSelection intValue];
    if(noOfQuestions == 40 || noOfQuestions == 60)
    {
       [self triggerPurchase];
    }
    [nameText resignFirstResponder];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [levelpicker objectAtIndex:row];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == countryText)
    {
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring];
        //[self checkName];
        countrySelected = FALSE;
        return TRUE;
    }
    if(textField == nameText)
    {
        newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:LEGAL] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        [self checkName];
        return ([string isEqualToString:filtered] && !([newString length] > 6));
    }
    //return !([newString length] > 5);
    return FALSE;
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
    [nameText resignFirstResponder];
    [countryText resignFirstResponder];
    [countryTableView resignFirstResponder];
    [self checkName];
    [self validateTextField];
}

// Close keyboard when Enter or Done is pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	BOOL isDone = YES;
    [nameText resignFirstResponder];
	if (isDone) {
        [self finishedSearching];
        
		return YES;
	} else {
		return NO;
	}
    [self checkName];
    [self validateTextField];
}

- (IBAction)backgroundTouched:(id)sender {
    [self.view endEditing:YES];
    [self checkName];
    [self validateTextField];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [nameText resignFirstResponder];
    [countryText resignFirstResponder];
    [countryTableView resignFirstResponder];
    [self checkName];
    [self validateTextField];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    [nameText resignFirstResponder];
    CGRect rect = CGRectMake(0, 0, 180, 60);
    UILabel *label = [[UILabel alloc]initWithFrame:rect];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(-3.14/2);
    rotate = CGAffineTransformScale(rotate, 0.2, 2.0);
    [label setTransform:rotate];
    label.text = [levelpicker objectAtIndex:row];
    label.font = [UIFont systemFontOfSize:70.0];
    label.textAlignment = UITextAlignmentCenter;
    label.numberOfLines = 2;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.backgroundColor = [UIColor clearColor];
    label.clipsToBounds = YES;
    noOfQuestions = 20; //set defaul to 20, set to 1 for testing only
    return label;
}

- (IBAction)valueChanged
{
	switch (segmentedControl.selectedSegmentIndex) {
		case 0:
            challengeLevel = 1;
			break;
		case 1:
            challengeLevel = 2;
            [self triggerPurchase];
			break;
        case 2:
            challengeLevel = 3;
            [self triggerPurchase];
			break;
		default:
            break;
    }
    
}

-(void)populateCountry
{

NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Country.txt" ofType:nil];
NSData* data = [NSData dataWithContentsOfFile:filePath];
    
//Convert the bytes from the file into a string
NSString* string = [[NSString alloc] initWithBytes:[data bytes]
                                                length:[data length]
                                              encoding:NSUTF8StringEncoding];
//Split the string around newline characters to create an array
NSString* delimiter = @"\n";
NSArray *item = [string componentsSeparatedByString:delimiter];
elementArray = [[NSMutableArray alloc] initWithArray:item];
autoCompleteArray = [[NSMutableArray alloc] init];

    
//Search Bar
countryText = [[UITextField alloc] initWithFrame:CGRectMake(40, 150, 240, 40)];
countryText.borderStyle = 3; // rounded, recessed rectangle
countryText.autocorrectionType = UITextAutocorrectionTypeNo;
countryText.textAlignment = UITextAlignmentCenter;
countryText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
countryText.returnKeyType = UIReturnKeyDone;
countryText.font = [UIFont fontWithName:@"Trebuchet MS" size:30];
countryText.textColor = [UIColor blackColor];
[countryText setDelegate:self];
[self.view addSubview:countryText];

//Autocomplete Table
countryTableView = [[UITableView alloc] initWithFrame:CGRectMake(60, 175, 200, tableHeight) style:UITableViewStylePlain];
countryTableView.delegate = self;
countryTableView.dataSource = self;
countryTableView.scrollEnabled = YES;
countryTableView.hidden = YES;
countryTableView.rowHeight = tableHeight;
[self.view addSubview:countryTableView];

}

// Take string from Search Textfield and compare it with autocomplete array
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
	
	// Put anything that starts with this substring into the autoCompleteArray
	// The items in this array is what will show up in the table view
	
	[autoCompleteArray removeAllObjects];
    
	for(NSString *curString in elementArray) {
		NSRange substringRangeLowerCase = [curString rangeOfString:[substring lowercaseString]];
		NSRange substringRangeUpperCase = [curString rangeOfString:[substring uppercaseString]];
        
		if (substringRangeLowerCase.length != 0 || substringRangeUpperCase.length != 0    ) {
			[autoCompleteArray addObject:curString] ;
		}
	}
	levelPickerView.hidden = YES;
	countryTableView.hidden = NO;
	[countryTableView reloadData];
    [self validateTextField];
}

#pragma mark UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    
	//Resize auto complete table based on how many elements will be displayed in the table
	if (autoCompleteArray.count >= 3) {
		countryTableView.frame = CGRectMake(45, 190, 230, tableHeight*3);
		return autoCompleteArray.count;
	}
	
	else if (autoCompleteArray.count == 2) {
		countryTableView.frame = CGRectMake(45, 190, 230, tableHeight*2);
		return autoCompleteArray.count;
	}
	
	else if (autoCompleteArray.count == 0){
		countryTableView.frame = CGRectMake(45, 190, 230, 0);
        levelPickerView.hidden = NO;
		return autoCompleteArray.count;
	}
    else {
		countryTableView.frame = CGRectMake(45, 190, 230, tableHeight);
		return autoCompleteArray.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
	cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier] ;
	}
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.text = [autoCompleteArray objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    countryText.text = selectedCell.textLabel.text;
    country = countryText.text;
    countrySelected = TRUE;
    countryText.font = [UIFont fontWithName:@"Trebuchet MS" size:25];
    [self validateTextField];
    levelPickerView.hidden = NO;
    [self finishedSearching];
}

-(void)checkName
{
    if (newString == NULL || newString == @"") newString = nameText.text;
    nsURL = [@"http://www.komagan.com/KidsIQ/leaders.php?format=json&checkname2=1&name=" stringByAppendingFormat:@"%@", newString];
    self.responseData = [NSMutableData data];
    NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: nsURL]];
    [[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *myError = nil;
    res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    newString = nameText.text;
    for(NSDictionary *res1 in res) {
        nameExists = [[res1 objectForKey:@"result"] boolValue];
        if(nameExists)
            {
                statusLabel.text = [newString stringByAppendingString:@" Exists. Please enter another name"];
            }
        else{
            //statusLabel.text = @"";
        }
        [self validateTextField];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.responseData = nil;
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation != UIDeviceOrientationLandscapeLeft) &&
	(orientation != UIDeviceOrientationLandscapeRight);
}

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{

}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    
}

/**************************In-App Purchase Logic*****************/

-(BOOL)IAPItemPurchased {
    
    NSError *error = nil;
    NSString *password = [SFHFKeychainUtils getPasswordForUsername: @"KidsIQIPhone" andServiceName: kStoredData error:&error];
    NSLog(@"%@", password);
    if ([password isEqualToString:@"whatever"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)triggerPurchase {
    self.spinner.hidden = FALSE;
    [self.spinner startAnimating];
    if ([self IAPItemPurchased]) {
        //statusLabel.text = @"Welcome back. You already purchased this app";
        [self yesPurchase];
    }
    else{
        askToPurchase = [[UIAlertView alloc]
                         initWithTitle:@"Full Feature Locked"
                         message:@"Purchase full feature \n for US $0.99?"
                         delegate:self
                         cancelButtonTitle:nil
                         otherButtonTitles:@"Yes", @"No", nil];
        askToPurchase.delegate = self;
        segmentedControl.enabled = FALSE;
        levelPickerView.hidden = TRUE;
        nameOK.hidden = TRUE;
        backButton.hidden = TRUE;
        [self.spinner startAnimating];
        self.spinner.hidden = FALSE;
        [askToPurchase show];
    }
}

#pragma mark StoreKit Delegate

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    //[self checkPurchasedItems];
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
            {
                statusLabel.text = @"Processing...";
                break;
            }
            case SKPaymentTransactionStatePurchased:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                statusLabel.text = @"Congrats. You unlocked full version!";
                UIAlertView *tmp = [[UIAlertView alloc]
                                    initWithTitle:@"Complete"
                                    message:@"You have unlocked Full Feature!"
                                    delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                paidFlag = TRUE;
                [self yesPurchase];
                [tmp show];
                [self completeTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                [self restoreTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                NSLog(@"%d", transaction.error.code);
                if (transaction.error.code != SKErrorPaymentCancelled) {
                    NSLog(@"Error payment cancelled");
                    statusLabel.text = @"Sorry. Feature Locked!";
                    paidFlag = FALSE;
                    [self noPurchase];
                }
                if (transaction.error.code != SKErrorPaymentNotAllowed) {
                    NSLog(@"Error payment not allowed");
                    statusLabel.text = @"Welcome back. You already purchased this app!";
                    [self yesPurchase];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // remove wait view here
                break;
            }
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:@"KidsIQIPhone"])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"KidsIQIPhone" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)restoreTransaction: (SKPaymentTransaction *)transaction
{
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    // remove wait view here
    statusLabel.text = @"";
    paidFlag = TRUE;
    [self noPurchase];
}

- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:@"KidsIQIPhone"])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"KidsIQIPhone" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    // remove wait view here
    statusLabel.text = @"";
    
    SKProduct *validProduct = nil;
    int count = [response.products count];
    
    if (count > 0) {
        validProduct = [response.products objectAtIndex:0];
        
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"KidsIQIPhone"];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    } else {
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Not Available"
                            message:@"No products to purchase"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];  
        paidFlag = FALSE;
        [self noPurchase];
        [tmp show];
    }
    
    
}

-(void)noPurchase
{
    [levelPickerView selectRow:2 inComponent:0 animated:YES];
    segmentedControl.selectedSegmentIndex = 0;
    [self.spinner stopAnimating];
    self.spinner.hidden = TRUE;
    backButton.enabled = TRUE;
    segmentedControl.enabled = TRUE;
    levelPickerView.hidden = FALSE;
    nameOK.hidden = FALSE;
    backButton.hidden = FALSE;
}

-(void)yesPurchase
{
    paidFlag = TRUE;
    [self.spinner stopAnimating];
    self.spinner.hidden = TRUE;
    backButton.hidden = FALSE;
    backButton.enabled = TRUE;
    nameOK.hidden = FALSE;
    segmentedControl.enabled = TRUE;
    levelPickerView.hidden = FALSE;
    NSError *error = nil;
    [SFHFKeychainUtils storeUsername:@"KidsIQIPhone" andPassword:@"whatever" forServiceName:kStoredData updateExisting:TRUE error:&error];
    NSString *password = [SFHFKeychainUtils getPasswordForUsername:@"KidsIQIPhone" andServiceName:kStoredData error:&error];
}

-(void)requestDidFinish:(SKRequest *)request
{

}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to connect with error: %@", [error localizedDescription]);
}



#pragma mark AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView==askToPurchase) {
        if (buttonIndex==0) {
            // user tapped YES, but we need to check if IAP is enabled or not.
            if ([SKPaymentQueue canMakePayments]) {
                request = [[SKProductsRequest alloc] initWithProductIdentifiers:productId];
                request.delegate = self;
                [request start];
            } else {
                UIAlertView *tmp = [[UIAlertView alloc]
                                    initWithTitle:@"Prohibited"
                                    message:@"Parental Control is enabled, cannot make a purchase!"
                                    delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                                    [levelPickerView selectRow:2 inComponent:0 animated:YES];
                                    segmentedControl.selectedSegmentIndex = 0;
                [tmp show];
            }
        } 
    else {
            NSLog(@"Not selected");
            [self noPurchase];
        }
    }
}

-(IBAction)deleteKeyChain:(id)sender {
    
    NSError *error = nil;
    [SFHFKeychainUtils deleteItemForUsername:@"KidsIQIPhone" andServiceName:kStoredData error:&error];
}

/** FB Login stuff **/

-(IBAction)FBScreen {
    
    SLViewController *fbView = [[SLViewController alloc] initWithNibName:@"SLViewController" bundle:nil];
    fbView.fbLoginOption = 1;
    [self presentModalViewController:fbView animated:false];
}

@end
