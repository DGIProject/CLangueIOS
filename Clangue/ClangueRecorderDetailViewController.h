//
//  ClangueRecorderDetailViewController.h
//  Clangue
//
//  Created by guillaume on 09/10/13.
//  Copyright (c) 2013 DoTProjects. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClangueRecorderDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) id subjectId;
@property (weak, nonatomic) IBOutlet UIWebView *enonce;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
