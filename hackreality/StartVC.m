//
//  StartVC.m
//  hackreality
//
//  Created by darkmage on 9/14/15.
//  Copyright (c) 2015 evildojo. All rights reserved.
//

#import "StartVC.h"
#import "StormpathAPIKey.h"
#import "CreateAccountVC.h"
#import "SearchAccountsVC.h"
#import "LoginVC.h"

@interface StartVC () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSURLConnection *tenantConnection;
@property (nonatomic) NSURLConnection *applicationConnection;
@property (strong, nonatomic) NSString *accountsURLStr;
@property (strong, nonatomic) NSString *loginAttemptsURLStr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation StartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *tenantURL = [NSURL URLWithString:TENANT_URL_STRING];
    NSURLRequest *tenantRequest = [NSURLRequest requestWithURL:tenantURL];
    self.tenantConnection = [[NSURLConnection alloc] initWithRequest:tenantRequest delegate:self];
    self.applicationConnection = nil;
    self.loginAttemptsURLStr = nil;
    self.accountsURLStr = nil;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    if (connection == self.tenantConnection) {
        NSLog(@"tenantConnection: Successfully connected");
    }
    else if (connection == self.applicationConnection) {
        NSLog(@"applicationConnection: Successfully connected");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.tenantConnection) {
        NSLog(@"tenantConnection: Response received");
    }
    else if (connection == self.applicationConnection) {
        NSLog(@"applicationConnection: Response received");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == self.tenantConnection) {
        NSLog(@"tenantConnection: Data received.");
        NSError *error = nil;
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else {
            //NSString *URLStr             = dataDict[@"href"];
            //NSString *keyStr             = dataDict[@"key"];
            //NSString *modifiedAtStr      = dataDict[@"modifiedAt"];
            //NSString *nameStr            = dataDict[@"name"];
            //NSString *accountsURLStr     = dataDict[@"accounts"][@"href"];
            //NSString *agentsURLStr       = dataDict[@"agents"][@"href"];
            NSString *applicationsURLStr = dataDict[@"applications"][@"href"];
            //NSString *createdAtStr       = dataDict[@"createdAt"];
            //NSString *customDataStr      = dataDict[@"customData"][@"href"];
            //NSString *directoriesURLStr  = dataDict[@"directories"][@"href"];
            //NSString *groupsURLStr       = dataDict[@"groups"][@"href"];
            //NSString *idSitesURLStr      = dataDict[@"idSites"][@"href"];
            //NSString *organizationsURLStr = dataDict[@"organizations"][@"href"];
            
            NSString *myAppURLStr = [NSString stringWithFormat:@"%@?name=My%%20Application", applicationsURLStr];
            NSURL *myAppURL = [NSURL URLWithString:myAppURLStr];
            NSURLRequest *myAppRequest = [NSURLRequest requestWithURL:myAppURL];
            self.applicationConnection = [NSURLConnection connectionWithRequest:myAppRequest delegate:self];
        }
    }
    else if (connection == self.applicationConnection) {
        NSLog(@"applicationConnection: Data received.");
        NSError *error = nil;
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else {
            NSArray *dataDictObj = dataDict[@"items"];
            NSDictionary *dataDictItems = dataDictObj[0];
            NSDictionary *dataDictItemsAccounts = dataDictItems[@"accounts"];
            NSDictionary *dataDictItemsLoginAttempts = dataDictItems[@"loginAttempts"];
            NSString *accountsURLStr = dataDictItemsAccounts[@"href"];
            NSString *loginAttemptsURLStr = dataDictItemsLoginAttempts[@"href"];
            self.loginAttemptsURLStr = loginAttemptsURLStr;
            self.accountsURLStr = accountsURLStr;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.tenantConnection) {
        NSLog(@"tenantConnection: Connection failed");
    }
    else if (connection == self.applicationConnection) {
        NSLog(@"applicationConnection: Connection failed");
    }
}

#pragma mark - UITableViewDataSource and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Create Account";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Search Accounts";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"Login";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"CreateAccountSegue" sender:self];
    }
    else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"SearchAccountsSegue" sender:self];
    }
    else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue: %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"CreateAccountSegue"]) {
        CreateAccountVC *vc = segue.destinationViewController;
        vc.accountsURLStr = self.accountsURLStr;
    }
    else if ([segue.identifier isEqualToString:@"SearchAccountsSegue"]) {
        SearchAccountsVC *vc = segue.destinationViewController;
        vc.accountsURLStr = self.accountsURLStr;
    }
    else if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        LoginVC *vc = segue.destinationViewController;
        vc.loginAttemptsURLStr = self.loginAttemptsURLStr;
    }
}

@end
