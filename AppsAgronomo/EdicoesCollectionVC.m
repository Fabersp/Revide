//
//  EdicoesCollectionVC.m
//  AppsAgronomo
//
//  Created by Fabricio Padua on 12/07/16.
//  Copyright © 2016 Fabricio Padua. All rights reserved.
//

#import "EdicoesCollectionVC.h"
#import "MBProgressHUD.h"
#import <Photos/Photos.h>
#import "Reachability.h"
#import <TSMessages/TSMessageView.h>
#import "EdicoesColletionCell.h"
#import "QuartzCore/QuartzCore.h"


@implementation EdicoesCollectionVC

@synthesize pageImages;
@synthesize pastaEdicao;
@synthesize ObjetoJson;
@synthesize ID_Edicao;
@synthesize VarAno;





static NSString * const reuseIdentifier = @"Cell";

const CGFloat leftAndRightPaddings = 32.0;
const CGFloat numberOfItemsPerRow = 2.0;
const CGFloat heigthAdjustment = 70.0;

CGFloat width = 0.0;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat varWidth = [UIScreen mainScreen].bounds.size.width;
    width = ((varWidth - leftAndRightPaddings) / numberOfItemsPerRow);
    self.title = VarAno;
    
}

-(void)MensagemErro{
    
    // Add a button inside the message
    [TSMessage showNotificationInViewController:self
                                          title:@"Sem conexão com a intenet"
                                       subtitle:nil
                                          image:nil
                                           type:TSMessageNotificationTypeError
                                       duration:10.0
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:^{
                                     NSLog(@"User tapped the button");
                                     
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
}


-(void) viewWillAppear:(BOOL)animated
{
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName:@"www.revide.com.br"];
    [hostReachable startNotifier];
    
    // now patiently wait for the notification
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) checkNetworkStatus:(NSNotification *)notice {
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable: {
            self->internetActive = NO;
            [self MensagemErro];
            break;
        }
        case ReachableViaWiFi: {
            self->internetActive = YES;
            [self Loading];
            break;
        }
        case ReachableViaWWAN: {
            self->internetActive = YES;
            [self Loading];
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus) {
        case NotReachable: {
            NSLog(@"Estamos com instabilidade no site neste momento, tente mais tarde...");
            self->hostActive = NO;
            break;
        }
        case ReachableViaWiFi: {
            self->hostActive = YES;
            break;
        }
        case ReachableViaWWAN: {
            self->hostActive = YES;
            break;
        }
    }
}

-(void)LoadingPaginas{
    
    if (internetActive){
        
        NSString * UrlMontadada = [NSString stringWithFormat:@"http://www.revide.com.br/api_revide/paginasedicao.php?id=%@", ID_Edicao];
        
        NSURL  *url = [NSURL URLWithString:UrlMontadada];
        
        NSURLSession * session = [NSURLSession sharedSession];
        
        NSURLSessionDownloadTask * task =
        [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            NSData * jsonData = [[NSData alloc] initWithContentsOfURL:location];
            
            PathsPaginas = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
        }];
        [task resume];
        
    }
}


- (UIView *)collectionView:(UICollectionView *)collection viewForHeaderInSection:(NSInteger)section {

    if(section == 0) {
        CGFloat viewWidth = CGRectGetWidth(self.view.frame);
        
        viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 50)];
        [viewHeader setBackgroundColor:[UIColor clearColor]];
        
        // Tying up the segmented control to a scroll view
        self.segmentedControl4 = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 50)];
        self.segmentedControl4.sectionTitles = @[@"Cinema", @"Teatro", @"Música", @"Evento", @"Literatura"];
        self.segmentedControl4.selectedSegmentIndex = 0;
        self.segmentedControl4.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
        self.segmentedControl4.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        self.segmentedControl4.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]};
        self.segmentedControl4.selectionIndicatorColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
        self.segmentedControl4.selectionStyle = HMSegmentedControlSelectionStyleBox;
        self.segmentedControl4.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        self.segmentedControl4.tag = 3;
        [self.segmentedControl4 addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        
        [viewHeader addSubview:self.segmentedControl4];
        
        return viewHeader;
        
    }
    return nil;
}

