//
//  MyOrderViewController.m
//  CLWsdht
//
//  Created by koroysta1 on 16/4/7.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "MyOrderViewController.h"
#import "TheOrderViewController.h"
#import "MaintainOrderViewController.h"
#import "TardeCancelOrderViewController.h"
#import "ReturnGoodsViewController.h"
#import "AFNetworking.h"//主要用于网络请求方法
#import "UIKit+AFNetworking.h"//里面有异步加载图片的方法
#import "MJExtension.h"
#import "BaseHeader.h"
#import "SingleCase.h"
#import "NSJSON+YBClass.h"

@interface MyOrderViewController ()
//需求已报价
@property (weak, nonatomic) IBOutlet UILabel *maintainOrderSecond;//待评价


//配件订单
@property (weak, nonatomic) IBOutlet UILabel *buyPartOrderFirst;//待确认
@property (weak, nonatomic) IBOutlet UILabel *buyPartOrderSecond;//待发货
@property (weak, nonatomic) IBOutlet UILabel *buyPartOrderTirth;//待评价
@property (weak, nonatomic) IBOutlet UILabel *buyPartOrderFourth;//已取消
@property (weak, nonatomic) IBOutlet UILabel *buyPartOrderFifth;//待付款
@property (weak, nonatomic) IBOutlet UILabel *buyPartOrderSixth;//待交易
@property (weak, nonatomic) IBOutlet UILabel *buyPartOrderSeven;//已交易
@property (weak, nonatomic) IBOutlet UILabel *buyPartOrderEight;//退货申请
@property (weak, nonatomic) IBOutlet UILabel *buyPartOrderNine;//退货待收货

@property (nonatomic, strong) NSString *userID;

@end

@implementation MyOrderViewController

- (void)viewWillAppear:(BOOL)animated{
    SingleCase *singleCase = [SingleCase sharedSingleCase];
    _userID = singleCase.str;

    [self UsrAggregate];
}

- (void)UsrAggregate{
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Aggregate.asmx/StoreAggregate"];
    NSDictionary *paramDict = @{
                                @"id":_userID
                                };
    [ApplicationDelegate.httpManager POST:urlStr
                               parameters:paramDict
                                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      //http请求状态
                                      if (task.state == NSURLSessionTaskStateCompleted) {
                                          NSError* error;
                                          NSDictionary* jsonDic = [NSJSONSerialization
                                                                   JSONObjectWithData:responseObject
                                                                   options:kNilOptions
                                                                   error:&error];
                                          NSString *status = [NSString stringWithFormat:@"%@",jsonDic[@"Success"]];
                                          if ([status isEqualToString:@"1"]) {
                                              //成功
                                              NSLog(@"------------------%@", jsonDic);
                                              [self changeCorner:jsonDic];
                                              [SVProgressHUD showSuccessWithStatus:  k_Success_Load];
                                          } else {
                                              //失败
                                              [SVProgressHUD showErrorWithStatus:k_Error_WebViewError];
                                              
                                          }
                                      } else {
                                          [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                      }
                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                      //请求异常
                                      [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                  }];
    
}
- (void)changeCorner:(NSDictionary *)dict
{
    NSString *str1 = [[NSString alloc] init];
    str1 = [dict objectForKey:@"Data"];
    
    NSDictionary* dic1 = [NSDictionary dictWithJSON:str1];
    NSLog(@"dic = %@",dic1);
    _buyPartOrderFirst.text = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"POrder0"]];
    _buyPartOrderSecond.text = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"POrder1"]];
    _buyPartOrderTirth.text = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"POrder2"]];
    _buyPartOrderFourth.text = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"POrder3"]];
    _buyPartOrderFifth.text = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"POrder4"]];
    _buyPartOrderSixth.text = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"POrder100"]];
    _buyPartOrderSeven.text = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"POrderCancel"]];
    _buyPartOrderEight.text = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"POrderRefund"]];
    _buyPartOrderNine.text = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"POrderRefundDelivery"]];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"我的订单"];
    //设置圆角
    [_maintainOrderSecond.layer setMasksToBounds:YES];
    [_maintainOrderSecond.layer setCornerRadius:11];

    
    [_buyPartOrderFirst.layer setMasksToBounds:YES];
    [_buyPartOrderFirst.layer setCornerRadius:11];
    [_buyPartOrderSecond.layer setMasksToBounds:YES];
    [_buyPartOrderSecond.layer setCornerRadius:11];
    [_buyPartOrderTirth.layer setMasksToBounds:YES];
    [_buyPartOrderTirth.layer setCornerRadius:11];
    [_buyPartOrderFourth.layer setMasksToBounds:YES];
    [_buyPartOrderFourth.layer setCornerRadius:11];
    [_buyPartOrderFifth.layer setMasksToBounds:YES];
    [_buyPartOrderFifth.layer setCornerRadius:11];
    [_buyPartOrderSixth.layer setMasksToBounds:YES];
    [_buyPartOrderSixth.layer setCornerRadius:11];
    [_buyPartOrderSeven.layer setMasksToBounds:YES];
    [_buyPartOrderSeven.layer setCornerRadius:11];
    [_buyPartOrderEight.layer setMasksToBounds:YES];
    [_buyPartOrderEight.layer setCornerRadius:11];
    [_buyPartOrderNine.layer setMasksToBounds:YES];
    [_buyPartOrderNine.layer setCornerRadius:11];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 维修订单
