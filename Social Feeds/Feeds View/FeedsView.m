//
//  FeedsView.m
//  Social Feeds
//
//  Created by Krystel on 6/19/14.
//
//

#import "FeedsView.h"
#import "STTwitter.h"
#import "TwitterCell.h"
#import "InstaCell.h"
#import "BWTitlePagerView.h"
#import "JSONKit.h"
#import "GTScrollNavigationBar.h"
#import "AsyncImageView.h"

@interface FeedsView ()
{
    BWTitlePagerView *pagingTitleView;
    UIWebView *logInWebView;
    NSString *redirectURLforGetAccessToken;
    UIView *activityContainer;
    UIActivityIndicatorView *indicator;
}
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, retain) NSMutableArray *filteredPersons;
@property(nonatomic, copy) NSString *currentSearchString;

@end

@implementation FeedsView
@synthesize jsonData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.pagingEnabled = YES;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setDelegate:self];
    self.view = self.scrollView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    activityContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 504)];
    activityContainer.backgroundColor = [UIColor colorWithRed:0.953 green:0.953 blue:0.953 alpha:1];
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(activityContainer.frame.size.width/2-40, activityContainer.frame.size.height/2 -40, 80, 80)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.backgroundColor = [UIColor blackColor];
    [indicator layer].cornerRadius = 8.0;
    [indicator layer].masksToBounds = YES;
    [indicator startAnimating];
    [activityContainer addSubview:indicator];
    [self.view insertSubview:activityContainer aboveSubview:self.scrollView];

    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.561 green:0.267 blue:0.678 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    pagingTitleView = [[BWTitlePagerView alloc] init];
    pagingTitleView.frame = CGRectMake(0, 0, 150, 40);
    pagingTitleView.font = [UIFont systemFontOfSize:15];
    pagingTitleView.currentTintColor = [UIColor whiteColor];
    [pagingTitleView observeScrollView:self.scrollView];
    [pagingTitleView addObjects:@[@"Twitter", @"Instagram"]];
    self.navigationItem.titleView = pagingTitleView;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    statuses = [[NSMutableArray alloc] init];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.953 green:0.953 blue:0.953 alpha:1]];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"token"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"tokenSecret"])
        [self loggedIn:self];
    else
        [self loginToTwitter:self];
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    CGRect newBounds = twitterTable.bounds;
    if (twitterTable.bounds.origin.y < 44) {
        newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
        twitterTable.bounds = newBounds;
    }

    [twitterTable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:0 animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.scrollNavigationBar.scrollView = nil;
}


-(void) viewDidAppear:(BOOL)animated
{
    [self.scrollView showsHorizontalScrollIndicator];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, self.view.frame.size.height-64);
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void) loadInterface
{
    twitterTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 504) style:UITableViewStylePlain];
    [twitterTable setDelegate:self];
    [twitterTable setDataSource:self];
    [twitterTable setBackgroundColor:[UIColor clearColor]];
    [twitterTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [twitterTable setShowsVerticalScrollIndicator:NO];
    [twitterTable setShowsHorizontalScrollIndicator:NO];
    [self.scrollView addSubview:twitterTable];
    self.navigationController.scrollNavigationBar.scrollView = twitterTable;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [self.searchBar setBarStyle:UIBarStyleDefault];
    [self.searchBar setKeyboardType:UIKeyboardTypeDefault];
    [self.searchBar setPlaceholder:@"Search..."];
    [self.searchBar setShowsSearchResultsButton:NO];
    [self.searchBar sizeToFit];
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    
    twitterTable.tableHeaderView = self.searchBar;
    twitterTable.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.bounds));
    
    [self.searchBar setShowsScopeBar:NO];
    [self.searchBar sizeToFit];
    
    CGRect newBounds = [twitterTable bounds];
    newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
    [twitterTable setBounds:newBounds];

}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [twitterTable scrollRectToVisible:self.searchBar.frame animated:animated];
}

- (IBAction)goToSearch:(id)sender
{
    [self.searchBar becomeFirstResponder];
}


#pragma mark - Twitter

