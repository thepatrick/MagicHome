//
//  SwitchCell.m
//  MagicHome
//
//  Created by Patrick Quinn-Graham on 8/05/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "SwitchCell.h"

#define kLeftMargin				20.0
#define kTopMargin				20.0
#define kRightMargin			20.0
#define kBottomMargin			20.0
#define kTweenMargin			10.0
#define kStdButtonWidth			106.0
#define kStdButtonHeight		40.0
#define kSegmentedControlHeight 44.0
#define kPageControlHeight		40.0
#define kSliderHeight			7.0
#define kSwitchButtonWidth		94.0
#define kSwitchButtonHeight		27.0
#define kTextFieldHeight		30.0
#define kLabelHeight			17.0


@implementation SwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switcher addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        switcher.backgroundColor = [UIColor clearColor];
        [self addSubview:switcher];
        [switcher release];
    }
    return self;
}

- (void (^)(BOOL, void (^)(BOOL, BOOL)))switchDidChange {
    return switchDidChange;
}


- (void)setSwitchDidChange:(void (^)(BOOL, void (^)(BOOL, BOOL)))block {
    if(switchDidChange != block && switchDidChange) {
        Block_release(switchDidChange);
        switchDidChange = nil;
    }
    if(block) {
        switchDidChange = Block_copy(block);
    }
}

- (void (^)(void (^)(BOOL, BOOL)))switchState {
    return switchState;
}


- (void)setSwitchState:(void (^)(void (^)(BOOL, BOOL)))block {
    if(switchState != block && switchState) {
        Block_release(switchState);
        switchState = nil;
    }
    if(block) {
        switchState = Block_copy(block);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
//    CGRect contentRect = self.contentView.frame;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
//		CGFloat boundsX = contentRect.origin.x;
        CGRect frame = CGRectMake(((94 + kLeftMargin + kSwitchButtonWidth)), kTopMargin - 10, kSwitchButtonWidth, kSwitchButtonHeight);
        switcher.frame = frame;
    }
}

- (void)switchChanged:(id)sender {
    if(switchDidChange) {
        switchDidChange(switcher.on, ^(BOOL on, BOOL enabled) {
            switcher.enabled = enabled;
            switcher.on = on;
        });
    }
}

- (void)refreshSwitcher {
    if(switchState) {
        switchState(^(BOOL on, BOOL enabled) {
            switcher.enabled = enabled;
            switcher.on = on;
        });
    }
}

@end
