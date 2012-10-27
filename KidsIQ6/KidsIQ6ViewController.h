//
//  KidsIQ6ViewController.h
//  KidsIQ5
//
//  Created by Chan Komagan on 9/17/12.
//  Copyright (c) 2012 Chan Komagan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KidsIQ6ViewController : UIViewController
{
    IBOutlet UILabel *question;
    IBOutlet UILabel *answerA;
    IBOutlet UILabel *answerB;
    IBOutlet UILabel *answerC;
    IBOutlet UILabel *answerD;
    IBOutlet UILabel *myCounterLabel;
    IBOutlet UIButton *choicea;
    IBOutlet UIButton *choiceb;
    IBOutlet UIButton *choicec;
    IBOutlet UIButton *choiced;
    IBOutlet UIButton *submit;
    IBOutlet UILabel *score;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *result;
    IBOutlet UIButton *test;
    NSMutableData *responseData;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *country;
@property Boolean paidFlag;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableSet *usedNumbers;
@property (nonatomic, retain) UILabel *myCounterLabel;
@property int maxQuestions;
@property (assign) int level;
@property (nonatomic, retain) NSTimer *mainTimer;

-(IBAction)showQuitController;

-(IBAction)showLoginViewController;

-(IBAction)submit:(id)sender;

-(void)resetAllChoices;

-(void)resetAll;

-(void)disableAllChoices;

-(IBAction)checkAnswer;

-(IBAction)skipQuestion;

-(void)calculatescore;

-(void) calculateCount:(int)qCount;

-(void) calculateTCount:(int)category;

-(void)showResults;

-(int)generateRandomNumber;

-(IBAction)dismissView;

-(IBAction)startCountdown:(id)sender;
@end