-(IBAction)loggedIn:(id)sender
{
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] consumerSecret:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenSecret"] oauthToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] oauthTokenSecret:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenSecret"]];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
//        loginStatusLabel.text = [NSString stringWithFormat:@"You're logged in as %@",username];
        [titleN setText:[NSString stringWithFormat:@"@%@",username]];
        [self performSelector:@selector(getTimelineAction:) withObject:nil afterDelay:1.0];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (IBAction)loginToTwitter:(id)sender {
    
    self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        [titleN setText:[NSString stringWithFormat:@"@%@",username]];
        [self performSelector:@selector(getTimelineAction:) withObject:nil afterDelay:1.0];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
        [[NSUserDefaults standardUserDefaults] setObject:_twitter.oauthAccessToken forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] setObject:_twitter.oauthAccessTokenSecret forKey:@"tokenSecret"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (IBAction)getTimelineAction:(id)sender {
    
    [_twitter getHomeTimelineSinceID:sender
                               count:20
                        successBlock:^(NSArray *stats) {
                            
                            statuses = [NSMutableArray arrayWithArray:stats];
                            NSLog(@"-- statuses: %@", stats);
                            [self performSelectorInBackground:@selector(loadInterface) withObject:nil];
                            [twitterTable reloadData];
                            [indicator stopAnimating];
                            [activityContainer setHidden:YES];
                            
                        } errorBlock:^(NSError *error) {
                        }];
}


#pragma mark - Instagram

-(void)readFeedJsonFromURL{
    
    NSLog(@"readFeedJsonFromURL");
    
    NSString *clientID = @"97bc3b47f71a4f8dae03c4845801514c";
    redirectURLforGetAccessToken = @"http://www.opendream.co.th";
    NSString *requestAccessTokenPath = [[[[@"https://instagram.com/oauth/authorize/?client_id=" stringByAppendingString:clientID] stringByAppendingString:@"&redirect_uri="] stringByAppendingString:redirectURLforGetAccessToken] stringByAppendingString:@"&response_type=token"];
    
    
    NSHTTPURLResponse *responseURL = [[NSHTTPURLResponse alloc] init];
    NSURLRequest *requestAccessToken = [NSURLRequest requestWithURL:[NSURL URLWithString:requestAccessTokenPath]];
    NSData *accessTokenWithRedirectURL = [NSURLConnection  sendSynchronousRequest:requestAccessToken returningResponse:&responseURL error:NULL];
    
    self.jsonData = [accessTokenWithRedirectURL objectFromJSONData];
    
    logInWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    logInWebView.delegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[responseURL URL]];
    [logInWebView loadRequest:request];
    [self.view addSubview:logInWebView];
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"webView");
    NSURL *redirectURL = [request URL];
    NSString *redirectString = [redirectURL absoluteString];
    
    if([redirectString rangeOfString:@"#access_token="].location != NSNotFound && [redirectString rangeOfString:redirectURLforGetAccessToken].location != NSNotFound){

        NSRange rangeAccessToken = [redirectString rangeOfString:@"#access_token="];
        int indexStartToken = rangeAccessToken.location + rangeAccessToken.length;
        NSString *realAccessToken = [redirectString substringWithRange:NSMakeRange (indexStartToken, redirectString.length - indexStartToken)];
        
        accessToken = realAccessToken;
        NSLog(@"webview redirect from opendream");
        
        [self requestFeed];
    }
    
    return YES;
}

-(void)requestFeed
{
    NSLog(@"requestFeed");
    
    [logInWebView setHidden:YES];
    [logInWebView removeFromSuperview];

    NSString *path = @"https://api.instagram.com/v1/users/self/feed?access_token=";
    NSString *likePath = [path stringByAppendingString:accessToken];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:likePath]];
    NSData *feedData = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:NULL];
    
    self.jsonData = [feedData objectFromJSONData];
    [self readDictJsonData];
    
    
    [logInWebView removeFromSuperview];
    
    [twitterTable reloadData];
}

-(void)readFileJson
{
    NSLog(@"readFileJson");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Popular" ofType:@"json"];
    NSData *jsonDataWithPath = [NSData dataWithContentsOfFile:path];
    self.jsonData = [jsonDataWithPath objectFromJSONData];
}

