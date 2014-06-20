//
//  FeedsView.h
//  Social Feeds
//
//  Created by Krystel on 6/19/14.
//
//

#import <UIKit/UIKit.h>

@interface FeedsView : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIWebViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSMutableArray *statuses;
    IBOutlet UITableView *twitterTable;
    UILabel *titleN;
    
    NSString *accessToken;
    IBOutlet UIImageView *imageView;
    IBOutlet UIView *backgroundView;
    NSArray *dataArray;
}

@property (nonatomic,strong) NSDictionary *jsonData;
@property(nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;

//Twitter
- (IBAction)loginToTwitter:(id)sender;
- (IBAction)getTimelineAction:(id)sender;
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

- (IBAction)goToSearch:(id)sender;

@end
