//
//  ClangueConectionViewController.h
//  Clangue
//
//  Created by guillaume on 09/10/13.
//  Copyright (c) 2013 DoTProjects. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClangueConectionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameVar;
@property (weak, nonatomic) IBOutlet UITextField *passwordVar;
- (IBAction)saisieReturn :(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *butonNext;
@property (weak, nonatomic) IBOutlet UIButton *connectBtuon;
@property (weak, nonatomic) IBOutlet UILabel *ErrorLabel;
@end
