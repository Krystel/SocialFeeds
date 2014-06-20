//
//  InstaCell.h
//  Social Feeds
//
//  Created by Krystel on 6/19/14.
//
//

#import <UIKit/UIKit.h>

@interface InstaCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imageI;
@property (nonatomic, retain) IBOutlet UIView *bottomV;
@property (nonatomic, retain) IBOutlet UILabel *nameI, *statusI;

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

@end
