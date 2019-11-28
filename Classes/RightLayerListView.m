//
//  RightLayerListView.m
//  PSIos
//
//  Created by liuchao on 2019/11/4.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import "RightLayerListView.h"
#import "PSActionSheet.h"
#import "PSActiveState.h"
#import "PSAddLayer.h"
#import "PSBar.h"
#import "PSBlendModePicker.h"
#import "PSChangeOpacity.h"
#import "PSColor.h"
#import "PSColorSlider.h"
#import "PSDeleteLayer.h"
#import "PSJSONCoder.h"
#import "PSLayer.h"
#import "PSLayerCell.h"
#import "PSLayerController.h"
#import "PSModifyLayer.h"
#import "PSRedoChange.h"
#import "PSReorderLayers.h"
#import "PSUndoChange.h"
#import "PSUpdateLayer.h"
#import "PSUtilities.h"
#import "UIImage+Additions.h"

@interface RightLayerListView (Private)
// convert from table cell order to drawing layer order and vice versa
- (NSUInteger) flipIndex_:(NSUInteger)ix;
@end

@implementation RightLayerListView

@synthesize painting = painting_;
@synthesize layerCell = layerCell_;
@synthesize opacitySlider = opacitySlider_;
@synthesize opacityLabel = opacityLabel_;
@synthesize blendModePicker;
@synthesize dirtyThumbnails;
@synthesize topBar;
@synthesize bottomBar;
@synthesize blendModeSheet;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
        [self initView];
        
    }
    return self;
}

-(void)setUpUI{
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
}

//初始化容器视图
-(void)initView{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat x=0;
    CGFloat y=0;
    CGFloat width=self.frame.size.width;
    CGFloat height=self.frame.size.height;
    
    self.opacitySlider = [[PSColorSlider alloc] initWithFrame: CGRectMake(0, height - 120, 60, 60)];


    [self.opacitySlider setMode:WDColorSliderModeAlpha];
    self.opacitySlider.hidden = YES;
    
    UIControlEvents dragEvents = (UIControlEventTouchDown | UIControlEventTouchDragInside |UIControlEventTouchDragOutside);
    [self.opacitySlider addTarget:self action:@selector(opacitySliderMoved:) forControlEvents:dragEvents];
    
    UIControlEvents touchEndEvents = (UIControlEventTouchUpInside | UIControlEventTouchUpOutside);
    [self.opacitySlider addTarget:self action:@selector(takeOpacityFrom:) forControlEvents:touchEndEvents];
    
    //创建容器视图
    _layerTable = [[UITableView alloc]initWithFrame:CGRectMake(x, y + 40, width, height - 40) style:UITableViewStylePlain];
    _layerTable.delegate=self;//设置代理
    _layerTable.dataSource=self;//设置数据源
    _layerTable.alwaysBounceVertical=FALSE;
    _layerTable.bounces=FALSE;
    _layerTable.backgroundColor = [UIColor whiteColor];//设置背景

    //添加到主视图
    [self addSubview:_layerTable];
    
    
//    [_layerTable setEditing:YES];
    _layerTable.backgroundColor = nil;
    
    [self updateRowHeight];
    
    blendModePicker.titles = WDBlendModeDisplayNames();
    blendModePicker.target = self;
    blendModePicker.action = @selector(takeBlendModeFrom:);
    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] init];
//    doubleTap.numberOfTapsRequired = 2;
//    [doubleTap addTarget:self action:@selector(done:)];
//    [_layerTable addGestureRecognizer:doubleTap];
    
        [self.topBar addEdge];
        self.topBar.ignoreTouches = NO;
        self.topBar.items = [self topBarItems];
        
        [self.bottomBar addEdge];
        self.bottomBar.ignoreTouches = NO;
        self.bottomBar.items = [self bottomBarItems];
    
    if (dirtyThumbnails) {
        [dirtyThumbnails makeObjectsPerformSelector:@selector(updateThumbnail)];
        [dirtyThumbnails removeAllObjects];
    }
    
    
    if (PSDeviceIsPhone()) {
        _layerTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    // make sure the undo/redo buttons have the correct enabled state
    [self undoStatusDidChange:nil];

    [self enableLayerButtons];
    [self selectActiveLayer];
         
    [_layerTable flashScrollIndicators];
    
}


- (void) undoStatusDidChange:(NSNotification *)aNotification
{
    undo_.enabled = [self.painting.undoManager canUndo];
    redo_.enabled = [self.painting.undoManager canRedo];
}

