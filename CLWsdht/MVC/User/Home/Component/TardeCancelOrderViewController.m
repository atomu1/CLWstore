//
//  TardeCancelOrderViewController.m
//  CLWsdht
//
//  Created by koroysta1 on 16/4/18.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "TardeCancelOrderViewController.h"
#import "AFNetworking.h"//主要用于网络请求方法
#import "UIKit+AFNetworking.h"//里面有异步加载图片的方法
#import "MJExtension.h"
#import "OrderTableViewCell.h"
#import "BaseHeader.h"
#import "OrderModel.h"
#import "MyOrderViewController.h"
#import "UserInfo.h"
#import "SingleCase.h"

#define rowNum (NSInteger)((kScreen_Height - 100) / 96 + 1)

@interface TardeCancelOrderViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (nonatomic, strong) UITableView *orderTableView;
@property (nonatomic, strong) NSMutableArray *partlistArr;
@property (nonatomic, copy) NSString *storeId;

@property (nonatomic, strong) NSMutableArray *modelArr;
@property (nonatomic, strong) NSMutableArray *showModel;
@property (nonatomic, assign) NSInteger times;
@property (nonatomic, assign) NSInteger totalNum;

@end

@implementation TardeCancelOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"我的配件订单"];
    _partlistArr = [[NSMutableArray alloc] initWithCapacity:0];
    SingleCase *singleCase = [SingleCase sharedSingleCase];
    _storeId = singleCase.str;
    
    _times  = 0;
    self.showModel = [NSMutableArray arrayWithCapacity:0];
    
    [self GetOrderListByNetwork];
    [self setUpView];
    [self changLabel];
    [self setHeaderRefresh];
    [self setFooterRefresh];
    
}

/**
 *  当前选中的页面指示
 *
 */
- (void)changLabel{
    if ([_orderState  isEqual: @"100"]) {
        [_secondLabel setBackgroundColor:[UIColor whiteColor]];
        [_firstLabel setBackgroundColor:[UIColor redColor]];
    }else if ([_orderState  isEqual: @"-1"]){
        [_firstLabel setBackgroundColor:[UIColor whiteColor]];
        [_secondLabel setBackgroundColor:[UIColor redColor]];
    }
}


//UI界面
-(void)setUpView{
    _orderTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 104, SCREEN_WIDTH, SCREEN_HEIGHT-104) style:UITableViewStyleGrouped];
    _orderTableView.delegate=self;
    _orderTableView.dataSource=self;
    [_orderTableView registerNib:[UINib nibWithNibName:@"OrderTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderCellIdentifer"];
    [self.view addSubview:_orderTableView];
}


//已交易按钮
- (IBAction)tardeBtn:(UIButton *)sender {
    _orderState = @"100";
    [self changLabel];
    [self GetOrderListByNetwork];
}
//已取消按钮
- (IBAction)cancelBtn:(UIButton *)sender {
    _orderState = @"-1";
    [self changLabel];
    [self GetOrderListByNetwork];
}



