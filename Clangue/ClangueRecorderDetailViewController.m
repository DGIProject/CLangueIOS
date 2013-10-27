//
//  ClangueRecorderDetailViewController.m
//  Clangue
//
//  Created by guillaume on 09/10/13.
//  Copyright (c) 2013 DoTProjects. All rights reserved.
//

#import "ClangueRecorderDetailViewController.h"

@interface ClangueRecorderDetailViewController ()
- (void)configureView;
@end

@implementation ClangueRecorderDetailViewController

#pragma mark - Managing the detail item

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    //Call Api and Get the Json code
    NSLog(@"ALLO");
    NSLog(@"id: %@",_subjectId);
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://clangue.net/api/IOS/getHomework.php?s=" stringByAppendingString:_subjectId]]];
    //NSLog(@"%@",jsonData);
    NSError* error;
    NSDictionary *dit = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        //Get values from this dict using respective keys
        NSDictionary *msgs = [dit objectForKey:@"data"];
        NSNumber *ident = [msgs objectForKey:@"id"];
        NSString *enonce = [NSString stringWithFormat:@"%@",[msgs objectForKey:@"enonce"]];
        NSLog(@"%@",ident);
        NSLog(@"%@",enonce);
        [_enonce loadHTMLString:enonce baseURL:nil];
    }
    else {
        //Your error message
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
