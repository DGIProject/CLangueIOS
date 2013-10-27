//
//  ClangueConectionViewController.m
//  Clangue
//
//  Created by guillaume on 09/10/13.
//  Copyright (c) 2013 DoTProjects. All rights reserved.
//

#import "ClangueConectionViewController.h"
#import "ClangueRecorderMasterViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface ClangueConectionViewController ()

@end

@implementation ClangueConectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)Onlick:(id)sender {
    
    NSURL *scriptUrl = [NSURL URLWithString:@"http://clangue.net/api/IOS/test.html"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data == nil){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Connection Failed"
                                                       message: @"Please connect to network and try again"
                                                      delegate: self
                                             cancelButtonTitle: @"Close"
                                             otherButtonTitles:nil];
        
        //Show Alert On The View
        [alert show];

    }
    else
    {
        const char *cStr = [_passwordVar.text UTF8String];
        unsigned char result[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(cStr, strlen(cStr), result);
        NSString *passhach = [NSString  stringWithFormat:
                       @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                       result[0], result[1], result[2], result[3], result[4],
                       result[5], result[6], result[7],
                       result[8], result[9], result[10], result[11], result[12],
                       result[13], result[14], result[15],
                       result[16], result[17], result[18], result[19]
                       ];
       // NSLog(@"sha1encode %@",passhach);
        
        NSString *post = [[@"username=" stringByAppendingString:_usernameVar.text] stringByAppendingString:[@"&password=" stringByAppendingString:passhach]];
        
        NSLog(@"%@",post);
        NSData *postData = [post dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:NO];
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
        [urlRequest setURL:[NSURL URLWithString:@"http://clangue.net/api/IOS/loggin.php"]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:postData];        
        
        NSData *urlData;
        NSURLResponse *response;
        NSError *error;
        urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        if(!urlData) {
            NSLog(@"Connection Failed!");
        }
        NSString *ReturnedStr = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
       // NSLog(@"%@", ReturnedStr);
        
        if ([ReturnedStr isEqual: @"0"])
        {
            NSLog(@"OK");
            _butonNext.hidden = false;
            _connectBtuon.hidden = true;
            _ErrorLabel.text = @"Vous êtes connecté";
        }else
        {
            _ErrorLabel.text = @"Identifiants Incorrects";
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_ErrorLabel.text = @" ";
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgApp.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)saisieReturn:(id)sender
{
    [sender resignFirstResponder];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CoPush"]) {
        [[segue destinationViewController] setDetailItem:_usernameVar.text];
    }
}

@end