- (void) undo:(id)sender
{
    if ([self.painting.undoManager canUndo]) {
        changeDocument(self.painting, [PSUndoChange undoChange]);
    }
}

- (void) redo:(id)sender
{
    if ([self.painting.undoManager canRedo]) {
        changeDocument(self.painting, [PSRedoChange redoChange]);
    }
}

- (void) mergeLayerDown:(id)sender
{
    changeDocument(self.painting, [PSModifyLayer modifyLayer:self.painting.activeLayer withOperation:WDMergeLayer]);
}

- (void) done:(id)sender
{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissViewController:)]) {
//        [self.delegate performSelector:@selector(dismissViewController:) withObject:self];
//    }
    
    if (_delegate) {
           [_delegate onDismissClick];
       }
}

- (NSUInteger) minimumRowHeight
{
    return [self runningOnPhone] ? 110 : 128;
}

- (void) updateRowHeight
{
    PSLayer *layer = (painting_.layers)[0];
    _layerTable.rowHeight = MAX([self minimumRowHeight], layer.thumbnailImageHeight * 0.5 + 20);
    
    [_layerTable reloadData];
}

- (void) registerNotifications
{
    NSNotificationCenter    *defaultCenter = [NSNotificationCenter defaultCenter];
    NSUndoManager           *undoManager = painting_.undoManager;
    
    [defaultCenter addObserver:self
                      selector:@selector(undoStatusDidChange:)
                          name:NSUndoManagerDidUndoChangeNotification
                        object:undoManager];
    
    [defaultCenter addObserver:self
                      selector:@selector(undoStatusDidChange:)
                          name:NSUndoManagerDidRedoChangeNotification
                        object:undoManager];
    
    [defaultCenter addObserver:self
                      selector:@selector(undoStatusDidChange:)
                          name:NSUndoManagerWillCloseUndoGroupNotification
                        object:undoManager];
    
    [defaultCenter addObserver:self selector:@selector(activeLayerChanged:)
                          name:WDActiveLayerChangedNotification object:painting_];
    
    [defaultCenter addObserver:self selector:@selector(layerAdded:)
                          name:WDLayerAddedNotification object:painting_];
    
    [defaultCenter addObserver:self selector:@selector(layerDeleted:)
                          name:WDLayerDeletedNotification object:painting_];
    
    [defaultCenter addObserver:self selector:@selector(layerVisibilityChanged:)
                          name:WDLayerVisibilityChanged object:painting_];
    
    [defaultCenter addObserver:self selector:@selector(layerOpacityChanged:)
                          name:WDLayerOpacityChanged object:painting_];
    
    [defaultCenter addObserver:self selector:@selector(layerBlendModeChanged:)
                          name:WDLayerBlendModeChanged object:painting_];
    
    [defaultCenter addObserver:self selector:@selector(layerLockedStatusChanged:)
                          name:WDLayerLockedStatusChanged object:painting_];
    
    [defaultCenter addObserver:self selector:@selector(layerAlphaLockedStatusChanged:)
                          name:WDLayerAlphaLockedStatusChanged object:painting_];
    
    [defaultCenter addObserver:self selector:@selector(layerThumbnailChanged:)
                          name:WDLayerThumbnailChangedNotification object:painting_];
    
    [defaultCenter addObserver:self selector:@selector(layersReordered:)
                          name:WDLayersReorderedNotification object:painting_];
}

- (void) setPainting:(PSPainting *)painting
{
    if (painting == painting_) {
        return;
    }
    
    if (painting_) {
        // stop listening to the old painting
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    painting_ = painting;
    [self registerNotifications];

    [self updateRowHeight];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void) viewDidUnload
//{
//    _layerTable = nil;
//    [self.dirtyThumbnails removeAllObjects];
//}

- (void) deselectSelectedRow
{
    NSUInteger      row = [self flipIndex_:painting_.indexOfActiveLayer];
    NSIndexPath     *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    [_layerTable deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) deleteLayer:(id)sender
{
    if (painting_.layers.count == 1) {
        // if there's only 1 layer, it's simpler to just clear it
        changeDocument(painting_, [PSModifyLayer modifyLayer:painting_.activeLayer withOperation:WDClearLayer]);
    } else {
        changeDocument(painting_, [PSDeleteLayer deleteLayer:painting_.activeLayer]);
    }
}

- (void) addLayer:(id)sender
{
    NSUInteger index = [painting_ indexOfActiveLayer] + 1;
    changeDocument(painting_, [PSAddLayer addLayerAtIndex:index]);
}

- (void) duplicateLayer:(id)sender
{
    [self.painting duplicateActiveLayer];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return painting_.layers.count;
}

- (void) updateCellIndices
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (PSLayerCell *cell in _layerTable.visibleCells) {
            [cell updateIndex];
        }
    });
}

