//
//  NameViewController.h
//  KidsIQ5
//
//  Created by Chan Komagan on 7/28/12.
//  Copyright (c) 2012 KidsIQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface NameViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate, UITableViewDelegate, UITextFieldDelegate>
 {
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *choicesLabel;
    IBOutlet UILabel *errorStatus;
    UITextField *nameText;
    IBOutlet UIButton *nameOK;
    IBOutlet UIPickerView *levelPickerView;
    IBOutlet UISegmentedControl *segmentedControl;
    NSMutableArray *autoCompleteArray;
    NSMutableArray *elementArray, *lowerCaseElementArray;
    UITextField *countryText;
    UITableView *countryTableView;
    IBOutlet UILabel *statusLabel;
    UIAlertView *askToPurchase;
    NSMutableData *responseData;
}

@property (nonatomic, retain) NSArray *levelpicker;
@property (nonatomic, retain) UIPickerView *levelPickerView;
@property (nonatomic, retain)  UILabel *statusLabel;
@property (nonatomic, retain) NSMutableData *responseData;
@property int maxQuestions;

-(void)validateTextField;
-(IBAction)dismissView;
-(IBAction)textFieldReturn:(id)sender;
-(IBAction)valueChanged;
-(BOOL)IAPItemPurchased;
-(void)triggerPurchase;
-(IBAction)deleteKeyChain:(id)sender;

@end