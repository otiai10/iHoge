//
//  IHogeViewController.m
//  iHoge
//
//  Created by otiai10 on 2014/07/20.
//  Copyright (c) 2014年 otiai10. All rights reserved.
//

#import "IHogeViewController.h"
// 1) xcodeprojでimportしたフレームワークを、コード的も参照する
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface IHogeViewController ()

@end

@implementation IHogeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // 2) アカウント保存先をコンストラクトとする
    ACAccountStore *myAccountStore = [[ACAccountStore alloc] init];
    // 3) アカウントの種別をコンストラクトする
    ACAccountType *twitterAccountType = [myAccountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
    // 4) ACAccountStoreの持つメソッドを用いてリクエストする
    [myAccountStore requestAccessToAccountsWithType: twitterAccountType withCompletionHandler: ^(BOOL reqGranted, NSError *err){
        if (! reqGranted) {
            NSLog(@"Account Access Denied by user");
            return;
        }
        NSArray *twitterAccounts = [myAccountStore accountsWithAccountType:twitterAccountType];
        if ([twitterAccounts count] < 1) {
            return;
        }
        ACAccount *account = [twitterAccounts objectAtIndex: 0];
        // NSString *path = @"https://api.twitter.com/statuses/home_timeline.json"; // error.code = 34
        NSString *path = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
        NSURL *twitterApiUrl = [NSURL URLWithString: path];
        TWRequest *apiRequest = [[TWRequest alloc] initWithURL:twitterApiUrl parameters:nil requestMethod:TWRequestMethodGET ];
        [apiRequest setAccount:account];
        [apiRequest performRequestWithHandler: ^(NSData *resData, NSHTTPURLResponse *urlRes, NSError *err) {
            if (! resData) {
                NSLog(@"ない %@", err);
                return;
            }
            NSError *jsonParseError;
            statuses = [NSJSONSerialization JSONObjectWithData:resData options: NSJSONReadingMutableLeaves error: &jsonParseError];
            if (jsonParseError != nil) {
                NSLog(@"リクエストERROR %@", jsonParseError);
                return;
            }
            // 更新したstatusesを元にself.tableViewを最新にする
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)composeButton:(id)sender {
    if (! [TWTweetComposeViewController canSendTweet]) {
        NSLog(@"ツイートできないです");
        return;
    }
    TWTweetComposeViewController *myTweetController = [[TWTweetComposeViewController alloc] init];
    [self presentModalViewController: myTweetController animated: YES];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView");
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [statuses count];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (myCell == nil) {
        myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
        myCell.textLabel.font = [UIFont systemFontOfSize: 11.0];
    }
    NSDictionary *status = [statuses objectAtIndex: indexPath.row];
    NSString *text = [status objectForKey: @"text"];
    myCell.textLabel.text = text;
    return myCell;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
