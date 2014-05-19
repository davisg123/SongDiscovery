//
//  ViewController.m
//  SongDiscovery
//
//  Created by Davis Gossage on 9/27/13.
//  Copyright (c) 2013 Davis Gossage. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "customPlayer.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

@interface ViewController ()
@property (strong, nonatomic) AVPlayer *player;
@end

@implementation ViewController


@synthesize player = _player;
NSString *songID2;
NSString *songID1;
int currentSong;
int currentChoice = 1;
AVPlayerItem *song1;
AVPlayerItem *song2;
NSInteger random1;
NSInteger random2;
NSInteger hipster;

- (void)viewDidLoad
{
    progress1.layer.cornerRadius = 12;
    progress2.layer.cornerRadius = 12;
    progress3.layer.cornerRadius = 12;
    progress4.layer.cornerRadius = 12;
    progress5.layer.cornerRadius = 12;
    progress6.layer.cornerRadius = 12;
    progress7.layer.cornerRadius = 12;
    progress8.layer.cornerRadius = 12;
    progress9.layer.cornerRadius = 12;
    progress10.layer.cornerRadius = 12;
    
    [self nextSet:0];
    [super viewDidLoad];
    outer1.layer.shadowColor = (__bridge CGColorRef)([UIColor blackColor]);
    outer1.layer.shadowOpacity = 1.0;
    outer1.layer.shadowOffset = CGSizeMake(5, 5);
    outer1.layer.cornerRadius = 5.0;
    
}

- (void)nextSet:(int)selection{
    
        random1 = arc4random() % 600;
        random2 = arc4random() % 100;
        random2 = random1 - 50 + random2;
        if (random2<0)
            random2 = 15;
        if (random2 == random1)
            random2++;
        NSLog(@"random 1 is %ld", (long)random1);
        NSLog(@"random 1 is %ld", (long)random2);

    PFQuery *query = [PFQuery queryWithClassName:@"SongPopData"];
    
    [query whereKey:@"GenreCode" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"GenreCode"]];
    [query whereKey:@"GenreRank" containedIn:[NSArray arrayWithObjects:[NSNumber numberWithInteger:random1],[NSNumber numberWithInteger:random2], nil]];
    [query orderByAscending:@"GenreCode"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"RETURNING ONCE %@", objects);
        if (!error){
            if([objects count] == 2){
                songID1 = [[objects objectAtIndex:0] objectForKey:@"SongID"];
                songID2 = [[objects objectAtIndex:1] objectForKey:@"SongID"];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Data mismatch.  Expected two results, got less..." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
            [self loadNewSongSet];
        }
    }];
}


