//
//  ViewContato.m
//  SidebarDemo
//
//  Created by Fabricio Aguiar de Padua on 08/05/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import "ViewContato.h"
#import "SWRevealViewController.h"
#import <sys/utsname.h>


@interface ViewContato ()

@end

@implementation ViewContato

@synthesize contato;
@synthesize contarumamigo;
@synthesize site;

@synthesize ViewApper;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    
    contato.layer.cornerRadius = 6.0f;
    contato.layer.masksToBounds = YES;
    
    contarumamigo.layer.cornerRadius = 6.0f;
    contarumamigo.layer.masksToBounds = YES;

    site.layer.cornerRadius = 6.0f;
    site.layer.masksToBounds = YES;
    
    //UIImage *image = [UIImage imageNamed:@"LogoProMasterSolution"];
   // self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    //	[self dismissModalViewControllerAnimated:YES];
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)btnContato:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        //[[mailer navigationBar] setTintColor:[UIColor whiteColor]];
        
        [mailer setSubject:@"Contato App Revide - iOS"];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"comercial@promastersolution.com.br", nil];
        [mailer setToRecipients:toRecipients];
        // only for iPad
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:mailer animated:YES completion:^{NSLog (@"Action Completed");}];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Falha"
                                                        message:@"Este dispositivo não suporta o envio de e-mail."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)btnContarAmigo:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [[mailer navigationBar] setTintColor:[UIColor whiteColor]];
        
        [mailer setSubject:@"App Central do Café"];
        
        NSString *emailBody = @"Olá,\n\n Estou utilizando o AppGrow \n\n Baixe ele na Itunes.";
        
        [mailer setMessageBody:emailBody isHTML:YES];
        
        // only for iPad
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:mailer animated:YES completion:^{NSLog (@"Action Completed");}];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Falha"
                                                        message:@"Este dispositivo não suporta o envio de e-mail."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)btnSite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.promastersolution.com.br"]];
    
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
