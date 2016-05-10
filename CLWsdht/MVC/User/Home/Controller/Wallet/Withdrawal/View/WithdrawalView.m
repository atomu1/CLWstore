//
//  WithdrawalView.m
//  CLWsdht
//
//  Created by yang on 16/4/16.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "WithdrawalView.h"
#import "BaseHeader.h"
#import "UserInfo.h"

@implementation WithdrawalView
{
    UILabel *bankAccount;//银行卡
    UITextField *bankAccountField;
    UILabel *name;//姓名
    UITextField *nameField;
    UILabel *money;//钱数
    UITextField *moneyField;
    UIButton *button;//按钮
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setSubViews];
    }
    return self;
}

//提交申请点击事件
- (void)buttonClick:(UIButton *)sender
{
    [self fieldResignFirstResponder];
    if ([_price integerValue] < [moneyField.text integerValue] || [moneyField.text integerValue] <= 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"请正确输入金额"];
        });
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:ApplicationDelegate.userInfo.user_Id forKey:@"usrId"];
    [dic setObject:@"2" forKey:@"usrType"];
    [dic setObject:moneyField.text forKey:@"val"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"withDrawal" object:nil userInfo:dic];
}

//点击空白处取消第一响应者
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self fieldResignFirstResponder];
}

- (void)fieldResignFirstResponder
{
    [bankAccountField resignFirstResponder];
    [nameField resignFirstResponder];
    [moneyField resignFirstResponder];
}
//设置钱的占位符
- (void)setPrice:(NSString *)price
{
    _price = price;
    moneyField.placeholder = [NSString stringWithFormat:@"当前可提现金额%@元", price];
}
//ui
- (void)setSubViews
{
    bankAccount = [UILabel new];
    bankAccount.text = @"银行卡";
    bankAccount.font = [UIFont systemFontOfSize:12];
    [self addSubview:bankAccount];
    bankAccountField = [UITextField new];
    bankAccountField.placeholder = @"请输入银行卡号";
    bankAccountField.textAlignment = 2;
    bankAccountField.font = [UIFont systemFontOfSize:12];
    bankAccountField.keyboardType = UIKeyboardTypeNumberPad;
    bankAccountField.borderStyle = UITextBorderStyleRoundedRect;
    bankAccountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:bankAccountField];
    name = [UILabel new];
    name.text = @"姓名";
    name.font = [UIFont systemFontOfSize:12];
    [self addSubview:name];
    nameField = [UITextField new];
    nameField.placeholder = @"请输入姓名";
    nameField.textAlignment = 2;
    nameField.font = [UIFont systemFontOfSize:12];
    nameField.borderStyle = UITextBorderStyleRoundedRect;
    nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:nameField];
    money = [UILabel new];
    money.text = @"金额(元)";
    money.font = [UIFont systemFontOfSize:12];
    [self addSubview:money];
    moneyField = [UITextField new];
    moneyField.textAlignment = 2;
    moneyField.font = [UIFont systemFontOfSize:12];
    moneyField.keyboardType = UIKeyboardTypeNumberPad;
    moneyField.borderStyle = UITextBorderStyleRoundedRect;
    moneyField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:moneyField];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"提交申请" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:251/255.0 green:68/255.0 blue:31/255.0 alpha:1.0];
    button.layer.cornerRadius = 5;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}
//frame
- (void)layoutSubviews
{
    __weak typeof(self) weakSelf = self;
    [bankAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(weakSelf).offset(20);
        make.width.equalTo(weakSelf).multipliedBy(0.2);
        make.height.mas_equalTo(@30);
    }];
    [bankAccountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(bankAccount);
        make.left.equalTo(bankAccount.mas_right).offset(0);
        make.right.equalTo(weakSelf).offset(-20);
    }];
    [name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bankAccount.mas_bottom).offset(10);
        make.left.width.height.equalTo(bankAccount);
    }];
    [nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(name);
        make.left.right.height.equalTo(bankAccountField);
    }];
    [money mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(name.mas_bottom).offset(10);
        make.left.width.height.equalTo(bankAccount);
    }];
    [moneyField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(money);
        make.left.right.height.equalTo(bankAccountField);
    }];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(money.mas_bottom).offset(20);
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.width.equalTo(weakSelf).multipliedBy(0.85);
        make.height.mas_equalTo(@40);
    }];
}
//移除通知
- (void)dealloc
{
    [button removeTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
}

@end