//待确认
- (IBAction)confirmBtn:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    MaintainOrderViewController *mainOrderVC = [[MaintainOrderViewController alloc] init];
    _mainState = @"0";
    mainOrderVC.orderState = _mainState;
    [self.navigationController pushViewController:mainOrderVC animated:YES];
}

//待付款
- (IBAction)payBtn:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    MaintainOrderViewController *mainOrderVC = [[MaintainOrderViewController alloc] init];
    _mainState = @"2";
    mainOrderVC.orderState = _mainState;
    [self.navigationController pushViewController:mainOrderVC animated:YES];
}
//待评价
- (IBAction)judgeBtn:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    MaintainOrderViewController *mainOrderVC = [[MaintainOrderViewController alloc] init];
    _mainState = @"3";
    mainOrderVC.orderState = _mainState;
    [self.navigationController pushViewController:mainOrderVC animated:YES];
}

//已交易
- (IBAction)tardeBtn:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    MaintainOrderViewController *mainOrderVC = [[MaintainOrderViewController alloc] init];
    _mainState = @"100";
    mainOrderVC.orderState = _mainState;
    [self.navigationController pushViewController:mainOrderVC animated:YES];
}

//已取消
- (IBAction)cancelBtn:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    MaintainOrderViewController *mainOrderVC = [[MaintainOrderViewController alloc] init];
    _mainState = @"-1";
    mainOrderVC.orderState = _mainState;
    [self.navigationController pushViewController:mainOrderVC animated:YES];
}

#pragma mark -- 购买配件订单
//待确认
- (IBAction)confirmBuy:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    TheOrderViewController *theOrderVC = [[TheOrderViewController alloc] init];
    _state = @"0";
    theOrderVC.orderState = _state;
    [self.navigationController pushViewController:theOrderVC animated:YES];
}

//待付款
- (IBAction)payBuy:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    TheOrderViewController *theOrderVC = [[TheOrderViewController alloc] init];
    _state = @"1";
    theOrderVC.orderState = _state;
    [self.navigationController pushViewController:theOrderVC animated:YES];
}

//待发货
- (IBAction)dispatchBuy:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    TheOrderViewController *theOrderVC = [[TheOrderViewController alloc] init];
    _state = @"2";
    theOrderVC.orderState = _state;
    [self.navigationController pushViewController:theOrderVC animated:YES];
}

//待收货
- (IBAction)putBuy:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    TheOrderViewController *theOrderVC = [[TheOrderViewController alloc] init];
    _state = @"3";
    theOrderVC.orderState = _state;
    [self.navigationController pushViewController:theOrderVC animated:YES];
}

//待评价
- (IBAction)judgeBuy:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    TheOrderViewController *theOrderVC = [[TheOrderViewController alloc] init];
    _state = @"4";
    theOrderVC.orderState = _state;
    [self.navigationController pushViewController:theOrderVC animated:YES];
}

//已交易
- (IBAction)tardeBuy:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    TardeCancelOrderViewController *targeCancelOrder = [[TardeCancelOrderViewController alloc] init];
    _state = @"100";
    targeCancelOrder.orderState = _state;
    [self.navigationController pushViewController:targeCancelOrder animated:YES];
}

//已取消
- (IBAction)cancelBuy:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    TardeCancelOrderViewController *targeCancelOrder = [[TardeCancelOrderViewController alloc] init];
    _state = @"-1";
    targeCancelOrder.orderState = _state;
    [self.navigationController pushViewController:targeCancelOrder animated:YES];
}

//退货申请
- (IBAction)returnBuy:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    ReturnGoodsViewController *returnGoods = [[ReturnGoodsViewController alloc] init];
    _state = @"0";
    returnGoods.orderState = _state;
    [self.navigationController pushViewController:returnGoods animated:YES];
}

//退货待收货
- (IBAction)returnGoods:(UIButton *)sender {
    [self setHidesBottomBarWhenPushed:YES];
    ReturnGoodsViewController *returnGoods = [[ReturnGoodsViewController alloc] init];
    _state = @"2";
    returnGoods.orderState = _state;
    [self.navigationController pushViewController:returnGoods animated:YES];
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
