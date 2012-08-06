//
//  NoteContentViewController.m
//  PCSNote
//
//  Created by Yongmo Liang on 7/24/12.
//  Copyright (c) 2012 Baidu Inc. All rights reserved.
//

#import "NoteContentViewController.h"

@interface NoteContentViewController () {
    NSString *content;
    NSString *modifiedDate;
    NSString *fileName;
}

@end

extern NSString *accessToken;


@implementation NoteContentViewController

@synthesize titleFiled;
@synthesize timeLabel;
@synthesize isEditMode;
@synthesize textView;
@synthesize detailFile;


- (void) saveFileWithTitle:(NSString *)fileTitle Content:(NSString *) fileContent
{
    NSString *finalFileName = [[[fileTitle stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByAppendingFormat:@"%@", @".txt"];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:finalFileName];
    NSLog(@"path: %@",filePath);
    [[fileContent dataUsingEncoding:NSUTF8StringEncoding] writeToFile:filePath atomically:YES];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSLog(@"File Exists!!!!");
    }
    
    NSString *baseUrl = @"https://pcs.baidu.com/rest/2.0/pcs/file?";
    baseUrl = [baseUrl stringByAppendingFormat:@"access_token=%@&method=%@&path=/apps/云端记事本/%@",
               accessToken, @"upload", finalFileName];
    baseUrl = [baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Upload Request: %@", baseUrl);
    
    NSURL *url = [NSURL URLWithString:baseUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *params = [[NSString alloc] initWithFormat:@"&file=%@", filePath];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Response Data: %@", data);
    NSLog(@"HTTP Response Status: %d", [response statusCode]);

    
    if ([data length] > 0 && error == nil)
    {
        
    } else if ([data length] ==0 && error == nil) {
        NSLog(@"No Data");
    } else if  (error) {
        NSLog(@"Error Code: %d", error.code);
    }
}

- (IBAction) navigationItemAction:(id)sender
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Save"]) {
        // Save a note
        
        [self saveFileWithTitle:titleFiled.text Content:self.textView.text];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        // Edit a note
        self.navigationItem.rightBarButtonItem.title = @"Save";
        [self.textView setEditable:YES];
        [self.textView becomeFirstResponder];
    }
}

- (NSString *)getCurrentDateTime
{
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    
    NSString *dateString = [dataFormatter stringFromDate:tmpDate];
    return dateString;
}

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (isEditMode == YES) {
        self.navigationItem.rightBarButtonItem.title = @"Save";
        titleFiled.text = @"";
        textView.text = @"";
        [self.titleFiled becomeFirstResponder];
        [self.navigationItem setTitle:@"New Note"];
        [self.timeLabel setText:[self getCurrentDateTime]];
    } else {
        [self.textView setEditable:NO];
        
        NSDateFormatter *fomatter = [[NSDateFormatter alloc] init];
        [fomatter setDateFormat:@"MM-dd HH:mm"];
        NSDate *fileMDate = [NSDate dateWithTimeIntervalSince1970:[[detailFile objectForKey:@"mtime"] intValue]];
        modifiedDate = [fomatter stringFromDate:fileMDate];
        
        fileName = [[detailFile objectForKey:@"path"] lastPathComponent];
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];

        content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        self.navigationItem.rightBarButtonItem.title = @"Edit";
        [self.timeLabel setText:modifiedDate];
        [self.textView setText:content];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