//获取我的订单
- (void)GetOrderListByNetwork{
    [SVProgressHUD showWithStatus:k_Status_Load];
    if (_totalNum == 0) {
        _totalNum = 10;
    }
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Usr.asmx/GetOrdersList"];
    NSDictionary *paramDict = @{
                                @"state":_orderState,
                                @"usrId":@"",
                                @"garageId":@"",
                                @"storeId":_storeId,
                                @"start":[NSString stringWithFormat:@"%d",0],
                                @"limit":[NSString stringWithFormat:@"%ld", _totalNum]
                                };
    
    [ApplicationDelegate.httpManager POST:urlStr
                               parameters:paramDict
                                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      //http请求状态
                                      if (task.state == NSURLSessionTaskStateCompleted) {
                                          //            NSDictionary *jsonDic = [JYJSON dictionaryOrArrayWithJSONSData:responseObject];
                                          NSError* error;
                                          NSDictionary* jsonDic = [NSJSONSerialization
                                                                   JSONObjectWithData:responseObject
                                                                   options:kNilOptions
                                                                   error:&error];
                                          if (jsonDic[@"Success"]) {
                                              //成功
                                              NSLog(@"------------------%@", jsonDic);
                                              OrderModel *orderModel = [[OrderModel alloc] init];
                                              _partlistArr = [orderModel assignModelWithDict:jsonDic];
                                              [self datprocessingWith:_partlistArr];
                                              [SVProgressHUD showSuccessWithStatus:  k_Success_Load];
                                              
                                          } else {
                                              //失败
                                              [SVProgressHUD showErrorWithStatus:k_Error_WebViewError];
                                              
                                          }
                                          [_orderTableView.mj_header endRefreshing];
                                      } else {
                                          [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                      }
                                      [_orderTableView.mj_header endRefreshing];
                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                      //请求异常
                                      [_orderTableView.mj_header endRefreshing];
                                      [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                  }];
    
}

/**
 *  上下拉刷新
 */
#pragma mark - 上拉刷新
- (void)setHeaderRefresh {
    
    _orderTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _modelArr = [NSMutableArray arrayWithCapacity:0];
        _showModel = [NSMutableArray arrayWithCapacity:0];
        _totalNum = 0;
        _times = 0;
        [self GetOrderListByNetwork];
        
        [_orderTableView.mj_header beginRefreshing];
        [_orderTableView reloadData];
    }];
}



#pragma mark - 下拉加载
- (void)setFooterRefresh {
    _orderTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        if (_totalNum >= 10&&_times == 1) {
            [self GetOrderListByNetwork];
        } else {
            for (NSInteger i = _times * rowNum; i < _modelArr.count; i++) {
                [_showModel addObject:_modelArr[i]];
                if (i ==( (1 + _times) * rowNum) - 1) {
                    break;
                }
            }
            _times++;
        }
        if (_showModel.count == _modelArr.count) {
            [SVProgressHUD showInfoWithStatus:@"没有更多可以加载了"];
        }
        [_orderTableView.mj_footer endRefreshing];
        [_orderTableView reloadData];
    }];
}


/**
 *  刷新
 */
- (void)datprocessingWith:(NSMutableArray *)jsonArr {
    for (NSInteger i = _times*rowNum; i < jsonArr.count; i ++) {
        [_showModel addObject:jsonArr[i]];
        if (i == ((1 + _times) * rowNum)-1) {
            break;
        }
    }
    _times ++;
    
    [_orderTableView reloadData];
}



#pragma mark -- UITableViewDataSource

