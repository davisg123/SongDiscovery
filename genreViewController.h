//
//  genreViewController.h
//  SongDiscovery
//
//  Created by Davis Gossage on 9/28/13.
//  Copyright (c) 2013 Davis Gossage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface genreViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;

@end
