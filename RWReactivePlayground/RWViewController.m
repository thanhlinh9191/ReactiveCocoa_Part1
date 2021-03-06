//
//  RWViewController.m
//  RWReactivePlayground
//
//  Created by THANHLINH on 9/05/15.
//  Copyright (c) 2015 THANHLINH. All rights reserved.
//

#import "RWViewController.h"
#import "RWDummySignInService.h"
#import  <ReactiveCocoa.h>

@interface RWViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signInFailureText;

@property (strong, nonatomic) RWDummySignInService *signInService;

@end

@implementation RWViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.signInService = [RWDummySignInService new];
  
  // initially hide the failure message
  self.signInFailureText.hidden = YES;
  
  //B2 : create valid state signals
    //create signals
    RACSignal *validUsernameSignal = [self.usernameTextField.rac_textSignal map:^id(NSString* text) {
        return @([self isValidUsername:text]);
    }];
    RACSignal *validPasswordSignal = [self.passwordTextField.rac_textSignal map:^id(NSString *text) {
         return @([self isValidPassword:text]);
     }];
    
    //transform these signals so that they provide a nice background color
    [[validPasswordSignal
      map:^id(NSNumber *passwordValid) {
          return [passwordValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
      }]
     subscribeNext:^(UIColor *color) {
         self.passwordTextField.backgroundColor = color;
     }];
    //can use a macro as below
//    RAC(self.passwordTextField, backgroundColor) =
//    [validPasswordSignal
//     map:^id(NSNumber *passwordValid) {
//         return [passwordValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
//     }];
    //use macro for username
    RAC(self.usernameTextField, backgroundColor) =
    [validUsernameSignal
     map:^id(NSNumber *usernameValid) {
         return [usernameValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
     }];
    
    //B3. combine  signals
    RACSignal *signUpActiveSignal =
    [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal]
                      reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid) {
                          return @([usernameValid boolValue] && [passwordValid boolValue]);
                      }];
    [signUpActiveSignal subscribeNext:^(NSNumber *signupActive) {
        self.signInButton.enabled = [signupActive boolValue];
    }];
    
    //B4. Singal for control events
//    [[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        NSLog(@"Singin Button : clicked");
//    }];
    //B5 : create new signal for sign-in
//    [[[self.signInButton
//       rac_signalForControlEvents:UIControlEventTouchUpInside]
//      map:^id(id x) {
//          return [self signInSignal];
//      }]
//     subscribeNext:^(id x) {
//         //example :  Sign in result: <RACDynamicSignal: 0x7f8dc25b5520> name: +createSignal:
//        //This situation above is sometimes called the signal of signals;
//         NSLog(@"Sign in result: %@", x);
//     }];
    
    //B6. singal for signals
    //short pipeline
//    [[[self.signInButton
//       rac_signalForControlEvents:UIControlEventTouchUpInside]
//      flattenMap:^id(id x) {
//          return [self signInSignal];
//      }]
//     subscribeNext:^(id x) {
//         NSLog(@"Sign in result: %@", x);
//     }];
    //full pipeline
//    [[[self.signInButton
//       rac_signalForControlEvents:UIControlEventTouchUpInside]
//      flattenMap:^id(id x) {
//          return [self signInSignal];
//      }]
//     subscribeNext:^(NSNumber *signedIn) {
//         BOOL success = [signedIn boolValue];
//         self.signInFailureText.hidden = success;
//         if (success) {
//             [self performSegueWithIdentifier:@"signInSuccess" sender:self];
//         }
//     }];
    
    //B7: ADD SIDE EFFECT
    [[[[self.signInButton
        rac_signalForControlEvents:UIControlEventTouchUpInside]
       doNext:^(id x) {
           self.signInButton.enabled = NO;
           self.signInFailureText.hidden = YES;
       }]
      flattenMap:^id(id x) {
          return [self signInSignal];
      }]
     subscribeNext:^(NSNumber *signedIn) {
         self.signInButton.enabled = YES;
         BOOL success = [signedIn boolValue];
         self.signInFailureText.hidden = success;
         if (success) {
             [self performSegueWithIdentifier:@"signInSuccess" sender:self];
         }
     }];
}

//B5. CREATE SINGAL SINGAL
//to adapt existing asynchronous APIs to be expressed as a signal.
-(RACSignal *)signInSignal{
    //
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       [self.signInService signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text complete:^(BOOL success) {
           [subscriber sendNext:@(success)];
           [subscriber sendCompleted];
       }];
        return nil;
    }];
}

- (BOOL)isValidUsername:(NSString *)username {
  return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
  return password.length > 3;
}

- (IBAction)signInButtonTouched:(id)sender {
  // disable all UI controls
  self.signInButton.enabled = NO;
  self.signInFailureText.hidden = YES;
  
  // sign in
  [self.signInService signInWithUsername:self.usernameTextField.text
                            password:self.passwordTextField.text
                            complete:^(BOOL success) {
                              self.signInButton.enabled = YES;
                              self.signInFailureText.hidden = success;
                              if (success) {
                                [self performSegueWithIdentifier:@"signInSuccess" sender:self];
                              }
                            }];
}

@end
