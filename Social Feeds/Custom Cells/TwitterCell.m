//
//  TwitterCell.m
//  Social Feeds
//
//  Created by Krystel on 6/19/14.
//
//

#import "TwitterCell.h"

@implementation TwitterCell
@synthesize imageT, statusL, dateL, rNameL, sNameL;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIView *bckView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 210)];
        [bckView setBackgroundColor:[UIColor whiteColor]];
        
        imageT = [[UIImageView alloc] initWithFrame:CGRectMake(bckView.frame.size.width/2 - 40, 5, 80, 80)];
        [bckView addSubview:imageT];
        
        rNameL = [[UILabel alloc] initWithFrame:CGRectMake(0, imageT.frame.size.height + imageT.frame.origin.y,  bckView.frame.size.width, 25)];
        [rNameL setTextAlignment:NSTextAlignmentCenter];
        [rNameL setTextColor:[UIColor darkGrayColor]];
        [rNameL setFont:[UIFont boldSystemFontOfSize:12]];
        [rNameL setBackgroundColor:[UIColor clearColor]];
        [bckView addSubview:rNameL];
        
        sNameL = [[UILabel alloc] initWithFrame:CGRectMake(0, rNameL.frame.origin.y + rNameL.frame.size.height-5, bckView.frame.size.width, rNameL.frame.size.height)];
        [sNameL setTextAlignment:NSTextAlignmentCenter];
        [sNameL setTextColor:[UIColor grayColor]];
        [sNameL setFont:[UIFont italicSystemFontOfSize:11]];
        [sNameL setBackgroundColor:[UIColor clearColor]];
        [bckView addSubview:sNameL];
        
        dateL = [[UILabel alloc] initWithFrame:CGRectMake(0, sNameL.frame.origin.y + sNameL.frame.size.height-5, bckView.frame.size.width, sNameL.frame.size.height)];
        [dateL setTextAlignment:NSTextAlignmentCenter];
        [dateL setTextColor:[UIColor grayColor]];
        [dateL setFont:[UIFont systemFontOfSize:10]];
        [dateL setBackgroundColor:[UIColor clearColor]];
        [bckView addSubview:dateL];
        
        statusL = [[UILabel alloc] initWithFrame:CGRectMake(0, dateL.frame.size.height + dateL.frame.origin.y - 5, 300, 65)];
        [statusL setBackgroundColor:[UIColor clearColor]];
        [statusL setTextAlignment:NSTextAlignmentCenter];
        [statusL setTextColor:[UIColor darkGrayColor]];
        [statusL setNumberOfLines:3];
        [statusL setLineBreakMode:NSLineBreakByWordWrapping];
        [statusL setFont:[UIFont systemFontOfSize:12]];
        [bckView addSubview:statusL];
        
        [self.contentView addSubview:bckView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
