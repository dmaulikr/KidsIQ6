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

#import <UIKit/UIKit.h>

@interface SLViewController : UIViewController
{
    IBOutlet UITextView *postMessageTextView;
    IBOutlet UIImageView *postImageView;
    IBOutlet UILabel *postNameLabel;
    IBOutlet UILabel *postCaptionLabel;
    IBOutlet UILabel *postDescriptionLabel;
    IBOutlet UILabel *nameLabel, *message;
    IBOutlet UIButton *publishButton, *cancelButton;
}

@property (strong, nonatomic) NSString *nameText, *scoreText;
@property int fbLoginOption;
@property (strong, nonatomic) NSMutableDictionary *postParams;
extern NSString *const FBSessionStateChangedNotification;
@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) NSURLConnection *imageConnection;

-(IBAction)shareButtonAction:(id)sender;
-(IBAction)publishButtonAction:(id)sender;

@end