- (void) layersReordered:(NSNotification *)aNotification
{
    [self updateCellIndices];
    [self enableLayerButtons];
}

- (void) layerAdded:(NSNotification *)aNotification
{
    PSLayer *addedLayer = [aNotification userInfo][@"layer"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self flipIndex_:[painting_.layers indexOfObject:addedLayer]] inSection:0];
    
    [_layerTable beginUpdates];
    [_layerTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [_layerTable endUpdates];

    [self enableLayerButtons];
    [self updateCellIndices];
    
    // ensure that the selection indicator doesn't disappear when undoing layer reorder
    [self performSelector:@selector(selectActiveLayer) withObject:nil afterDelay:0];
}

- (void) layerDeleted:(NSNotification *)aNotification
{
    NSNumber *index = [aNotification userInfo][@"index"];
    NSUInteger row = [self flipIndex_:[index integerValue]] + 1; // add one to account for the fact that the model already deleted the entry
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    [_layerTable beginUpdates];
    [_layerTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [_layerTable endUpdates];
    
    [self enableLayerButtons];
    [self updateCellIndices];
}

- (void) activeLayerChanged:(NSNotification *)aNotification
{
    [self performSelector:@selector(selectActiveLayer) withObject:nil afterDelay:0];
    [self enableLayerButtons];
}

- (void) layerVisibilityChanged:(NSNotification *)aNotification
{
    PSLayer *layer = [aNotification userInfo][@"layer"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self flipIndex_:[painting_.layers indexOfObject:layer]] inSection:0];
    
    PSLayerCell *layerCell = (PSLayerCell *) [_layerTable cellForRowAtIndexPath:indexPath];
    
    [layerCell updateVisibilityButton];
    [self enableLayerButtons];
}

- (void) layerLockedStatusChanged:(NSNotification *)aNotification
{
    PSLayer *layer = [aNotification userInfo][@"layer"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self flipIndex_:[painting_.layers indexOfObject:layer]] inSection:0];
    
    PSLayerCell *layerCell = (PSLayerCell *) [_layerTable cellForRowAtIndexPath:indexPath];
    [layerCell updateLockedStatusButton];
    
    [self enableLayerButtons];
}

- (void) layerAlphaLockedStatusChanged:(NSNotification *)aNotification
{
    PSLayer *layer = [aNotification userInfo][@"layer"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self flipIndex_:[painting_.layers indexOfObject:layer]] inSection:0];
    
    PSLayerCell *layerCell = (PSLayerCell *) [_layerTable cellForRowAtIndexPath:indexPath];
    [layerCell updateAlphaLockedStatusButton];
}

- (void) layerBlendModeChanged:(NSNotification *)aNotification
{
    if ([self runningOnPhone]) {
        PSLayer *layer = [aNotification userInfo][@"layer"];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self flipIndex_:[painting_.layers indexOfObject:layer]] inSection:0];
        
        PSLayerCell *layerCell = (PSLayerCell *) [_layerTable cellForRowAtIndexPath:indexPath];
        [layerCell updateBlendMode];
    } else {
        [self updateBlendMode];
    }
}

- (void) layerOpacityChanged:(NSNotification *)aNotification
{
    PSLayer *layer = [aNotification userInfo][@"layer"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self flipIndex_:[painting_.layers indexOfObject:layer]] inSection:0];
    
    PSLayerCell *layerCell = (PSLayerCell *) [_layerTable cellForRowAtIndexPath:indexPath];
    [layerCell updateOpacity];
    
    [self updateOpacity];
}

- (BOOL) isVisible
{
    return (self.isHidden) ? NO : YES;
}

- (NSMutableSet *) dirtyThumbnails
{
    if (!dirtyThumbnails) {
        dirtyThumbnails = [[NSMutableSet alloc] init];
    }
    
    return dirtyThumbnails;
}

