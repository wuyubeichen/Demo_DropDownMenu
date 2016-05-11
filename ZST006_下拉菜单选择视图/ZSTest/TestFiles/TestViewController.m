//
//  TestViewController.m
//  Test
//
//  Created by zhoushuai on 16/3/7.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "TestViewController.h"
#import "WJDropdownMenu.h"
#import "JSONKit.h"
@interface TestViewController ()<WJMenuDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)WJDropdownMenu *dropDownMenu;


//顶部视图的高度
@property(nonatomic,assign)CGFloat chooseViewHeight;

//省份和城市
@property(nonatomic,strong)NSMutableArray *areaArray;
@property(nonatomic,strong)NSMutableArray *cityArray;

//索引
@property(nonatomic,assign)NSInteger typeIndex;
@property(nonatomic,assign)NSInteger areaIndex;
@property(nonatomic,assign)NSInteger cityIndex;


@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"测试下拉菜单";
    
    _chooseViewHeight = 50;
    
    [self getLoctionInformation];
    
    //添加表视图
    [self.view addSubview:self.tableView];
    //添加选择视图
    [self.view addSubview:self.dropDownMenu];
    [self createAllMenuData];

}




#pragma mark UITableViewDelegate
//返回组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
//返回行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}
//返回单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"chatDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor purpleColor];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}


//单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


#pragma mark - 获取数据
//地区信息
-(void)getLoctionInformation{
    //读取地区信息
    _areaArray = (NSMutableArray *)[self readAreaArray];
    _cityArray = [NSMutableArray array];
    
    @try {
        for (NSDictionary *dic in _areaArray) {
            NSMutableArray *citysMutArr = [NSMutableArray array];
            //每个省份之后都加上了不限
            NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
            [mutDic setObject:@"0" forKey:@"id"];
            [mutDic setObject:@"不限" forKey:@"name"];
            [citysMutArr addObject:mutDic];
            
            [citysMutArr addObjectsFromArray:dic[@"citys"]];
            [_cityArray addObject:citysMutArr];
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"%@",exception.name);
    }
    @finally {
        
    }
}


- (NSArray *)readAreaArray
{
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"txt"];
    NSString *textFilesStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    // If there are no results, something went wrong
    if (textFilesStr == nil) {
        // an error occurred
        NSLog(@"Error reading text file. %@", [error localizedFailureReason]);
    }
    return [textFilesStr objectFromJSONString];
}



#pragma mark - 得到索引
- (void)menuCellDidSelected:(NSInteger)MenuTitleIndex firstIndex:(NSInteger)firstIndex andSecondIndex:(NSInteger)secondIndex{
    if (MenuTitleIndex == 0) {
        //选择了类型
        _typeIndex = firstIndex;
        
    }else{
        //选择了地址
        _areaIndex = firstIndex;
        _cityIndex = secondIndex;
    }
    //选择之后，使用筛选的信息请求新数据
    NSLog(@"广场搜索条件_类型:%ld",(long)_typeIndex);
    NSLog(@"广场搜索条件_地区:%ld_%ld",(long)_areaIndex,(long)_cityIndex);
    
}

#pragma mark - set/get方法
- (WJDropdownMenu *)dropDownMenu{
    if (_dropDownMenu == nil) {
        _dropDownMenu = [[WJDropdownMenu alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, _chooseViewHeight)];
        //设置代理
        _dropDownMenu.delegate = self;
        
        //增加了遮盖层动画时间设置   不设置默认是  0.15
        _dropDownMenu.caverAnimationTime = 0.5;
        
        //设置menuTitle字体大小    不设置默认是  11
        _dropDownMenu.menuTitleFont = 15;
        
        //设置tableTitle字体大小   不设置默认是  10
        _dropDownMenu.tableTitleFont = 15;
        
        //设置tableViewcell高度   不设置默认是  40
        _dropDownMenu.cellHeight = 50;
        
        //旋转箭头的样式(空心箭头 or 实心箭头)
        _dropDownMenu.menuArrowStyle = menuArrowStyleSolid;
        
        //tableView的最大高度(超过此高度就可以滑动显示)
        _dropDownMenu.tableViewMaxHeight = kDeviceHeight -64 - _chooseViewHeight -150;
        
        //menu定义了一个tag值如果与本页面的其他button的值有冲突重合可以自定义设置
        _dropDownMenu.menuButtonTag = 100;
        
        //设置遮罩层颜色
        _dropDownMenu.CarverViewColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }
    return _dropDownMenu;
}



- (void)createAllMenuData{
    NSArray *twoMenuTitleArray =  @[@"类型",@"位置"];
    //创建第一个菜单数据
    NSArray *firstArrOne = [NSArray arrayWithObjects:@"类型1",@"类型2",@"类型3", @"类型4",nil];
    NSArray *firstMenu = [NSArray arrayWithObject:firstArrOne];
    
    //创建第二个菜单数据
     NSMutableArray *firstArrTwo = [NSMutableArray array];
    [firstArrTwo addObject:@"不限"];
    for (int i = 0; i<_areaArray.count; i++) {
        [firstArrTwo  addObject:_areaArray[i][@"name"]];
    }
    NSMutableArray *secondArrTwo = [NSMutableArray array];
    [secondArrTwo addObject:@[]];
    for (int i = 0; i<_cityArray.count; i++) {
        NSMutableArray *cityNames = [NSMutableArray array];
        NSArray *currentCityArr = _cityArray[i];
        for ( int j = 0; j<currentCityArr.count; j++) {
            [cityNames addObject:currentCityArr[j][@"name"]];
        }
        [secondArrTwo addObject:cityNames];
    }
    NSArray *SecondMenu = [NSArray arrayWithObjects:firstArrTwo,secondArrTwo, nil];
    
    //创建具有两个选项的菜单
    [self.dropDownMenu createTwoMenuTitleArray:twoMenuTitleArray FirstArr:firstMenu SecondArr:SecondMenu];
}



- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView  alloc] initWithFrame:CGRectMake(0, _chooseViewHeight, kDeviceWidth, kDeviceHeight-64) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor orangeColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}


 
@end
