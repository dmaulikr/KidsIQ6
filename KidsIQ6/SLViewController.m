/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "SLViewController.h"
#import "KidsIQ6AppDelegate.h"

NSString *kPlaceholderPostMessage;

@interface SLViewController () <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)buttonClickHandler:(id)sender;

@end

@implementation SLViewController
@synthesize spinner = _spinner;
@synthesize postParams = _postParams;
@synthesize imageData = _imageData;
@synthesize imageConnection = _imageConnection;
@synthesize scoreText = _scoreText, nameText = _nameText;
NSString *const FBSessionStateChangedNotification =
@"com.chan.KidsIQ";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"SLViewController_iPhone" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    self.postParams =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     @"https://itunes.apple.com/us/app/kids-iq/id558345466?mt=8", @"link",
     @"http://komagan.com/KidsIQ/kidsiq_72x72.png", @"picture",
     @"KidsIQ iPhone App", @"name",
     @"iPhone Quiz App for Kids and Adults.", @"caption",
     @"Challenge your IQ by taking this test with questions ranging from General Knowledge to Science to Math!", @"description",
     nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spinner.hidden = TRUE;
    [self resetPostMessage];
    KidsIQ6AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
    // Set up the post information, hard-coded for this sample
    postNameLabel.text = [self.postParams objectForKey:@"name"];
    postCaptionLabel.text = [self.postParams
                                  objectForKey:@"caption"];
    [postCaptionLabel sizeToFit];
    postDescriptionLabel.text = [self.postParams
                                      objectForKey:@"description"];
    [postDescriptionLabel sizeToFit];
    
    self.imageData = [[NSMutableData alloc] init];
    NSURLRequest *imageRequest = [NSURLRequest
                                  requestWithURL:
                                  [NSURL URLWithString:
                                   [self.postParams objectForKey:@"picture"]]];
    self.imageConnection = [[NSURLConnection alloc] initWithRequest:
                            imageRequest delegate:self];
    nameLabel.text = self.nameText;
    kPlaceholderPostMessage = @"Hey guys, according to this app my IQ score is ";
    kPlaceholderPostMessage = [kPlaceholderPostMessage stringByAppendingString:self.scoreText];
    kPlaceholderPostMessage = [kPlaceholderPostMessage stringByAppendingString:@". Want to challenge me?"];
    postMessageTextView.text = kPlaceholderPostMessage;
    postMessageTextView.font = [UIFont systemFontOfSize: 14.0];
    [postMessageTextView setTextColor:[UIColor blackColor]];
    NSLog(@"message = %@", kPlaceholderPostMessage);
}

- (void)connection:(NSURLConnection*)connection
    didReceiveData:(NSData*)data{
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    // Load the image
    postImageView.image = [UIImage imageWithData:
                                [NSData dataWithData:self.imageData]];
    self.imageConnection = nil;
    self.imageData = nil;
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error{
    self.imageConnection = nil;
    self.imageData = nil;
}

-(void)handleDidBecomeActive{
    [FBSession.activeSession handleDidBecomeActive];
}

-(void)applicationWillTerminate{
    [FBSession.activeSession close];
}


- (void)resetPostMessage
{
    postMessageTextView.text = kPlaceholderPostMessage;
    postMessageTextView.textColor = [UIColor lightGrayColor];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // Clear the message text when the user starts editing
    if ([textView.text isEqualToString:kPlaceholderPostMessage]) {
        //textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // Reset to placeholder text if the user is done
    // editing and no message has been entered.
    if ([textView.text isEqualToString:@""]) {
        [self resetPostMessage];
    }
}

/*
 * A simple way to dismiss the message text view:
 * whenever the user clicks outside the view.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([postMessageTextView isFirstResponder] &&
        (postMessageTextView != touch.view))
    {
        [postMessageTextView resignFirstResponder];
    }
}

- (IBAction)publishButtonAction:(id)sender {
    SLViewController *viewController = [[SLViewController alloc]
                                           initWithNibName:@"SLViewController_iPhone"
                                           bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)shareButtonAction:(id)sender {
    // Hide keyboard if showing when button clicked
    //postMessageTextView.text = scoreLabel.text;
    if ([postMessageTextView isFirstResponder]) {
        [postMessageTextView resignFirstResponder];
    }
    // Add user message parameter if user filled it in
    [self.postParams setObject:postMessageTextView.text
                            forKey:@"message"];
    
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        // No permissions found in session, ask for it
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // If permissions granted, publish the story
                 [self publishStory];
             }
         }];
    } else {
        // If permissions present, publish the story
        [self publishStory];
    }
}

- (void)publishStory
{
    self.spinner.hidden = FALSE;
    [self.spinner startAnimating];
    publishButton.enabled = FALSE;
    cancelButton.enabled = FALSE;
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:self.postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertText = [NSString stringWithFormat:
                          @"Thanks for sharing your score!"];
         }
         // Show the result in an alert
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK!"
                           otherButtonTitles:nil]
          show];
         [self.spinner stopAnimating];
         cancelButton.enabled = TRUE;
     }];
}

- (IBAction)cancelButtonAction:(id)sender {
    [[self presentingViewController]
     dismissModalViewControllerAnimated:YES];
    [self.spinner stopAnimating];
}

- (void) alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[self presentingViewController]
     dismissModalViewControllerAnimated:YES];
}

#pragma mark Template generated code

- (void)viewDidUnload
{
    if (self.imageConnection) {
        [self.imageConnection cancel];
        self.imageConnection = nil;
    }
    [self.spinner stopAnimating];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -

@end
