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
    NSMutableArray *_idSubject;
    NSMutableArray *_DoneSubjectArray;
    NSMutableArray *_availableSubject;
    NSMutableArray * _homeworkIdList;
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
    
    _homeworkIdList = [NSMutableArray array];
    _objects = [NSMutableArray array];
    _idSubject = [NSMutableArray array];
    _DoneSubjectArray = [NSMutableArray array];    
    _availableSubject = [NSMutableArray array];
    
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
      //  NSLog(@"%@",msgs);
        NSNumber *countString = [dit objectForKey:@"count"];
      //  NSLog(@"coujt %@",countString);
       // int count = [countString intValue];
        int i=0;
        int numberOfloop = [countString intValue];
        NSLog(@"%d",numberOfloop);
        for (i=0;i<numberOfloop;i++)
        {
            NSLog(@"entered In");
            NSString *sujet  = [@"suj" stringByAppendingFormat:@"%d",i];
            NSLog(@"%@",sujet);
            NSDictionary *itemSujet = [msgs objectForKey:sujet];
            NSString *nameSujet = [itemSujet objectForKey:@"name"];
            NSString *idsujet = [itemSujet objectForKey:@"subjectId"];
            NSString *done = [itemSujet objectForKey:@"doneSubject"];
            NSString *availablea  = [itemSujet objectForKey:@"available"];
            NSString *homeId = [itemSujet objectForKey:@"id"];
            NSLog(@"%@",nameSujet);
            [_objects addObject:nameSujet];
            [_idSubject addObject:idsujet];
            [_DoneSubjectArray addObject:done];
            [_availableSubject addObject:availablea];
            [_homeworkIdList addObject:homeId];
            NSLog(@"sujert %@",idsujet);
        }
            
        
        NSLog(@"log fin");
    }
    else {
        //Your error message
    }
    // NSLog(@"%@",ReturnedStr);
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
    //return _objects.count;
    return 1;
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
    NSString *done = _DoneSubjectArray[indexPath.row];
    NSString *availablea = [NSString stringWithFormat:@"%@",_availableSubject[indexPath.row]];
    NSLog(@"available !! %@",availablea);
   // NSLog(@"%@",done);
    if ([availablea isEqualToString: @"1"])
    {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.userInteractionEnabled = FALSE;
    }
    else
    {
        if ([done isEqualToString:@"1"])
        {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.userInteractionEnabled = FALSE;

        }
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        NSDate *object2 = _idSubject[indexPath.row];
        NSString *selectedHomeworkId = _homeworkIdList[indexPath.row];
      //  NSString *done = _DoneSubjectArray[indexPath.row];
        ClangueRecorderDetailViewController *controler = (ClangueRecorderDetailViewController*)segue.destinationViewController;
            controler.detailItem = object;
            controler.subjectId = object2;
        controler.username = _detailItem;
        controler.homeworkId = selectedHomeworkId;
            
            // NSLog(@"Array contents: %@", _objects);
            //  NSLog(@"Array contents 2 : %@", _idSubject);
            // NSMutableArray *arrayObject;
            // [arrayObject addObject:object];
            //  [arrayObject addObject:object2];
            //[[segue destinationViewController] setDetailItem:object2];
            
        
        
        
    }
}
- (void)setDetailItem:(id)newDetailItem		
{
    _detailItem = newDetailItem;
    NSLog(@"detail %@",_detailItem);
}

@end