-(void) SetarEdicoes_Default{
    
    NSURL * url = [NSURL URLWithString:@"http://www.revide.com.br/api_revide/listaEdicoes_ios.php"];
    
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask * task =
    [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData * jsonData = [[NSData alloc] initWithContentsOfURL:location];
        ListarNumEdicoes = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Perguntar se quer apagar ou não //
            if ([self checkIfDirectoryAlreadyExists:@"Revista"]) {
                
                UIAlertController * view =  [UIAlertController
                                             alertControllerWithTitle:@"Mensagem"
                                             message:@"Deseja excluir todas as Edições?"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"Sim"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          
                                          [self removeImage:@"Revista"];
                                          
                                          // limpar os dados salvos para voltar o botao ativo //
                                          NSUserDefaults * btnDownload = [NSUserDefaults standardUserDefaults];
                                          
                                          for (NSInteger i = 0; i < ListarNumEdicoes.count; i ++) {
                                              
                                              NSString * ID = [[ListarNumEdicoes objectAtIndex:i] objectForKey:@"edicao"];
                                              
                                              [btnDownload setBool:false forKey:ID];
                                              
                                          }
                                          
                                          [btnDownload synchronize];
                                          
                                          [self.collectionView reloadData];
                                          
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          
                                      }];
                UIAlertAction* cancel = [UIAlertAction
                                         actionWithTitle:@"Não"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [view dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                
                [view addAction:ok];
                [view addAction:cancel];
                [self presentViewController:view animated:NO completion:nil];
                
            } else {
                UIAlertController * view=   [UIAlertController
                                             alertControllerWithTitle:@"Mensagem"
                                             message:@"Não existem edições para ser excluída"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          
                                      }];
                [view addAction:ok];
                [self presentViewController:view animated:NO completion:nil];
            }

        });
    }];
    [task resume];
}




- (IBAction)btnExcluirEdicoes:(id)sender {
    
    // Perguntar se quer apagar ou não //
    if ([self checkIfDirectoryAlreadyExists:@"Revista"]) {
        
        UIAlertController * view =  [UIAlertController
                                     alertControllerWithTitle:@"Mensagem"
                                     message:@"Deseja excluir todas as Edições??"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction
                              actionWithTitle:@"Sim"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  [self removeImage:@"Revista"];
                                  
                                  // limpar os dados salvos para voltar o botao ativo //
                                  NSUserDefaults * btnDownload = [NSUserDefaults standardUserDefaults];
                                  
                                  for (NSInteger i = 0; i < EdicaoParaBaixar.count; i ++) {
                                      
                                      NSString * ID = [[EdicaoParaBaixar objectAtIndex:i] objectForKey:@"edicao"];
                                      
                                      [btnDownload setBool:false forKey:ID];
                                      
                                  }
                                  
                                  [btnDownload synchronize];
                                  
                                  [self.collectionView reloadData];
                                  
                                  [view dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Não"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [view addAction:ok];
        [view addAction:cancel];
        [self presentViewController:view animated:NO completion:nil];
        
    } else {
        UIAlertController * view=   [UIAlertController
                                     alertControllerWithTitle:@"Mensagem"
                                     message:@"Não existem edições para ser excluída"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  [view dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
        [view addAction:ok];
        [self presentViewController:view animated:NO completion:nil];
    }
}

- (void)removeImage:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"Pasta Apagada %@ ", filename);
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}




-(void)Loading {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

   
    NSString * UrlMontadada = [NSString stringWithFormat:@"http://www.revide.com.br/api_revide/edicaoporano_ios.php?Ano=%@",VarAno];
    
    NSURL * url = [NSURL URLWithString:UrlMontadada];
    
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask * task =
    [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData * jsonData = [[NSData alloc] initWithContentsOfURL:location];
        EdicaoParaBaixar = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            hud.hidden = YES;
            
        });
    }];
    [task resume];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Edicao = [[EdicaoParaBaixar objectAtIndex:indexPath.row] objectForKey:@"edicao"]; // ex. ID = 1
    // abrir NSUserDefaults * btnDownload pra ver se foi setado o valor true
    
    ID_Edicao = [[EdicaoParaBaixar objectAtIndex:indexPath.row] objectForKey:@"Id_revista"];
    
    NSUserDefaults * btnDownload = [NSUserDefaults standardUserDefaults];
    bool Verificar = [btnDownload boolForKey:Edicao];
    
      
    NSString * pasta    = [NSString stringWithFormat:@"Revista/%@",Edicao];
   
    
    if (!Verificar){
        if (internetActive){
            
            [self LoadingPaginas];
            
            UIAlertController * view =  [UIAlertController
                                         alertControllerWithTitle:@"Mensagem"
                                         message:@"Deseja realizar o download desta edição?"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * ok = [UIAlertAction
                                  actionWithTitle:@"Sim"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      
                                      // verifica qual é o ID que será setado na memória //
                                      if (![self checkIfDirectoryAlreadyExists:@"Revista"]) {
                                          [self criarPasta:@"Revista"];
                                      }
                                      
                                      if (![self checkIfDirectoryAlreadyExists:pasta]) {
                                          [self criarPasta:pasta];
                                          MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                          
                                          // Set the bar determinate mode to show task progress.
                                         // hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
                                          
                                          hud.mode = MBProgressHUDModeDeterminate;
                                          //hud.labelText = @"Carregando...";
                                          
                                          hud.dimBackground = YES;

                                          
                                          dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                                              // Do something useful in the background and update the HUD periodically.
                                              [self DonwloadImagens:pasta];
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  hud.hidden = YES;
                                                  // ex. ID = 1  e o Sender = 0
                                                  if (internetActive){
                                                      NSUserDefaults * btnDownload = [NSUserDefaults standardUserDefaults];
                                                      [btnDownload setBool:true forKey:Edicao];
                                                      [btnDownload synchronize];
                                                  
                                                      [self VisualizarEdicao:pasta];
                                                  }
                                              });

                                              
                                              
                                          });
                                      }
                                      [view dismissViewControllerAnimated:YES completion:nil];
                                      
                                  }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Não"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [view dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            
            [view addAction:ok];
            [view addAction:cancel];
            [self presentViewController:view animated:NO completion:nil];
        }else {
            [self MensagemErro];
        }
        
    } else {
        [self VisualizarEdicao:pasta];
    }
}

