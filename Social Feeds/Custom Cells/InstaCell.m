//
//  InstaCell.m
//  Social Feeds
//
//  Created by Krystel on 6/19/14.
//
//

#import "InstaCell.h"

@implementation InstaCell

@synthesize imageI, bottomV, nameI, statusI;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageI = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 300, 150)];
        [self.contentView addSubview:imageI];
        
        bottomV = [[UIView alloc] initWithFrame:CGRectMake(10, imageI.frame.size.height +imageI.frame.origin.y, 300, 60)];
        [bottomV setBackgroundColor:[UIColor whiteColor]];
        [bottomV setAlpha:1.0];
        
        nameI = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
        [nameI setTextAlignment:NSTextAlignmentCenter];
        [nameI setTextColor:[UIColor blackColor]];
        [nameI setFont:[UIFont boldSystemFontOfSize:12]];
        [nameI setBackgroundColor:[UIColor clearColor]];
        [bottomV addSubview:nameI];
        
        statusI = [[UILabel alloc] initWithFrame:CGRectMake(0, nameI.frame.origin.y + nameI.frame.size.height-3, 300, 35)];
        [statusI setBackgroundColor:[UIColor clearColor]];
        [statusI setTextAlignment:NSTextAlignmentCenter];
        [statusI setTextColor:[UIColor darkGrayColor]];
        [statusI setNumberOfLines:3];
        [statusI setLineBreakMode:NSLineBreakByWordWrapping];
        [statusI setFont:[UIFont italicSystemFontOfSize:10]];
        [bottomV addSubview:statusI];
        [self.contentView addSubview:bottomV];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view
{
    CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
    
    float distanceFromCenter = CGRectGetHeight(view.frame)/2 - CGRectGetMinY(rectInSuperview);
    float difference = CGRectGetHeight(imageI.frame) - CGRectGetHeight(self.frame);
    float move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference;
    
    CGRect imageRect = imageI.frame;
    imageRect.origin.y = -(difference/2)+move;
    imageI.frame = imageRect;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
