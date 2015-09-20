//
//  CreateAccountVC.m
//  hackreality
//
//  Created by darkmage on 9/15/15.
//  Copyright (c) 2015 evildojo. All rights reserved.
//

#import "CreateAccountVC.h"
#import "StormpathAPIKey.h"

@interface CreateAccountVC () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTF;
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTF;

@property (nonatomic) NSURLConnection *createAccountConnection;

@end

@implementation CreateAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIButton Actions

- (IBAction)createAccountTapped:(id)sender {
    NSLog(@"createAccountTapped");
    // verify fields are non-empty
    for (UITextField *field in @[self.firstNameTF, self.lastNameTF, self.userNameTF, self.emailTF, self.passwordTF, self.confirmPasswordTF]) {
        if ([field.text isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot have a blank field!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }
    }
    // also check that the two password fields contain the same string
    BOOL passwordCheckValid = [self.passwordTF.text isEqualToString:self.confirmPasswordTF.text];
    if (passwordCheckValid) {
        // construct the POST data string
        NSDictionary *dataDict = @{
                                   @"givenName":self.firstNameTF.text,
                                   @"surname"  :self.lastNameTF.text,
                                   @"username" :self.userNameTF.text,
                                   @"email"    :self.emailTF.text,
                                   @"password" :self.passwordTF.text
                                   };
        NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.accountsURLStr]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        self.createAccountConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    else if (!passwordCheckValid) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password fields must match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - NSURLConnectionDelegate

// deprecated in iOS 8
// use willSendRequestForAuthenticationChallenge
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (challenge.previousFailureCount == 0) {
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:API_ID password:API_SECRET persistence:NSURLCredentialPersistenceNone];
        [challenge.sender useCredential:newCredential forAuthenticationChallenge:challenge];
    }
    else {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}

// iOS 8 and up
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (challenge.previousFailureCount == 0) {
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:API_ID password:API_SECRET persistence:NSURLCredentialPersistenceNone];
        [challenge.sender useCredential:newCredential forAuthenticationChallenge:challenge];
    }
    else {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.createAccountConnection) {
        NSLog(@"createAccountConnection: Successfully connected");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.createAccountConnection) {
        NSLog(@"createAccountConnection: Response received");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == self.createAccountConnection) {
        NSLog(@"createAccountConnection: Data received.");
        NSError *error = nil;
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"ERROR!!!");
        }
        else {
            NSLog(@"Data dict: %@", dataDict);
            NSNumber *code = dataDict[@"code"];
            if (code) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Code %ld", (long)code.integerValue] message:dataDict[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully created account" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.createAccountConnection) {
        NSLog(@"createAccountConnection: Connection failed");
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
