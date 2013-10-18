//
//  ClangueRecorderMasterViewController.m
//  Clangue
//
//  Created by guillaume on 09/10/13.
//  Copyright (c) 2013 DoTProjects. All rights reserved.
//

#import "ClangueRecorderMasterViewController.h"

#import "ClangueRecorderDetailViewController.h"

@interface ClangueRecorderMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation ClangueRecorderMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _objects = [NSMutableArray array];
    //Getting Json by Post method on the Api
  /*  NSString *post = [@"username=" stringByAppendingString:_detailItem];
    
    NSData *postData = [post dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:NO];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:@"http://clangue.net/api/IOS/getSubject.php"]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:postData];
    
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if(!urlData) {
        NSLog(@"Connection Failed!");
    }
    NSString *ReturnedStr = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];*/
    //Parsing Json
    

    
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://clangue.net/api/IOS/getSubject.php"]];
    //NSLog(@"%@",jsonData);
    NSError* error;
    NSDictionary *dit = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        //Get values from this dict using respective keys
        NSDictionary *msgs = [dit objectForKey:@"list"];
       // NSDictionary *msg = [msgs objectForKey:@"message"];
        NSLog(@"%@",msgs);
        NSNumber *countString = [dit objectForKey:@"count"];
        NSLog(@"coujt %@",countString);
       // int count = [countString intValue];

            NSLog(@"entered In");
            NSString *sujet  = [@"suj" stringByAppendingFormat:@"%d",0];
            NSDictionary *itemSujet = [msgs objectForKey:sujet];
            NSString *nameSujet = [itemSujet objectForKey:@"name"];
            NSLog(@"%@",nameSujet);
            [_objects addObject:nameSujet ];
        
        NSLog(@"log fin");
    }
    else {
        //Your error message
    }
   // NSLog(@"%@",ReturnedStr);
    
    
    [_objects addObject:@"test"];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:@"test"];
    }
}
- (void)setDetailItem:(id)newDetailItem
{
    _detailItem = newDetailItem;
    NSLog(@"detail %@",_detailItem);
}

@end
