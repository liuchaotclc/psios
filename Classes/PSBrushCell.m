//
//  PSBrushCell.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSBrush.h"
#import "PSBrushCell.h"
#import "PSCellSelectionView.h"

@implementation PSBrushCell

@synthesize preview;
@synthesize size;
@synthesize editButton;
@synthesize brush;
@synthesize table;
@synthesize previewDirty;

- (void) awakeFromNib
{
    PSCellSelectionView *selectionView = [[PSCellSelectionView alloc] init];
    self.selectedBackgroundView = selectionView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    editButton.hidden = !selected;
}

- (void) brushChanged:(NSNotification *)aNotification
{
    [self setNeedsLayout];
    self.previewDirty = YES;
    
    PSProperty *prop = [aNotification userInfo][@"property"];
    if (prop && prop == brush.weight) {
        size.text = [NSString stringWithFormat:@"%d px", (int) brush.weight.value];
    }
}

- (void) setBrush:(PSBrush *)inBrush
{
    if (brush == inBrush) {
        return;
    }
    
    brush = inBrush;

    preview.image = [brush previewImageWithSize:preview.bounds.size];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushChanged:) name:PSBrushPropertyChanged object:brush];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushChanged:) name:PSBrushGeneratorChanged object:brush];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushChanged:) name:PSBrushGeneratorReplaced object:brush];
    
    size.text = [NSString stringWithFormat:@"%d px", (int) brush.weight.value];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) disclose:(id)sender
{
    [table.delegate tableView:table accessoryButtonTappedForRowWithIndexPath:[table indexPathForCell:self]];
}

- (void) layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.contentView.frame;
    // make sure our width doesn't get smaller if the reorder view is made visible
    frame.size.width = CGRectGetWidth(self.superview.frame);
    self.contentView.frame = frame;
    
    if (self.previewDirty) {
        preview.image = [brush previewImageWithSize:preview.bounds.size];
        self.previewDirty = NO;
    }
}

@end
