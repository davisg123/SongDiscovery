//
//  genreViewController.m
//  SongDiscovery
//
//  Created by Davis Gossage on 9/28/13.
//  Copyright (c) 2013 Davis Gossage. All rights reserved.
//

#import "genreViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"

@interface genreViewController ()

@end

@implementation genreViewController

NSArray *genreData;
NSMutableArray *albumArtData;

@synthesize myCollectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    UINib *cellNib = [UINib nibWithNibName:@"genreCell" bundle:nil];
    [myCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    [super viewDidLoad];
    albumArtData = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"SongPopGenre"];
    [query whereKey:@"genre_rank" equalTo:[NSNumber numberWithInteger:1]];
    [query orderByAscending:@"genre_id"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            NSLog(@"objects are %@", objects);
            NSLog(@"found %d objects", objects.count);
            NSLog(@"class of subarray is %@", [[objects objectAtIndex:0] class]);
            genreData = [[NSArray alloc] initWithArray:objects];
            [myCollectionView reloadData];
            NSLog(@"got objects %@", objects);
    }
    }];
        //else{
        //    NSLog(@"error fetching");
        //}
         //   }];
    
	// Do any additional setup after loading the view.
}

// DataSource - optional method
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

// DataSource - mandatory methods
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return genreData.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *blockData = [genreData objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"cvCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    titleLabel.layer.shadowColor = (__bridge CGColorRef)([UIColor blackColor]);
    titleLabel.layer.shadowRadius = 5;
    [titleLabel setText:[NSString stringWithFormat:@"%@", [blockData objectForKey:@"genre_name"]]];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:2];
    if ([blockData objectForKey:@"album_url"]){
        NSLog(@"loading image");
        [imageView setImageWithURL:[NSURL URLWithString:[blockData objectForKey:@"album_url"]]];
    }
    else
        imageView.image = NULL;
    return cell;
}

// Delegate - optional method
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *blockData = [genreData objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:[blockData objectForKey:@"genre_id"] forKey:@"GenreCode"];
    [self performSegueWithIdentifier:@"toSongCompare" sender:nil];
    
    //NSString *cellData = [contentArray objectAtIndex:indexPath.row];
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"You have selected %@ item",cellData] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //[alert show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