- (void)loadNewSongSet{
    NSLog(@"RUNNING ONCE");
   // NSString *songID = @"656406081";
    //NSString *songID2 = @"465932897";
    NSString *trackInfoURL = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?country=us&id=%@", songID1];
    NSString *trackInfoURL2 = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?country=us&id=%@", songID2];
    
	// Do any additional setup after loading the view, typically from a nib.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:trackInfoURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"results"] count] == 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Song info couldn't be retrieved..." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        NSString *previewURLString = [[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"previewUrl"];
        NSString *albumArt = [[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"artworkUrl100"];
        albumArt = [albumArt stringByReplacingOccurrencesOfString:@"100x100" withString:@"600x600"];
        [albumArt1 setImageWithURL:[NSURL URLWithString:albumArt]];
        artist1.text = [[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"artistName"];
        title1.text = [[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"trackName"];
        currentSong = 1;
        
        song1 = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:previewURLString]];
        if (!self.player)
            self.player =[[AVPlayer alloc] initWithPlayerItem:song1];
        else{
            [self.player replaceCurrentItemWithPlayerItem:song1];
            [self.player play];
        }
     
        [self buffer2:manager andURL:trackInfoURL2];
        [self.player addObserver:self forKeyPath:@"status" options:0 context:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:song1];
        [[AVAudioSession sharedInstance] setActive:YES error: nil];
        
        //NSLog(@"JSON: %@", previewURLString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)finishedPlaying{
    if (currentSong == 1){
        [bar11.layer removeAllAnimations];
        [bar12.layer removeAllAnimations];
        [bar13.layer removeAllAnimations];
        [self.player replaceCurrentItemWithPlayerItem:song2];
        [self animate2];
    }
    else{
        [bar21.layer removeAllAnimations];
        [bar22.layer removeAllAnimations];
        [bar23.layer removeAllAnimations];
        [self animate1];
        [self.player replaceCurrentItemWithPlayerItem:song1];
    }
}

- (void)buffer2:(AFHTTPRequestOperationManager *)manager andURL:(NSString *)trackInfoURL2{
    [manager GET:trackInfoURL2 parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"response is %@", responseObject);
        if ([[responseObject objectForKey:@"results"] count] == 0){
            NSString *errorMessage = [NSString stringWithFormat:@"Couldn't retrieve track info, link is %@", trackInfoURL2];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        NSString *previewURLString = [[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"previewUrl"];
        NSString *albumArt = [[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"artworkUrl100"];
        albumArt = [albumArt stringByReplacingOccurrencesOfString:@"100x100" withString:@"600x600"];
        [albumArt2 setImageWithURL:[NSURL URLWithString:albumArt]];
        artist2.text = [[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"artistName"];
        title2.text = [[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"trackName"];
        song2 = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:previewURLString]];
        //self.player2 =[[AVPlayer alloc] initWithURL:[NSURL URLWithString:previewURLString]];
        //[self.player2 addObserver:self forKeyPath:@"statusofPlayer2" options:0 context:NULL];
         
        //NSLog(@"JSON: %@", previewURLString);
         
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (IBAction)selectSong1:(id)sender{
    [self increment];
    progress.text = [NSString stringWithFormat:@"%d",currentChoice];
    [self.player pause];
    PFQuery *userQuery = [PFQuery queryWithClassName:@"GlobalUserStats"];
    NSString *deviceID = CFBridgingRelease(CFUUIDCreateString(nil,(__bridge CFUUIDRef)([[UIDevice currentDevice] identifierForVendor])));
    [userQuery whereKey:@"UserID" equalTo:deviceID];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] != 0){
            PFObject *userStat = [objects objectAtIndex:0];
            [userStat incrementKey:@"TotalPicks"];
            if (random1>random2)
                [userStat incrementKey:@"HipsterPicks"];
        }
        else{
            PFObject *userStat = [PFObject objectWithClassName:@"GlobalUserStats"];
            [userStat setObject:deviceID forKey:@"UserID"];
            [userStat setObject:[NSNumber numberWithInteger:1] forKey:@"TotalPicks"];
            if (random1>random2)
                [userStat incrementKey:@"HipsterPicks"];
        }
    
    }];
    if (random1>random2)
        hipster++;

    PFObject *songStat1 = [PFObject objectWithClassName:@"SongStats"];
    PFObject *songStat2 = [PFObject objectWithClassName:@"SongStats"];
    [songStat1 setObject:songID1 forKey:@"SongID"];
    [songStat1 setObject:[NSNumber numberWithBool:TRUE] forKey:@"Chosen"];
    [songStat2 setObject:songID2 forKey:@"SongID"];
    [songStat2 setObject:[NSNumber numberWithBool:FALSE] forKey:@"Chosen"];
    [songStat1 saveInBackground];
    [songStat2 saveInBackground];
    [self animateOut:outer1];
    [self performSelector:@selector(animateOut:) withObject:outer2 afterDelay:.25];
    //[self switchIt:[NSNumber numberWithInt:1]];
}

- (void)changeto1:(id)sender{
    [self.player replaceCurrentItemWithPlayerItem:song1];
    [self.player play];
    [bar21.layer removeAllAnimations];
    [bar22.layer removeAllAnimations];
    [bar23.layer removeAllAnimations];
    [self animate1];
}

- (void)changeto2:(id)sender{
    [self.player replaceCurrentItemWithPlayerItem:song2];
    [self.player play];
    [bar11.layer removeAllAnimations];
    [bar12.layer removeAllAnimations];
    [bar13.layer removeAllAnimations];
    [self animate2];
}

- (IBAction)selectSong2:(id)sender{
    if (random2>random1)
        hipster++;
    [self increment];
    [self.player pause];
    PFObject *userStat = [PFObject objectWithClassName:@"UserStats"];
    NSString *deviceID = CFBridgingRelease(CFUUIDCreateString(nil,(__bridge CFUUIDRef)([[UIDevice currentDevice] identifierForVendor])));
    [userStat setObject:deviceID forKey:@"UserID"];
    [userStat setObject:songID1 forKey:@"Song1"];
    [userStat setObject:songID2 forKey:@"Song2"];
    [userStat setObject:[NSNumber numberWithInt:2] forKey:@"Picked"];
    [userStat saveInBackground];
    PFObject *songStat1 = [PFObject objectWithClassName:@"SongStats"];
    PFObject *songStat2 = [PFObject objectWithClassName:@"SongStats"];
    [songStat1 setObject:songID1 forKey:@"SongID"];
    [songStat1 setObject:[NSNumber numberWithBool:FALSE] forKey:@"Chosen"];
    [songStat2 setObject:songID2 forKey:@"SongID"];
    [songStat2 setObject:[NSNumber numberWithBool:TRUE] forKey:@"Chosen"];
    [songStat1 saveInBackground];
    [songStat2 saveInBackground];
    [self animateOut:outer2];
    [self performSelector:@selector(animateOut:) withObject:outer1 afterDelay:.25];
}

- (void)increment{
    currentChoice++;
    UIView *switchView;
    switch (currentChoice) {
        case 1:
            switchView = progress1;
            break;
        case 2:
            switchView = progress2;
            break;
        case 3:
            switchView = progress3;
            break;
        case 4:
            switchView = progress4;
            break;
        case 5:
            switchView = progress5;
            break;
        case 6:
            switchView = progress6;
            break;
        case 7:
            switchView = progress7;
            break;
        case 8:
            switchView = progress8;
            break;
        case 9:
            switchView = progress9;
            break;
        case 10:
            switchView = progress10;
            break;
        default:
            break;
    }
    switchView.alpha = 0;
    switchView.hidden = FALSE;
    [UIView animateWithDuration:1 animations:^{
        switchView.alpha = 1.0;
    }];
}

- (IBAction)goBack:(id)sender{
    [self.tabBarController dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)animateOut:(UIView *)viewToAnimate{
    [UIView animateWithDuration:.6 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frameShiftLeft = CGRectMake(viewToAnimate.frame.origin.x-740, viewToAnimate.frame.origin.y, viewToAnimate.frame.size.width, viewToAnimate.frame.size.height);
        viewToAnimate.frame= frameShiftLeft;
    } completion:^(BOOL finished) {
        CGRect frameShiftRight = CGRectMake(viewToAnimate.frame.origin.x+1480, viewToAnimate.frame.origin.y, viewToAnimate.frame.size.width, viewToAnimate.frame.size.height);
        viewToAnimate.frame = frameShiftRight;
        if (currentChoice == 10){
            [self complete];
            return;
        }
            

        if (viewToAnimate.tag == 3){
            [self nextSet:1];
            //bar11.hidden = TRUE;
            //bar12.hidden = TRUE;
            //bar13.hidden = TRUE;
            artist1.text = @"";
            title1.text = @"";
            albumArt1.image = NULL;
        }
        else{
            [bar21.layer removeAllAnimations];
            [bar22.layer removeAllAnimations];
            [bar23.layer removeAllAnimations];
            [self animate1];
            artist2.text = @"";
            title2.text = @"";
            albumArt2.image = NULL;
        }
         
        [UIView animateWithDuration:.6 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect frameShiftCenter = CGRectMake(viewToAnimate.frame.origin.x-740, viewToAnimate.frame.origin.y, viewToAnimate.frame.size.width, viewToAnimate.frame.size.height);
            viewToAnimate.frame = frameShiftCenter;
        } completion:nil];
    }];
}