/*设置标题头的宽度*/
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
/*设置标题尾的宽度*/
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 85;
}
//设置cell头的UI
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    OrderModel *OM = [[OrderModel alloc] init];
    OM = _partlistArr[section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    //店铺图标
    UIImageView *storeImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
    [storeImg setImage:[UIImage imageNamed:@"NotificationBackgroundError.png"]];
    [headerView addSubview:storeImg];
    //店铺名字
    UILabel *storeName = [[UILabel alloc] initWithFrame:CGRectMake(storeImg.frame.origin.x+storeImg.frame.size.width+5, storeImg.frame.origin.y, 100, 20)];
    [storeName setBackgroundColor:[UIColor clearColor]];
    [storeName setText:OM.StoreName];
    [storeName setTextColor:[UIColor blackColor]];
    [storeName setFont:[UIFont systemFontOfSize:14]];
    [headerView addSubview:storeName];
    //图标
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-35, storeImg.frame.origin.y, 20, 20)];
    [img setImage:[UIImage imageNamed:@"等级砖石"]];
    [headerView addSubview:img];
    return headerView;
    
}
//设置cell尾的UI
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 125)];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    
    OrderModel *OM = [[OrderModel alloc] init];
    OM = _partlistArr[section];
    
    //价格Label
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65,10, 50, 15)];
    [price setBackgroundColor:[UIColor clearColor]];
    [price setText:[NSString stringWithFormat:@"￥%@",OM.Price]];
    [price setTextAlignment:NSTextAlignmentCenter];
    [price setTextColor:[UIColor redColor]];
    [price setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:price];
    //合计
    UILabel *add = [[UILabel alloc] initWithFrame:CGRectMake(price.frame.origin.x-40, price.frame.origin.y, 35, 15)];
    [add setBackgroundColor:[UIColor clearColor]];
    [add setText:@"合计"];
    [add setTextAlignment:NSTextAlignmentRight];
    [add setTextColor:[UIColor lightGrayColor]];
    [add setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:add];
    //共计几件商品
    UILabel *manyGood = [[UILabel alloc] initWithFrame:CGRectMake(add.frame.origin.x-95, add.frame.origin.y, 90, 15)];
    [manyGood setBackgroundColor:[UIColor clearColor]];
    NSArray *many = OM.PartsList;
    [manyGood setText:[NSString stringWithFormat:@"共计%lu件商品",(unsigned long)many.count]];
    [manyGood setTextAlignment:NSTextAlignmentCenter];
    [manyGood setTextColor:[UIColor lightGrayColor]];
    [manyGood setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:manyGood];
    //分割线
    UILabel *carveF = [[UILabel alloc] initWithFrame:CGRectMake(0, manyGood.frame.origin.y+manyGood.frame.size.height+8, SCREEN_WIDTH, 0.5)];
    [carveF setBackgroundColor:[UIColor lightGrayColor]];
    [footerView addSubview:carveF];
    
    //收货地址、
    UILabel *storeOK = [[UILabel alloc] initWithFrame:CGRectMake(10, carveF.frame.origin.y+5, 90, 15)];
    [storeOK setBackgroundColor:[UIColor clearColor]];
    [storeOK setText:@"收货地址"];
    [storeOK setTextColor:[UIColor lightGrayColor]];
    [storeOK setFont:[UIFont systemFontOfSize:12]];
    [footerView addSubview:storeOK];
    //收货地址信息
    UILabel *garageOK = [[UILabel alloc] initWithFrame:CGRectMake(10, storeOK.frame.origin.y+storeOK.frame.size.height+3, SCREEN_WIDTH-20, 15)];
    [garageOK setBackgroundColor:[UIColor clearColor]];
    [garageOK setText:OM.Addr];
    [garageOK setTextColor:[UIColor lightGrayColor]];
    [garageOK setFont:[UIFont systemFontOfSize:12]];
    [footerView addSubview:garageOK];
    //分割线
    UILabel *carveS = [[UILabel alloc] initWithFrame:CGRectMake(0, garageOK.frame.origin.y+manyGood.frame.size.height+13, SCREEN_WIDTH, 0.5)];
    [carveS setBackgroundColor:[UIColor lightGrayColor]];
    [footerView addSubview:carveS];
    return footerView;
}

//返回某个section中rows的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    OrderModel *OM = [[OrderModel alloc] init];
    OM = _partlistArr[section];
    return OM.PartsList.count;
}


//这个方法是用来创建cell对象，并且给cell设置相关属性的
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置标识符
    static NSString *userStoreCellIdentifer = @"orderCellIdentifer";
    OrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCellIdentifer"];
    if (cell == nil) {
        cell = [[OrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userStoreCellIdentifer];
    }
    OrderModel *OM=_partlistArr[indexPath.section];
    GoodModel *GM=OM.PartsList[indexPath.row];
    [cell setOrderWithModel:GM andWtihState:_orderState andWithOrderModel:OM];
    return cell;
}

//返回section的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"zzzzzz%lu",(unsigned long)_partlistArr.count);
    return _partlistArr.count;
}

#pragma mark -- UITableViewDelegate
//返回cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}
//选中cell时调起的方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //选中cell要做的操作
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
