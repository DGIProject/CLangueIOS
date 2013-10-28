//
//  ClangueRecorderDetailViewController.h
//  Clangue
//
//  Created by guillaume on 09/10/13.
//  Copyright (c) 2013 DoTProjects. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "lame.h"

@interface ClangueRecorderDetailViewController : UIViewController
@property (strong, nonatomic) id homeworkId;
@property (strong, nonatomic) id username;
@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) id subjectId;
@property (weak, nonatomic) IBOutlet UIWebView *enonce;
@property (weak, nonatomic) IBOutlet UILabel *timeText;

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)recordPauseTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;

- (IBAction)SendTapped:(id)sender;
 

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
