//
//  HomeVC.m
//  CLW
//
//  Created by majinyu on 16/1/9.
//  Copyright © 2016年 cn.com.cucsi. All rights reserved.
//

#import "HomeVC.h"
#import "LoginViewController.h"//登陆页面
#import "AddNewPartsVC.h"
#import "MyShopReleaseVC.h"

#import "CityListVC.h"//城市选择
#import "AddressGroupJSONModel.h"//地址model
#import "AddressJSONModel.h"//地址model
#import "MyOrderViewController.h"//我的订单VC
#import "SupplierReceiveViewController.h"
#import "MyWalletViewController.h"//我的钱包VC

@interface HomeVC () <UISearchBarDelegate> {
    
    NSString *userSeletedCity;//用户选择的城市(默认用户当前位置所在城市)
    NSString *userSeletedCityID;//用户选择的城市ID(默认用户当前位置所在城市)
    
}


//当前在线商家数量
@property (weak, nonatomic) IBOutlet UILabel *repairCarOnlineNumber;
//我要修车
@property (weak, nonatomic) IBOutlet UIButton *myCase;

//我要买件
@property (weak, nonatomic) IBOutlet UIButton *needer;

//金牌商家视图
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation HomeVC

#pragma mark - Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;

    //设置圆角
    _myCase.layer.masksToBounds = YES;
    _myCase.layer.cornerRadius = 8;
    
    _needer.layer.masksToBounds = YES;
    _needer.layer.cornerRadius = 8;
    [self initData];
    
    [self initUI];
    [self std_regsNotification];
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = NO;
    }
    //加载首页数据信息
    
    userSeletedCity = ApplicationDelegate.currentCity;
    userSeletedCityID = ApplicationDelegate.currentCityID;
    [self initRightButtonItemWithCityName:userSeletedCity];
    
    
    //显示登录页面
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//    LoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
//    self.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:NO];
//    self.hidesBottomBarWhenPushed = NO;
    
    
    
    if (!ApplicationDelegate.isLogin) {
        //显示登录页面
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:NO];
        self.hidesBottomBarWhenPushed = NO;
    } else {
        //加载首页数据信息
        
        userSeletedCity = ApplicationDelegate.currentCity;
        userSeletedCityID = ApplicationDelegate.currentCityID;
        [self initRightButtonItemWithCityName:userSeletedCity];
    }
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:k_Notification_UpdateUserAddressInfo_Home
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:k_Notification_CitySelect_Home
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:k_Notification_CityBtnName_Home
                                                  object:nil];

}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
}

#pragma mark -std Local
- (void)execute:(NSNotification *)notification {
    if([notification.name isEqualToString:k_Notification_CityBtnName_Home] ){
        userSeletedCity=ApplicationDelegate.currentCity;
        userSeletedCityID = ApplicationDelegate.currentCityID;
        UIButton *btn = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
        [btn setTitle:userSeletedCity forState:UIControlStateNormal];
        btn.titleLabel.text = userSeletedCity;
        
    }
}

- (void)selectCity:(NSNotification *)notification {
    if([notification.name isEqualToString:k_Notification_CitySelect_Home] ){
        [self seleteCityAction];
        
    }
}


-(void)std_regsNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(execute:)
                                                 name:k_Notification_CityBtnName_Home
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectCity:)
                                                 name:k_Notification_CitySelect_Home
                                               object:nil];
}


#pragma mark - Data & UI
//数据
-(void)initData
{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserSeletdCity:)
                                                 name:k_Notification_UpdateUserAddressInfo_Home
                                               object:nil];
    
    
}
//页面
-(void)initUI
{
    
    // 张晓新 2016-04-07 添加导航栏搜索框
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 30)];
    UIColor *color =  self.navigationController.navigationBar.barTintColor;
    [titleView setBackgroundColor:color];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.frame = CGRectMake(0, 0, 160, 30);
    searchBar.backgroundColor = color;
    searchBar.layer.cornerRadius = 10;
    searchBar.layer.masksToBounds = YES;
    [searchBar.layer setBorderWidth:8];
    [searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];  //设置边框为白色
    
    searchBar.placeholder = @"搜索：配件/商店";
    [titleView addSubview:searchBar];
    
    //Set to titleView
    [self.navigationItem.titleView sizeToFit];
    self.navigationItem.titleView = titleView;
}

#pragma mark - Notification Method
/**
 *  更新用户选择信息
 *
 *  @param noti
 */
- (void)updateUserSeletdCity:(NSNotification *) noti
{
    AddressJSONModel *address = noti.object;
    
    userSeletedCity = address.city_name;
    userSeletedCityID = address.city_id;
    ApplicationDelegate.currentCity=userSeletedCity;
    ApplicationDelegate.currentCityID=userSeletedCityID;
    [ApplicationDelegate std_saveCityName:userSeletedCity];
    UIButton *btn = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    [btn setTitle:userSeletedCity forState:UIControlStateNormal];
    btn.titleLabel.text = userSeletedCity;
}

#pragma mark - Target & Action

#pragma mark - Functions Custom

/**
 *   初始化右上角按钮
 */
- (void)initRightButtonItemWithCityName:(NSString *)cityName
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/3, 44)];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btn setTitle:cityName forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn addTarget:self action:@selector(seleteCityAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

/**
 *  选择城市的方法
 */
- (void) seleteCityAction
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    CityListVC *vc = [sb instantiateViewControllerWithIdentifier:@"CityListVC"];
    vc.vcType = 2;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:^{}];
    
}
#pragma mark -我的钱包
- (IBAction)myCaseBtn:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    MyWalletViewController *wallet = [[MyWalletViewController alloc] init];
    [self.navigationController pushViewController:wallet animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}
#pragma mark -我要买件
- (IBAction)neederBtn:(UIButton *)sender {
}
#pragma mark -- 我的订单
- (IBAction)myOrderBtn:(UIButton *)sender {
    UIBarButtonItem *backIetm = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backIetm;
    backIetm.title =@"返回";
    [self setHidesBottomBarWhenPushed:YES];
    MyOrderViewController *myOrderVC = [[MyOrderViewController alloc] init];
    [self.navigationController pushViewController:myOrderVC animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}


- (IBAction)supplyDemand:(id)sender { /* 供货需求 */
    [self setHidesBottomBarWhenPushed:YES];
    SupplierReceiveViewController *supplier = [[SupplierReceiveViewController alloc] init];
    [self.navigationController pushViewController:supplier animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

#pragma mark - 新品上架
- (IBAction)newPartsButtonPressed:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    //AddNewPartsVC *newPartsVC = [[AddNewPartsVC alloc] initWithNibName:@"AddNewPartsVC" bundle:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MyShop" bundle:nil];
    MyShopReleaseVC *newPartsVC = [storyboard instantiateViewControllerWithIdentifier:@"MyShopReleaseVC"];
    [self.navigationController pushViewController:newPartsVC animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}


#pragma mark - Networking


@end
