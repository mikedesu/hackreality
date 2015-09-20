//
//  LoginVC.m
//  hackreality
//
//  Created by darkmage on 9/19/15.
//  Copyright © 2015 evildojo. All rights reserved.
//

#import "LoginVC.h"
#import "StormpathAPIKey.h"

@interface LoginVC () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (nonatomic) NSURLConnection *loginConnection;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button methods

- (IBAction)loginButtonTapped:(id)sender {
    NSLog(@"loginButtonTapped");
    NSString *username = self.usernameTF.text;
    NSString *password = self.passwordTF.text;
    if ([username isEqualToString:@""] || [password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter both your username and password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else {
        NSString *usernameAndPassword = [NSString stringWithFormat:@"%@:%@", username, password];
        NSData *usernameAndPasswordData = [usernameAndPassword dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64 = [usernameAndPasswordData base64EncodedStringWithOptions:0];
        // construct the POST data string
        NSDictionary *dataDict = @{
                                   @"type"  : @"basic",
                                   @"value" : base64
                                   };
        NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.loginAttemptsURLStr]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        self.loginConnection = [NSURLConnection connectionWithRequest:request delegate:self];
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
    if (connection == self.loginConnection) {
        NSLog(@"loginConnection: Successfully connected");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.loginConnection) {
        NSLog(@"loginConnection: Response received");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == self.loginConnection) {
        NSLog(@"loginConnection: Data received.");
        NSError *error = nil;
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else {
            NSLog(@"dataDict: %@", dataDict);
            NSNumber *code = dataDict[@"code"];
            if (code) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Code %ld", (long)code.integerValue] message:dataDict[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully logged in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.loginConnection) {
        NSLog(@"loginConnection: Connection failed");
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
