//
//  LogsViewController.m
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 9/28/15.
//  Copyright © 2015 Lifewaresolutions. All rights reserved.
//

#import "LogsViewController.h"

@interface LogsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation LogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self scrollTextViewToBottom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doneClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
    if ([self.delegate respondsToSelector:@selector(logsViewControllerDone)]) {
        [self.delegate logsViewControllerDone];
    }
}

-(void)scrollTextViewToBottom {
    if (self.textView.text.length > 5) {
    NSRange range = NSMakeRange(self.textView.text.length - 5, 5);
    [self.textView scrollRangeToVisible:range];
    }
}
- (BOOL)isAtBottom {
    float bottomEdge = self.textView.contentOffset.y + self.textView.frame.size.height;
    return bottomEdge >= self.textView.contentSize.height-10;
}
-(void)addNewString:(NSString*)str {
    if (self.view){}
    BOOL isBottom = self.isAtBottom;
    self.textView.text = [self.textView.text stringByAppendingString:str];
    
    if (isBottom) {
        [self performSelector:@selector(scrollTextViewToBottom) withObject:nil afterDelay:0.01];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