- (void) layerThumbnailChanged:(NSNotification *)aNotification
{
    if (!_layerTable) {
        return;
    }
    
    PSLayer *layer = [aNotification userInfo][@"layer"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self flipIndex_:[painting_.layers indexOfObject:layer]] inSection:0];
    
    PSLayerCell *layerCell = (PSLayerCell *) [_layerTable cellForRowAtIndexPath:indexPath];
    
    if (layerCell) {
        [self isVisible] ? [layerCell updateThumbnail] : [self.dirtyThumbnails addObject:layerCell];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LayerCell";
    PSLayer         *layer = (painting_.layers)[[self flipIndex_:indexPath.row]];
    
    PSLayerCell *cell = (PSLayerCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSString *nibName = @"LayerCell";
        [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        cell = layerCell_;
        self.layerCell = nil;
        cell.delegate = self;
        
        [self.layerCell.blendModeButton addTarget:self action:@selector(blendModeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.paintingLayer = layer;
    
    return cell;
}
     
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return ((UITextField *)textField.superview.superview).selected;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath == destinationIndexPath) {
        return;
    }

    NSUInteger srcIndex = sourceIndexPath.row;
    NSUInteger destIndex = destinationIndexPath.row;
    
    srcIndex = [self flipIndex_:srcIndex];
    destIndex = [self flipIndex_:destIndex];
    
    changeDocument(self.painting, [PSReorderLayers moveLayer:(painting_.layers)[srcIndex] toIndex:(int)destIndex]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
    NSUInteger index = [self flipIndex_:newIndexPath.row];
    
    [painting_ activateLayerAtIndex:index];
    
    [deletebtn setEnabled:[painting_ canDeleteLayer]];
    
    if (delete_) {
        delete_.enabled = [painting_ canDeleteLayer];
    }
}

- (void) scrollToSelectedRowIfNotVisible
{
    UITableViewCell *selected = [_layerTable cellForRowAtIndexPath:[_layerTable indexPathForSelectedRow]];

    // if the cell is nil or not completely visible, we should scroll the table
    if (!selected || !CGRectIntersectsRect(selected.frame, _layerTable.bounds)) {
        [_layerTable scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (void) selectActiveLayer
{
    [self updateOpacity];
    [self updateBlendMode];
    
    NSUInteger  activeRow = [self flipIndex_:painting_.indexOfActiveLayer];
    
    if ([[_layerTable indexPathForSelectedRow] isEqual:[NSIndexPath indexPathForRow:activeRow inSection:0]]) {
        [self scrollToSelectedRowIfNotVisible];
        return;
    }
    
    for (NSUInteger i = 0; i < painting_.layers.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        if (i != activeRow) {
            [_layerTable cellForRowAtIndexPath:indexPath].selected = NO;
            [_layerTable deselectRowAtIndexPath:indexPath animated:NO];
        } else {
            
            [_layerTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (PSBar *) topBar
{
    if (!topBar) {
        PSBar *aBar = [PSBar topBar];
        CGRect frame = aBar.frame;
        frame.size.width = CGRectGetWidth(self.bounds);
        aBar.frame = frame;
        
        [self addSubview:aBar];
        self.topBar = aBar;
    }
    
    return topBar;
}

- (PSBar *) bottomBar
{
    if (!bottomBar) {
        PSBar *aBar = [PSBar bottomBar];
        CGRect frame = aBar.frame;
        frame.origin.y  = CGRectGetHeight(self.bounds) - CGRectGetHeight(aBar.frame);
        frame.size.width = CGRectGetWidth(self.bounds);
        aBar.frame = frame;
        
        [self addSubview:aBar];
        self.bottomBar = aBar;
    }
    
    return bottomBar;
}

- (NSArray *) topBarItems
{
    delete_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"trash.png"] target:self action:@selector(deleteLayer:)];
    add_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"add.png"] target:self action:@selector(addLayer:)];
    duplicate_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"duplicate.png"] target:self action:@selector(duplicateLayer:)];
                            
    NSMutableArray *items = [NSMutableArray arrayWithObjects: delete_, [PSBarItem flexibleItem], duplicate_, add_, nil];
    
    return items;
}

- (NSArray *) bottomBarItems
{
    merge_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"merge.png"]
                                  target:self action:@selector(mergeLayerDown:)];
    
    undo_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"undo.png"]
                                 target:self action:@selector(undo:)];
    
    redo_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"redo.png"]
                                 target:self action:@selector(redo:)];

    PSBarItem *dismiss = [PSBarItem barItemWithImage:[UIImage imageNamed:@"dismiss.png"]
                                              target:self action:@selector(done:)];
    
//    NSMutableArray *items = [NSMutableArray arrayWithObjects:merge_, [WDBarItem flexibleItem],
//                             undo_, [WDBarItem flexibleItem],
//                             redo_, [WDBarItem flexibleItem],
//                             dismiss, nil];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects: [PSBarItem flexibleItem],
                               dismiss, nil];
    
    return items;
}