-(void)readDictJsonData
{
    NSLog(@"readDictJsonData");
    dataArray = [self.jsonData objectForKey:@"data"];
    
    [indicator stopAnimating];
    [activityContainer setHidden:YES];
}

-(void)clearAccessToken
{
    NSLog(@"clearAccessToken");
    accessToken = @"";
    dataArray = [NSArray new];
    [twitterTable reloadData];
    
    NSURL *logOutURL = [NSURL URLWithString:@"https://instagram.com/accounts/logout/"];
    NSURLRequest *logOutRequest = [NSURLRequest requestWithURL:logOutURL];
    [NSURLConnection  sendSynchronousRequest:logOutRequest returningResponse:nil error:NULL];
    NSLog(@"LOG OUT!");
    
    [self readFeedJsonFromURL];
}

- (void)hideImageView:(UITapGestureRecognizer *)sender
{
    NSLog(@"hide image view");
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        backgroundView.alpha = 1;
        [imageView setFrame:CGRectMake(0, 0, 320, 320)];
        
        [UIView beginAnimations:@"" context:NULL];
        backgroundView.alpha = 0;
        [imageView setFrame:CGRectMake(0, 0, 0, 0)];
        //imageView.hidden = YES;
        //backgroundView.hidden = YES;
        [UIView commitAnimations];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    NSInteger rows =0;
    if (pagingTitleView.getCurrentPage ==0)
    {
        if (tableView == self.searchDisplayController.searchResultsTableView)
            rows = [self.filteredPersons count];
        else
            rows = [statuses count];
    }
    else if (pagingTitleView.getCurrentPage ==1)
    {
        if (tableView == self.searchDisplayController.searchResultsTableView)
            rows = [self.filteredPersons count];
        else
            rows = [dataArray count];
    }
    return rows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *result;
    
    if (pagingTitleView.getCurrentPage == 0)
    {
        if (tableView == self.searchDisplayController.searchResultsTableView)
            result = self.filteredPersons;
        else
            result = statuses;

        static NSString *simpleTableIdentifier = @"TwitterCell";
        
        TwitterCell *cell = (TwitterCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[TwitterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
           
            AsyncImageView *img = [[AsyncImageView alloc] initWithFrame:CGRectMake(cell.imageT.frame.origin.x+10, cell.imageT.frame.origin.y+10, cell.imageT.frame.size.width, cell.imageT.frame.size.height)];
            img.contentMode = UIViewContentModeScaleAspectFill;
            [img setShowActivityIndicator:YES];
            img.clipsToBounds = YES;
            img.tag = 99;
            [cell.contentView addSubview:img];
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        NSDictionary *status = [result objectAtIndex:indexPath.row];

        AsyncImageView *aimg = (AsyncImageView *)[cell viewWithTag:99];
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:aimg];
        NSString *stringUrl = [status valueForKeyPath:@"user.profile_image_url_https"];
        aimg.imageURL = [NSURL URLWithString:stringUrl];

        [cell.rNameL setText:[status valueForKeyPath:@"user.name"]];
        [cell.sNameL setText:[NSString stringWithFormat:@"@%@",[status valueForKeyPath:@"user.screen_name"]]];
        [cell.dateL setText:[status valueForKey:@"created_at"]];
        [cell.statusL setText:[status valueForKey:@"text"]];
        
        return cell;
    }
    else if (pagingTitleView.getCurrentPage ==1)
    {
        if (tableView == self.searchDisplayController.searchResultsTableView)
            result = self.filteredPersons;
        else
            result = dataArray;
        
        static NSString *simpleTableIdentifier = @"InstaCell";
        
        InstaCell *cell = (InstaCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[InstaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            AsyncImageView *img = [[AsyncImageView alloc] initWithFrame:CGRectMake(cell.imageI.frame.origin.x, cell.imageI.frame.origin.y, cell.imageI.frame.size.width, cell.imageI.frame.size.height)];
            img.contentMode = UIViewContentModeScaleAspectFill;
            [img setShowActivityIndicator:YES];
            img.clipsToBounds = YES;
            img.tag = 98;
            [cell.contentView addSubview:img];
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        NSString *stringUrl = [[[[result objectAtIndex:indexPath.row] objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"];
        
        AsyncImageView *aimg = (AsyncImageView *)[cell viewWithTag:98];
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:aimg];
        aimg.imageURL = [NSURL URLWithString:stringUrl];

        [cell.nameI setText:[[[result objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"full_name"]];
        
        if(![[[result objectAtIndex:indexPath.row] objectForKey:@"caption"] isKindOfClass:[NSNull class]])
            [cell.statusI setText:[[[result objectAtIndex:indexPath.row] objectForKey:@"caption"] objectForKey:@"text"]];
        
        return cell;

    }
   
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.scrollView])
    {
        if (pagingTitleView.getCurrentPage ==0)
        {
            [twitterTable setFrame:CGRectMake(0, 0, 320, 504)];
            [twitterTable reloadData];

        }
        else if (pagingTitleView.getCurrentPage ==1)
        {
            
            [activityContainer setFrame:CGRectMake(320, 0, 320, 504)];
            [indicator setFrame:CGRectMake(120, 120, 80, 80)];
            [indicator startAnimating];
            [self.scrollView addSubview:activityContainer];
            
            [twitterTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

            self.jsonData = [[NSDictionary alloc] init];
            imageView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageView:)];
            [tapGesture setNumberOfTapsRequired:1];
            [tapGesture setNumberOfTouchesRequired:1];
            [imageView addGestureRecognizer:tapGesture];
            
            [twitterTable setFrame:CGRectMake(320, 0, 320, 504)];
            [twitterTable setScrollsToTop:YES];

            
            if([accessToken isEqualToString:@""] || accessToken == nil){
                [self readFeedJsonFromURL];
            }
            else
                [twitterTable reloadData];
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPosition:YES];
}


#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    NSMutableArray* tempArr = [NSMutableArray new];
    self.filteredPersons = [[NSMutableArray alloc] init];

    if (pagingTitleView.getCurrentPage ==0)
    {
        for (NSDictionary* ma in statuses) {
            [tempArr addObject:[[ma objectForKey:@"user"] objectForKey:@"name"]];
            [tempArr addObject:[[ma objectForKey:@"user"] objectForKey:@"screen_name"]];
            [tempArr addObject:[ma objectForKey:@"text"]];
        }
    }
    else if (pagingTitleView.getCurrentPage ==1)
    {
        for (NSDictionary* ma in dataArray) {
            if (![[[ma objectForKey:@"user"] objectForKey:@"full_name"] isKindOfClass:[NSNull class]])
                [tempArr addObject:[[ma objectForKey:@"user"] objectForKey:@"full_name"]];
            if (![[ma objectForKey:@"caption"] isKindOfClass:[NSNull class]])
                [tempArr addObject:[[ma objectForKey:@"caption"] objectForKey:@"text"]];
        }
    }
    

    NSArray* tempFilterArr = nil;
    tempFilterArr =  [tempArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText]];
    
    if (pagingTitleView.getCurrentPage == 0)
    {
        for (NSDictionary* ma in statuses) {
            for (NSString* st in tempFilterArr) {
                if ([st isEqualToString:[[ma objectForKey:@"user"] objectForKey:@"name"]] || [st isEqualToString:[[ma objectForKey:@"user"] objectForKey:@"screen_name"]] || [st isEqualToString:[ma objectForKey:@"text"]]) {
                    [self.filteredPersons addObject:ma];
                    break;
                }
            }
        }
    }
    else if (pagingTitleView.getCurrentPage ==1)
    {
        for (NSDictionary* ma in dataArray) {
            for (NSString* st in tempFilterArr) {
                if ([[ma objectForKey:@"caption"] isKindOfClass:[NSNull class]])
                {
                    if ([st isEqualToString:[[ma objectForKey:@"user"] objectForKey:@"full_name"]]) {
                        [self.filteredPersons addObject:ma];
                        break;
                    }
                }
                else
                {
                    if ([st isEqualToString:[[ma objectForKey:@"user"] objectForKey:@"full_name"]] || [st isEqualToString:[[ma objectForKey:@"caption"] objectForKey:@"text"]]) {
                        [self.filteredPersons addObject:ma];
                        break;
                    }
                }
               
            }
        }
    }
}


#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
