//
//  GenreDataViewController.m
//  SongDiscovery
//
//  Created by Davis Gossage on 9/29/13.
//  Copyright (c) 2013 Davis Gossage. All rights reserved.
//

#import "GenreDataViewController.h"
#import <Parse/Parse.h>
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>

@interface GenreDataViewController ()

@end

@implementation GenreDataViewController

NSMutableArray *data;
NSMutableArray *names;
NSMutableArray *images;
NSMutableArray *pop;
NSMutableArray *previewLinks;

AVPlayer *player;

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
    PFQuery *query = [PFQuery queryWithClassName:@"MostPopular"];
    [query whereKey:@"Genre" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"GenreCode"]];
    [query orderByDescending:@"PopPercent"];
    names = [[NSMutableArray alloc] init];
    images = [[NSMutableArray alloc] init];
    pop = [[NSMutableArray alloc] init];
    previewLinks = [[NSMutableArray alloc] init];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] != 0){
            NSLog(@"got %@", objects);
            data = [[NSMutableArray alloc] initWithArray:objects];
            [myTableView reloadData];
            for (int i=0;i<[data count];i++){
            NSString *trackInfoURL = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?country=us&id=%@", [[data objectAtIndex:i] objectForKey:@"SongID"]];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager GET:trackInfoURL parameters:Nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"got %@", responseObject);
                [names addObject:[[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"trackName"]];
                [pop addObject:[[data objectAtIndex:i] objectForKey:@"PopPercent"]];
                [images addObject:[[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"artworkUrl100"]];
                [previewLinks addObject:[[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"previewUrl"]];
                [myTableView reloadData];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //
            }];
            }

            
        }
    }];
    /*
    for (int i=0;i<100;i++){
        NSString *trackInfoURL = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?country=us&id=%@", [[objects objectAtIndex:i] objectForKey:@"song_id"]];
        //Do any additional setup after loading the view, typically from a nib.
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:trackInfoURL parameters:Nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"url %@", trackInfoURL);
            if ([[responseObject objectForKey:@"results"] count] != 0){
                [[objects objectAtIndex:i] setObject:[[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"artworkUrl100"] forKey:@"album_url"];
                [[objects objectAtIndex:i] saveInBackground];
            }
            [myCollectionView reloadData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"request failed");
        }];
    }
     */
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Top 10 Songs";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [data count];    //count number of row from counting array hear cataGorry is An Array
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:[previewLinks objectAtIndex:[indexPath row]]]];
    [player play];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    [data objectAtIndex:[indexPath row]];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:MyIdentifier] ;
    }
    if ([names count] > [indexPath row]){
        NSString *string = [NSString stringWithFormat:@"%@ (%@%%)", [names objectAtIndex:[indexPath row]], [pop objectAtIndex:[indexPath row]]];
        cell.textLabel.text = string;
        [cell.imageView setImageWithURL:[NSURL URLWithString:[images objectAtIndex:[indexPath row]]]];
        //NSLog(@"images are %@", [images objectAtIndex:[indexPath row]]);
    }
    //Do any additional setup after loading the view, typically from a nib.
        // Here we use the provided setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with no image
    return cell;
}

@end
