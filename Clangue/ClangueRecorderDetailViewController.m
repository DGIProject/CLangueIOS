//
//  ClangueRecorderDetailViewController.m
//  Clangue
//
//  Created by guillaume on 09/10/13.
//  Copyright (c) 2013 DoTProjects. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ClangueRecorderDetailViewController.h"

@interface ClangueRecorderDetailViewController ()
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer* _timer;
    UIAlertView* _alert;
    NSURL* recordedFile;
    BOOL isTransfered;
}
@end

@implementation ClangueRecorderDetailViewController

#pragma mark - Managing the detail item

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    //Call Api and Get the Json code
    NSLog(@"ALLO");
    NSLog(@"id: %@",_subjectId);
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://clangue.net/api/IOS/getHomework.php?s=" stringByAppendingString:_subjectId]]];
    //NSLog(@"%@",jsonData);
    NSError* error;
    NSDictionary *dit = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        //Get values from this dict using respective keys
        NSDictionary *msgs = [dit objectForKey:@"data"];
        NSNumber *ident = [msgs objectForKey:@"id"];
        NSString *enonce = [NSString stringWithFormat:@"%@",[msgs objectForKey:@"enonce"]];
        NSLog(@"%@",ident);
        NSLog(@"%@",enonce);
        [_enonce loadHTMLString:enonce baseURL:nil];
    }
    else {
        //Your error message
    }
    
    [_playButton setImage:[UIImage imageNamed:@"glyphicons_173_play.png"] forState:UIControlStateNormal];
    [_recordPauseButton setImage:[UIImage imageNamed:@"glyphicons_169_record"] forState:UIControlStateNormal];
    [_stopButton setImage:[UIImage imageNamed:@"glyphicons_175_stop.png"] forState:UIControlStateNormal];
    // Disable Stop/Play button when application launches
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:NO];
    
    // Set the audio file
    recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:.01f
                                                  target:self
                                                selector:@selector(timerUpdate)
                                                userInfo:nil
                                                 repeats:YES];

        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        //[_recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    }
    [_recordPauseButton setEnabled:NO];
    [_stopButton setEnabled:YES];
    [_playButton setEnabled:NO];
}

- (IBAction)stopTapped:(id)sender {
    if (player.playing) {
        [player stop];
        
    }
    else{
        [recorder stop];
        [_timer invalidate];
        _timer = nil;
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        _alert = [[UIAlertView alloc] init];
        [_alert setTitle:@"Waiting.."];
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.frame = CGRectMake(140,
                                    80,
                                    CGRectGetWidth(_alert.frame),
                                    CGRectGetHeight(_alert.frame));
    
    
        [_alert addSubview:activity];
        [activity startAnimating];
    
        [_alert show];
        
        [NSThread detachNewThreadSelector:@selector(toMp3) toTarget:self withObject:nil];
     }
    [_playButton setEnabled:YES];
    [_stopButton setEnabled:NO];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)playTapped:(id)sender {
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        [_playButton setEnabled:NO];
        [_stopButton setEnabled:YES];
    }
}

- (IBAction)SendTapped:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Cofirmation"];
    [alert setMessage:@"Êtes vous sur vouloir valider votre sujet ? Apres ça il sera impossible de revenir en arrière."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert show];    
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    //[_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [_recordPauseButton setImage:[UIImage imageNamed:@"glyphicons_169_record"] forState:UIControlStateNormal];
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:YES];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
- (void) timerUpdate
{
    if (recorder.recording)
    {
        int m = recorder.currentTime / 60;
        int s = ((int) recorder.currentTime) % 60;
        
        _timeText.text = [NSString stringWithFormat:@"%d minute(s) %d sconde(s)", m, s];
    }
}
- (void) toMp3
{
    NSString *cafFilePath =[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"];
    
    NSString *mp3FileName = @"Mp3File";
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3FileName];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        NSLog(@"eee");
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void) convertMp3Finish
{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    
    _alert = [[UIAlertView alloc] init];
    [_alert setTitle:@"Finish"];
    [_alert addButtonWithTitle:@"OK"];
    [_alert setCancelButtonIndex: 0];
    [_alert show];
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    NSLog(@"tetetetetetetet");

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"Send");
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        _alert = [[UIAlertView alloc] init];
        [_alert setTitle:@"Envoi en cours..."];
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.frame = CGRectMake(140,
                                    80,
                                    CGRectGetWidth(_alert.frame),
                                    CGRectGetHeight(_alert.frame));
        
        
        [_alert addSubview:activity];
        [activity startAnimating];
        
        [_alert show];
        
        [NSThread detachNewThreadSelector:@selector(sendData) toTarget:self withObject:nil];

    }
    else if (buttonIndex == 1)
    {
        NSLog(@"cancel");
    }
}

-(void)sendData
{
    NSString *mp3FileName = @"Mp3File";
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3FileName];
    
    @try{
        
    
    NSData *data = [NSData dataWithContentsOfFile:mp3FilePath];

    if (data != nil)
    {
       NSString *filenames = [NSString stringWithFormat:@"TextLabel"];      //set name here
        NSLog(@"%@", filenames);
        
        
        NSString *partirl = [@"w=" stringByAppendingString:[_homeworkId stringByAppendingString:[@"&u=" stringByAppendingString:_username]]];
        NSString *urlString =[ @"http://clangue.net/model/student/upload.php?" stringByAppendingString:partirl];
        
        NSLog(@"%@",urlString);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[filenames dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\"record.mp3\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:data]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        // now lets make the connection to the web
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",returnString);
        if ([returnString isEqual:@"success"])
        {
            isTransfered = YES;
        }        
        NSLog(@"finish");
        }//end if
    }//end try
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            [self performSelectorOnMainThread:@selector(sendFinished)
                                   withObject:nil
                                waitUntilDone:YES];
        }

    
}
-(void)sendFinished
{
    if (isTransfered)
    {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        [_alert dismissWithClickedButtonIndex:0 animated:YES];
        
        _alert = [[UIAlertView alloc] init];
        [_alert setTitle:@"Enregistrement envoyé avec succè! Vous allez être redirigé vers la liste des sujets"];
        [_alert addButtonWithTitle:@"OK"];
        [_alert setCancelButtonIndex: 0];
        [_alert show];
        NSLog(@"Validation du sujet dans la base");
        NSArray *viewControllers = [self.navigationController viewControllers];
        ClangueRecorderMasterViewController *master = (ClangueRecorderMasterViewController *)[viewControllers objectAtIndex:viewControllers.count - 2];
        master.detailItem = _username;
        master.firstLoad = @"false";
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [_alert dismissWithClickedButtonIndex:0 animated:YES];
        
        _alert = [[UIAlertView alloc] init];
        [_alert setTitle:@"Une erreur s'est produite. Vous allez être redirigé vers la liste des sujets"];
        [_alert addButtonWithTitle:@"OK"];
        [_alert setCancelButtonIndex: 0];
        [_alert show];

        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        NSLog(@"Error");
    }
}

@end
