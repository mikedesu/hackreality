//
//  SearchAccountsVC.m
//  hackreality
//
//  Created by darkmage on 9/19/15.
//  Copyright © 2015 evildojo. All rights reserved.
//

#import "SearchAccountsVC.h"
#import "StormpathAPIKey.h"

@interface SearchAccountsVC () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (nonatomic) NSURLConnection *searchAccountsConnection;

@end

@implementation SearchAccountsVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button methods

- (IBAction)searchButtonTapped:(id)sender {
    NSLog(@"searchButtonTapped: %@", self.emailTF.text);
    if ([self.emailTF.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Email field cannot be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else {
        // assuming it is a valid email...
        // same procedure as the other screens
        NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", self.accountsURLStr, @"?email=", self.emailTF.text];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        self.searchAccountsConnection = [NSURLConnection connectionWithRequest:request delegate:self];
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
    if (connection == self.searchAccountsConnection) {
        NSLog(@"searchAccountsConnection: Successfully connected");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.searchAccountsConnection) {
        NSLog(@"searchAccountsConnection: Response received");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == self.searchAccountsConnection) {
        NSLog(@"searchAccountsConnection: Data received.");
        NSError *error = nil;
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else {
            NSLog(@"Data dict: %@", dataDict);
            NSNumber *sizeN = dataDict[@"size"];
            if (sizeN.integerValue == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No search results found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else if (sizeN.integerValue == 1) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Account found for email: %@", self.emailTF.text] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.searchAccountsConnection) {
        NSLog(@"searchAccountsConnection: Connection failed");
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
}

@end