- (void)complete{
    hipsterRank.text = [NSString stringWithFormat:@"%d%", hipster*10];
    hipsterView.hidden = FALSE;
    hipsterView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        hipsterView.alpha = 1.0;
    }];
}

- (void)switchIt:(NSNumber *) switchTo{
    
    if ([self.player rate] != 0.0){
        if ([switchTo integerValue] != 1){
            //player 1 isn't playing, switch
        }
    }

    
}

-(void)fadeOut{
    if (self.player.volume > 0.1) {
        self.player.volume = self.player.volume - 0.1;
        [self performSelector:@selector(fadeOut) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        /*
         [self.player stop];
         self.player.currentTime = 0;
         [self.player prepareToPlay];
         self.player.volume = 1.0;
         */
    }
}

-(void)fadeIn{
    if (self.player.volume < 0.1) {
        self.player.volume = self.player.volume + 0.1;
        [self performSelector:@selector(fadeIn) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        /*
         [self.player stop];
         self.player.currentTime = 0;
         [self.player prepareToPlay];
         self.player.volume = 1.0;
         */
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"playing");
            [self.player play];
            if (currentSong == 1)
                [self animate1];
            else
                [self animate2];
        } else if (self.player.status == AVPlayerStatusFailed) {
            NSLog(@"ERROR ");
            /* An error was encountered */
        }
    
    }
}

- (void)animate1{
    bar11.frame = CGRectMake(433, 174, 26, 50);
    bar12.frame = CGRectMake(462, 174, 26, 50);
    bar13.frame = CGRectMake(491, 174, 26, 50);
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        CGRect animateTo = CGRectMake(bar11.frame.origin.x, bar11.frame.origin.y-30, bar11.frame.size.width, bar11.frame.size.height+30);
        bar11.frame = animateTo;
    } completion:nil];
    [UIView animateWithDuration:.7 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        CGRect animateTo = CGRectMake(bar12.frame.origin.x, bar12.frame.origin.y-30, bar12.frame.size.width, bar12.frame.size.height+30);
        bar12.frame = animateTo;
    } completion:nil];
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        CGRect animateTo = CGRectMake(bar13.frame.origin.x, bar13.frame.origin.y-30, bar13.frame.size.width, bar13.frame.size.height+30);
        bar13.frame = animateTo;
    } completion:nil];
}

- (void)animate2{
    bar21.frame = CGRectMake(433, 174, 26, 50);
    bar22.frame = CGRectMake(462, 174, 26, 50);
    bar23.frame = CGRectMake(491, 174, 26, 50);
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        CGRect animateTo = CGRectMake(bar21.frame.origin.x, bar21.frame.origin.y-30, bar21.frame.size.width, bar21.frame.size.height+30);
        bar21.frame = animateTo;
    } completion:nil];
    [UIView animateWithDuration:.7 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        CGRect animateTo = CGRectMake(bar22.frame.origin.x, bar22.frame.origin.y-30, bar22.frame.size.width, bar22.frame.size.height+30);
        bar22.frame = animateTo;
    } completion:nil];
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        CGRect animateTo = CGRectMake(bar23.frame.origin.x, bar23.frame.origin.y-30, bar23.frame.size.width, bar23.frame.size.height+30);
        bar23.frame = animateTo;
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