- (BOOL) runningOnPhone
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
}

- (void) enableLayerButtons
{
    
    [deletebtn setEnabled:[painting_ canDeleteLayer]];
  
    BOOL enabled = [painting_ canAddLayer];
    
    [addbtn setEnabled:enabled];
  
    if (delete_) {
        delete_.enabled = [painting_ canDeleteLayer];
        duplicate_.enabled = enabled;
        add_.enabled = enabled;
    }
    
    if (merge_) {
        ((UIBarButtonItem *)merge_).enabled = [painting_ canMergeDown];
    }
}

- (void) updateOpacity
{
    opacitySlider_.color = [PSColor colorWithWhite:1.0 alpha:painting_.activeLayer.opacity];
    
    int rounded = round(painting_.activeLayer.opacity * 100);
    opacityLabel_.text = [NSString stringWithFormat:@"%d%%", rounded];
}

- (void) updateBlendMode
{
    NSUInteger blendIx = painting_.activeLayer.blendMode;
    
    blendIx = [PSBlendModes() indexOfObject:@(blendIx)];
    
    if (blendModePicker.selectedIndex != blendIx) {
        [blendModePicker chooseItemAtIndexSilent:blendIx];
    }
}

- (void) opacitySliderMoved:(PSColorSlider *)sender
{
    int rounded = round(sender.floatValue * 100);
    opacityLabel_.text = [NSString stringWithFormat:@"%d%%", rounded];
    
    PSLayerCell *cell = (PSLayerCell *) [_layerTable cellForRowAtIndexPath:[_layerTable indexPathForSelectedRow]];
    [cell setOpacity:sender.floatValue];

    opacitySlider_.color = [PSColor colorWithWhite:1.0 alpha:sender.floatValue];
}

- (void) takeBlendModeFrom:(PSBlendModePicker *)picker
{
    NSUInteger modeIndex = picker.selectedIndex;
    NSNumber *blendModeValue = PSBlendModes()[modeIndex];
    PSBlendMode mode = (PSBlendMode) blendModeValue.integerValue;
    
    [self setBlendMode:mode forLayer:painting_.activeLayer];
}

- (void) takeOpacityFrom:(PSColorSlider *)sender
{
    float opacity = sender.floatValue;
    PSLayer *layer = painting_.activeLayer;
    if (opacity != layer.opacity) {
        changeDocument(painting_, [PSChangeOpacity changeOpacity:opacity forLayer:layer]);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (UIView *) rotatingHeaderView
{
    return self.topBar;
}

- (UIView *) rotatingFooterView
{
    return self.bottomBar;
}

- (void) setBlendMode:(PSBlendMode)mode forLayer:(PSLayer *)layer
{
    NSString *format = NSLocalizedString(@"Blend Mode: %@", @"Blend Mode: %@");
    NSString *actionName = [NSString stringWithFormat:format, WDDisplayNameForBlendMode(mode)];
    [[painting_ undoManager] setActionName:actionName];
    
    if (mode != layer.blendMode) {
        PSJSONCoder *coder = [[PSJSONCoder alloc] initWithProgress:nil];
        PSLayer *updated = [coder copy:layer deep:NO];
        updated.blendMode = mode;
        changeDocument(painting_, [PSUpdateLayer updateLayer:updated]);
    }
}

- (void) editBlendModeForLayer:(PSLayer *)layer
{
//    self.blendModeSheet = [WDActionSheet sheet];
//
//    __unsafe_unretained WDLayerController *layerController = self;
//
//    for (NSNumber *mode in WDBlendModes()) {
//        [blendModeSheet addButtonWithTitle:WDDisplayNameForBlendMode((WDBlendMode)mode.integerValue)
//                                    action:^(id sender) {
//                                        [layerController setBlendMode:(WDBlendMode)mode.integerValue forLayer:layer];
//                                    }];
//    }
//
//    [blendModeSheet addCancelButton];
//
//    blendModeSheet.delegate = self;
//    [blendModeSheet.sheet showInView:self.view];
}

- (void) actionSheetDismissed:(PSActionSheet *)actionSheet
{
    if (actionSheet == blendModeSheet) {
        self.blendModeSheet = nil;
    }
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

@end

@implementation RightLayerListView (Private)

- (NSUInteger) flipIndex_:(NSUInteger)ix
{
    return (painting_.layers.count - ix - 1);
}

@end