-(void)DonwloadImagens :(NSString * ) pasta {
    

    NSInteger Paginas = [[[PathsPaginas objectAtIndex:0] objectForKey:@"totalpaginas"] integerValue];
    
    for ( NSInteger i = 0; i < Paginas; i++){
        
        NSInteger numpagina = [[[PathsPaginas objectAtIndex:i] objectForKey:@"pagina"] integerValue];
        
        NSString * Contador = [NSString stringWithFormat:@"%.3ld.jpg", (long)numpagina];
        
        NSString * UrlMontadada = [[PathsPaginas objectAtIndex:i] objectForKey:@"imagem"];
        
        NSURL  *url = [NSURL URLWithString:UrlMontadada];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData ) {
            // pega o nome do arquivo //
            //NSArray *parts = [UrlMontadada componentsSeparatedByString:@"/"];
            NSString *filename = Contador;     // [parts lastObject];
            
            // busca a pasta oficial do App //
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            // add na frente da pasta ofical o caminho ex: /Revista/Edicao22  //
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:pasta];
            // monta o caminho para ser salvo os aquivos //
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", dataPath, filename];
            // salva os aquivos na pasta //
            //saving is done on main thread
            float ratio = (float)i  / (float)Paginas;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Instead we could have also passed a reference to the HUD
                // to the HUD to myProgressTask as a method parameter.
                [MBProgressHUD HUDForView:self.navigationController.view].progress = (float)ratio;
            });
            usleep(50000);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
            });
        }
    }
}






- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return EdicaoParaBaixar.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EdicoesColletionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // add a border
    

//    [cell.layer setBorderColor:[UIColor grayColor].CGColor];
//    [cell.layer setBorderWidth:1.0];
//    cell.layer.cornerRadius = 3; // optional
//    
//    cell.layer.shadowOffset = CGSizeMake(4, 4);
//    cell.layer.shadowOpacity = 0.5;
//    cell.layer.shadowRadius = 4.0;
    
    cell.lbEdicaoCapa.text = [NSString stringWithFormat:@"Edição %@",[[EdicaoParaBaixar objectAtIndex:indexPath.row] objectForKey:@"numedicao"]];
    
    NSURL * urlImage = [NSURL URLWithString:[[EdicaoParaBaixar objectAtIndex:indexPath.row] objectForKey:@"imagem"]];
    
    
    Edicao = [[EdicaoParaBaixar objectAtIndex:indexPath.row] objectForKey:@"edicao"];
    
    cell.imgCapa.image = [UIImage imageNamed:@"loading_revista"];
    
    
    NSUserDefaults * btnDownload = [NSUserDefaults standardUserDefaults];
    bool Verificar = [btnDownload boolForKey:Edicao];
    
    if (Verificar) {
        cell.imgCapa.alpha = 1.0;
    }

    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:urlImage completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    EdicoesColletionCell * updateCell = (id)[collectionView cellForItemAtIndexPath:indexPath];
                    if (updateCell)
                        updateCell.imgCapa.image = image;
                });
            }
        }
    }];
    [task resume];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(width, width + heigthAdjustment);
}

-(void) criarPasta:(NSString * ) pasta {
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:pasta];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
}

-(BOOL)checkIfDirectoryAlreadyExists:(NSString *)name{
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:name];
    
    BOOL isDir;
    BOOL fileExists = [fileManager fileExistsAtPath:dataPath isDirectory:&isDir];
    
    if (fileExists){
        NSLog(@"Existe Arquivo...");
        
        if (isDir) {
            NSLog(@"Folder already exists...");
        }
    }
    return fileExists;
}

-(void) BucarDadosPasta :(NSString *) Pasta{
    
    pageImages = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:Pasta];
    
    NSArray * dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:NULL];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:@"jpg"]) {
            [pageImages addObject:[dataPath stringByAppendingPathComponent:filename]];
        }
    }];
    
    NSLog(@"Array: %@ ", pageImages);
    
}

-(void) VisualizarEdicao:(NSString * )Pasta {
    
    NSMutableArray * photos = [[NSMutableArray alloc] init];
    //MWPhoto *photo;
    
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    
    // buscar e carregar fotos no array abaixo //
    
    [self BucarDadosPasta:Pasta];
    
    for (NSInteger i = 0; i < pageImages.count; i++){
        
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:pageImages[i]];
        
        [photos addObject:[MWPhoto photoWithURL:fileURL]];
    }
    
    // Options
    enableGrid = NO;
    
    self.photos = photos;
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:0];
    
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    [self.navigationController pushViewController:browser animated:YES];
}

 
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
