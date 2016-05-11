
// 如有任何bug、不足、功能不全之处请在github不上找我，我会第一时间回复并修正
// QQ微信:576527857
// github:https://github.com/wjTime/WJDropDownMenu.git 实时更新中...


#define cell_h   40
#define window_h [UIScreen mainScreen].bounds.size.height
#define carverAnimationDefalutTime 0.15
#define tableViewMaxHeightDefalut  300
#define menuTitleDefalutFont  [UIFont systemFontOfSize:12]
#define TableTitleDefalutFont [UIFont systemFontOfSize:10]
#define menuButtonDefalutTag         700

#import "WJDropdownMenu.h"
#import <UIKit/UIKit.h>
#import "UIViewExt.h"

@interface WJDropdownMenu ()

@property (nonatomic,strong) UIView         *backView;
@property (nonatomic,strong) UITableView    *tableFirst;
@property (nonatomic,strong) UITableView    *tableSecond;
@property (nonatomic,strong) UITableView    *tableThird;

@property (nonatomic,strong) NSMutableArray *bgLayers;
@property (nonatomic,strong) NSMutableArray *dataSourceFirst;
@property (nonatomic,strong) NSMutableArray *dataSourceSecond;
@property (nonatomic,strong) NSMutableArray *dataSourceThird;

@property (nonatomic,strong) NSMutableArray *data;
@property (nonatomic,strong) NSMutableArray *allData;
@property (nonatomic,strong) NSMutableArray *allDataSource;

@property (nonatomic,assign) BOOL           firstTableViewShow;
@property (nonatomic,assign) BOOL           secondTableViewShow;
@property (nonatomic,assign) BOOL           thirdTableViewShow;

@property (nonatomic,assign) NSInteger      lastSelectedIndex;
@property (nonatomic,assign) NSInteger      lastSelectedCellIndex;
@property (nonatomic,assign) NSInteger      lastSecondCellIndex;

@property (nonatomic,assign) CGFloat        tableViewWith;
@property (nonatomic,assign) CGFloat        menuBaseHeight;

@property (nonatomic,assign) BOOL           isNet;

@property(nonatomic,assign)BOOL needTitleView;
@property(nonatomic,strong)UIView *titleView;

//当有两个视图的时候
//临时选中的省份索引,用于显示省份表视图的的背景色
@property(nonatomic,assign)NSInteger tempSelectedProvinceIndex;

//第一个表视图被选中索引
@property(nonatomic,assign)NSInteger tempProvinceCellIndex;
//第二个表视图被选中的索引
@property(nonatomic,assign)NSInteger tempcityCellIndex;
@end


@implementation WJDropdownMenu


#pragma mark - 视图生命周期及控件加载
- (void)createOneMenuTitleArray:(NSArray *)menuTitleArray FirstArray:(NSArray *)FirstArray{
    self.menuBaseHeight = self.frame.size.height;
    [self createMenuViewWithData:menuTitleArray];
    [self.allDataSource addObject:FirstArray];
    
    [self createTableViewFirst];
    [self createTableViewSecond];
}

- (void)createTwoMenuTitleArray:(NSArray *)menuTitleArray FirstArr:(NSArray *)firstArr SecondArr:(NSArray *)secondArr{
    self.menuBaseHeight = self.frame.size.height;
    [self createMenuViewWithData:menuTitleArray];
    [self.allDataSource addObject:firstArr];
    [self.allDataSource addObject:secondArr];
    
    [self createTableViewFirst];
    [self createTableViewSecond];
}
- (void)createThreeMenuTitleArray:(NSArray *)menuTitleArray FirstArr:(NSArray *)firstArr SecondArr:(NSArray *)secondArr threeArr:(NSArray *)threeArr{
    self.menuBaseHeight = self.frame.size.height;
    [self createMenuViewWithData:menuTitleArray];
    [self.allDataSource addObject:firstArr];
    [self.allDataSource addObject:secondArr];
    [self.allDataSource addObject:threeArr];
    
    [self createTableViewFirst];
    [self createTableViewSecond];
    [self createTableViewThird];
    
    self.tempSelectedProvinceIndex = 0;
    self.tempProvinceCellIndex = 0;
    self.tempcityCellIndex = 0;
    
}



- (void)createFourMenuTitleArray:(NSArray *)menuTitleArray FirstArr:(NSArray *)firstArr SecondArr:(NSArray *)secondArr threeArr:(NSArray *)threeArr fourArr:(NSArray *)fourArr{
    self.menuBaseHeight = self.frame.size.height;
    [self createMenuViewWithData:menuTitleArray];
    [self.allDataSource addObject:firstArr];
    [self.allDataSource addObject:secondArr];
    [self.allDataSource addObject:threeArr];
    [self.allDataSource addObject:fourArr];
    
    [self createTableViewFirst];
    [self createTableViewSecond];
}



#pragma mark - 使用本地数据初始化菜单组件
- (void)createMenuViewWithData:(NSArray *)data{
    self.cellHeight = self.cellHeight ? self.cellHeight : cell_h;
    //上一次选中的索引值， 默认
    self.lastSelectedIndex = -1;
    self.backgroundColor = self.CarverViewColor ? self.CarverViewColor : [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.5];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width
                            , self.menuBaseHeight);
    //添加移除手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remover)];
    [self addGestureRecognizer:tap];
    tap.delegate = self;
    
    self.bgLayers = [[NSMutableArray alloc]init];
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width
                                                            , self.menuBaseHeight)];
    self.backView.userInteractionEnabled = YES;
    self.backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backView];
    
    //创建按钮
    NSInteger num = data.count;
    CGFloat btnW = (self.frame.size.width
                    -num+1)/num;
    for (int i = 0; i < num; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((btnW+1)*i, 0, btnW, self.menuBaseHeight)];
        btn.backgroundColor = [UIColor whiteColor];
        NSInteger tempTag = self.menuButtonTag ? self.menuButtonTag :menuButtonDefalutTag;
        btn.tag = tempTag+i;
        btn.titleLabel.font = self.menuTitleFont ? [UIFont systemFontOfSize:self.menuTitleFont] : menuTitleDefalutFont;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:data[i] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(showFirstTableView:) forControlEvents:UIControlEventTouchUpInside];

        //转换图标
        CGPoint bgLayerPoint = CGPointMake(self.frame.size.width
                                           /num-10, self.menuBaseHeight/2);
        CALayer *bgLayer = [self createBgLayerWithColor:[UIColor clearColor] andPosition:bgLayerPoint];
        CGPoint indicatorPoint = CGPointMake(10, 10);
        CAShapeLayer *indicator = [self createIndicatorWithColor:[UIColor lightGrayColor] andPosition:indicatorPoint];
        [bgLayer addSublayer:indicator];
        [self.bgLayers addObject:bgLayer];
        [btn.layer addSublayer:bgLayer];
        [self.backView addSubview:btn];
    }
    
    //水平方向分割线
    for (int i = 0; i < num; i++) {
        UILabel *lineLb = [[UILabel alloc]initWithFrame:CGRectMake((btnW+1)*i+btnW, self.menuBaseHeight/10, 1, self.menuBaseHeight/10*8)];
        lineLb.backgroundColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1];// 分割线颜色
        if (i == num - 1) {
            lineLb.hidden = YES;
        }
        [self.backView addSubview:lineLb];
    }
    
    
    //顶部和底部分割线
    UILabel *VlineLbTop = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.backView.frame.size.width, 1)];
    VlineLbTop.backgroundColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1];
    // 顶部线的颜色
    UILabel *VlineLbBom = [[UILabel alloc]initWithFrame:CGRectMake(0, self.menuBaseHeight, self.backView.frame.size.width, 1)];
    // 底部线颜色
    VlineLbBom.backgroundColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1];
    
    [self.backView addSubview:VlineLbTop];
    [self.backView addSubview:VlineLbBom];
    
    //增加选择地址的提示视图
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, self.backView.bottom, kDeviceWidth, 40)];
    
    UIButton *provinceBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth/2, 40)];
    [provinceBtn setTitle:@"选择省" forState:UIControlStateNormal];
    [provinceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    provinceBtn.backgroundColor =[UIColor redColor];
    [_titleView addSubview:provinceBtn];

    UIButton *cityBtn = [[UIButton alloc] initWithFrame:CGRectMake(kDeviceWidth/2, 0, kDeviceWidth/2, 40)];
    [cityBtn setTitle:@"选择城市" forState:UIControlStateNormal];
     [cityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cityBtn.backgroundColor = [UIColor whiteColor];
    [_titleView addSubview:cityBtn];
    _titleView.hidden = YES;
    [self addSubview:_titleView];
}


- (void)changeMenuDataWithIndex:(NSInteger)index{
    //取出第一个表视图的数据
    [self createWithFirstData:self.allDataSource[index][0]];
    //根据到菜单的项目个数来确定表视图宽度
    if ([self.allDataSource[index] count] ==1) {
        self.titleView.hidden = YES;
        self.tableViewWith = self.frame.size.width;
        self.allData = nil;
        //样式设置：有分割线，无内容偏移
        self.tableFirst.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableFirst.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.tableFirst.backgroundColor = [UIColor whiteColor];
    }else if ([self.allDataSource[index] count] == 2){
        self.titleView.hidden = NO;
        //取出第二个表视图的数据:城市
        self.tableViewWith = self.frame.size.width/2;
        [self createWithSecondData:self.allDataSource[index][1]];
        //样式设置：无分割线，有内容偏移
        self.tableFirst.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableFirst.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
        self.tableFirst.backgroundColor =[UIColor whiteColor];
        
        self.tableSecond.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    }else if ([self.allDataSource[index] count] == 3){
        self.tableViewWith = self.frame.size.width/3;
        [self createWithSecondData:self.allDataSource[index][1]];
        [self createWithThirdData:self.allDataSource[index][2]];
    }
}
- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point{
    CAShapeLayer *layer = [CAShapeLayer new];
    UIBezierPath *path = [UIBezierPath new];
    
    if (self.menuArrowStyle == menuArrowStyleSolid) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(8, 0)];
        [path addLineToPoint:CGPointMake(4, 5)];
        
    }else{
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(5, 5)];
        [path moveToPoint:CGPointMake(5, 5)];
        [path addLineToPoint:CGPointMake(10, 0)];
    }
    
    
    [path closePath];
    layer.path = path.CGPath;
    
    layer.lineWidth = 0.8;
    if (self.menuArrowStyle == menuArrowStyleSolid) {
        layer.fillColor = [UIColor colorWithRed:0xcc/255.0 green:0xcc/255.0 blue:0xcc/255.0 alpha:0xcc/255.0].CGColor;
    }else{
        layer.strokeColor = [UIColor colorWithRed:0xcc/255.0 green:0xcc/255.0 blue:0xcc/255.0 alpha:0xcc/255.0].CGColor;
        layer.fillColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:255/255.0].CGColor;
    }
    
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    return layer;
}


- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position{
    CALayer *layer = [CALayer layer];
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, 20, 20);
    layer.backgroundColor = color.CGColor;
    return layer;
}


#pragma mark - 手势处理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCell"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }else{
        return YES;
    }
}
//移除菜单视图
- (void)remover{
    CALayer *layer = self.bgLayers[self.lastSelectedIndex-100];
    layer.transform = CATransform3DMakeRotation(M_PI*2, 0, 0, 1);
    
    self.firstTableViewShow = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
    }];
    self.secondTableViewShow = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableSecond.frame = CGRectMake(self.tableViewWith,CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
    }];
    self.thirdTableViewShow = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableThird.frame = CGRectMake(self.tableViewWith * 2,CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
    }];
    
    [self hideCarverView];
}



#pragma mark - 隐藏和显示遮罩视图
- (void)showCarverView{
    self.firstTableViewShow = YES;
    if (!self.caverAnimationTime) {
        self.caverAnimationTime = carverAnimationDefalutTime;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width
                            , window_h-self.frame.origin.y);
    [UIView animateWithDuration:self.caverAnimationTime animations:^{
        self.backgroundColor = self.CarverViewColor ? self.CarverViewColor : [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }];
    
}
- (void)hideCarverView{
    self.titleView.hidden = YES;
    self.firstTableViewShow = NO;
    if (!self.caverAnimationTime) {
        self.caverAnimationTime = carverAnimationDefalutTime;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width
                            , self.menuBaseHeight);
    [UIView animateWithDuration:self.caverAnimationTime animations:^{
        self.backgroundColor = self.CarverViewColor ? self.CarverViewColor : [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }];
    
}



#pragma mark - 显示表视图
//点击导航栏选项
- (void)showFirstTableView:(UIButton *)btn{
    self.allData = nil;
    self.data = nil;
    self.dataSourceSecond = nil;
    self.dataSourceThird = nil;
    
    //改变按钮的被选中样式
    NSInteger tempTag = self.menuButtonTag ? self.menuButtonTag :menuButtonDefalutTag;
    UIButton *btn0 = [self.backView viewWithTag:tempTag +0];
    UIButton *btn1 = [self.backView viewWithTag:tempTag +1];
    if (btn == btn0) {
        [btn0 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    }else{
        [btn0 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    }
    
    //默认为-1
    if (self.lastSelectedIndex != btn.tag && self.lastSelectedIndex !=-1) {
        CALayer *layer = self.bgLayers[self.lastSelectedIndex-100];
        layer.transform = CATransform3DMakeRotation(M_PI*2, 0, 0, 1);
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
            self.tableSecond.frame = CGRectMake(self.tableViewWith, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
            self.tableThird.frame = CGRectMake(self.tableViewWith * 2, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
        }completion:^(BOOL finished) {
            
            self.firstTableViewShow = NO;
            self.secondTableViewShow = NO;
            self.thirdTableViewShow = NO;
            [self showFirstAndSecondTableView:btn.tag];
            
        }];
        
    }else{
        //首次点击
        [self showFirstAndSecondTableView:btn.tag];
    }
    
    
}



- (void)showFirstAndSecondTableView:(NSInteger)index{
    NSInteger templastSelecte = self.lastSelectedIndex;
    self.lastSelectedIndex = index;
    void(^compelte)() = ^{
        //表视图的最大高度
        CGFloat TableViewW = self.cellHeight*self.dataSourceFirst.count;
        CGFloat MaxHeigth = self.tableViewMaxHeight ? self.tableViewMaxHeight : tableViewMaxHeightDefalut;
        if (TableViewW > MaxHeigth) {
            self.tableFirst.scrollEnabled = YES;
            TableViewW = MaxHeigth;
        }else{
            self.tableFirst.scrollEnabled = NO;
        }
        if (self.firstTableViewShow == NO) {
            //同时设置遮罩视图显示和表1显示
            [self showCarverView];
            CALayer *layer = self.bgLayers[index-100];
            layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            //显示表1
            self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
            [UIView animateWithDuration:0.2 animations:^{
                self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, TableViewW);
            }completion:^(BOOL finished) {
                //默认不限，首次进入，滑动到不限
                if (index == 101) {
                    //选择的地址，初始化已经选中的索引
                    _tempSelectedProvinceIndex = _tempProvinceCellIndex;
                    [self.tableFirst scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_tempSelectedProvinceIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    [self.tableFirst reloadData];
                    
                    //同时显示地址选择
                    if(_tempSelectedProvinceIndex != 0){
                        //执行表视图的点击事件，显示表2
                        [self showTableTwo];
                    }
                }
            }];
        }else{
            //第一个表视图已经处于显示状态，这时候隐藏所有视图
            //更新箭头状态
            CALayer *layer = self.bgLayers[index-100];
            layer.transform = CATransform3DMakeRotation(M_PI*2, 0, 0, 1);
            self.firstTableViewShow = NO;
            self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, TableViewW);
            //隐藏表1
            [UIView animateWithDuration:0.2 animations:^{
                self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
            }];
            //隐藏表2
            self.secondTableViewShow = NO;
            [UIView animateWithDuration:0.2 animations:^{
                self.tableSecond.frame = CGRectMake(self.tableViewWith, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
                self.tableThird.frame = CGRectMake(self.tableViewWith * 2, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
            }];
            //隐藏遮罩视图
            [self hideCarverView];
        }
    };
    
    if (self.isNet) {
        if (templastSelecte == index && self.firstTableViewShow) {
            compelte();
        }else{
            UIButton *btn = (UIButton *)[self viewWithTag:index];
            if (_delegate && [_delegate respondsToSelector:@selector(netMenuClickMenuIndex: menuTitle:)]) {
                [_delegate netMenuClickMenuIndex:index - 100 menuTitle:btn.titleLabel.text];
            }
        }
    }else{
        //非网络下：初始化数据配置
        [self changeMenuDataWithIndex:index-100];
        compelte();
    }
}




//显示第二个表视图
- (void)showSecondTabelView:(BOOL)secondTableViewShow{
    CGFloat TableViewW = self.cellHeight*self.dataSourceSecond.count;
    CGFloat MaxHeigth = self.tableViewMaxHeight ? self.tableViewMaxHeight : tableViewMaxHeightDefalut;
    if (TableViewW > MaxHeigth) {
        self.tableSecond.scrollEnabled = YES;
        TableViewW = MaxHeigth;
    }else{
        self.tableSecond.scrollEnabled = NO;
    }
    //当前第二个表视图图是显示的
    if (self.secondTableViewShow == YES) {
        [self showCarverView];
        [UIView animateWithDuration:0.2 animations:^{
            self.tableSecond.frame = CGRectMake(self.tableViewWith, CGRectGetMaxY(self.backView.frame), self.tableViewWith, TableViewW);
        }];
    }else{
        [self showCarverView];
        self.secondTableViewShow = YES;
        self.tableSecond.frame = CGRectMake(self.tableViewWith, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
        [UIView animateWithDuration:0.2 animations:^{
            self.tableSecond.frame = CGRectMake(self.tableViewWith, CGRectGetMaxY(self.backView.frame),self.tableViewWith, TableViewW);
        }completion:^(BOOL finished) {
            if (_tempcityCellIndex == 0) {
                [self.tableSecond scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }];
    }
    
}

- (void)showThirdTabelView:(BOOL)thirdTableViewShow{
    CGFloat TableViewW = self.cellHeight*self.dataSourceThird.count;
    CGFloat MaxHeigth = self.tableViewMaxHeight ? self.tableViewMaxHeight : tableViewMaxHeightDefalut;
    if (TableViewW > MaxHeigth) {
        self.tableThird.scrollEnabled = YES;
        TableViewW = MaxHeigth;
    }else{
        self.tableThird.scrollEnabled = NO;
    }
    if (self.thirdTableViewShow == YES) {
        [self showCarverView];
        [UIView animateWithDuration:0.2 animations:^{
            self.tableThird.frame = CGRectMake(CGRectGetMaxX(self.tableSecond.frame), CGRectGetMaxY(self.backView.frame), self.tableViewWith, TableViewW);
        }];
    }else{
        [self showCarverView];
        self.thirdTableViewShow = YES;
        self.tableThird.frame = CGRectMake(CGRectGetMaxX(self.tableSecond.frame), CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
        [UIView animateWithDuration:0.2 animations:^{
            self.tableThird.frame = CGRectMake(CGRectGetMaxX(self.tableSecond.frame), CGRectGetMaxY(self.backView.frame),self.tableViewWith, TableViewW);
        }];
    }
    
}

#pragma mark - 处理表视图需要的数据
- (void)createWithFirstData:(NSArray *)dataFirst{
    self.dataSourceFirst = [NSMutableArray arrayWithArray:dataFirst];
    [self.tableFirst reloadData];
}

- (void)createWithSecondData:(NSArray *)dataSecond{
    self.allData = [NSMutableArray arrayWithArray:dataSecond];
    [self.tableSecond reloadData];
    
    //[self showSecondTabelView:self.secondTableViewShow];
}

- (void)createWithThirdData:(NSArray *)dataThird{
    self.data = [NSMutableArray arrayWithArray:dataThird];
    [self.tableThird reloadData];
}


#pragma mark - 创建表视图
- (void)createTableViewFirst{
    self.tableFirst = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backView.frame),self.frame.size.width, 0) style:UITableViewStylePlain];
    self.tableFirst.scrollEnabled = NO;
    self.tableFirst.delegate = self;
    self.tableFirst.dataSource = self;
    self.tableFirst.showsVerticalScrollIndicator =NO;
    [self insertSubview:self.tableFirst belowSubview:self.backView];
    
}
- (void)createTableViewSecond{
    self.tableSecond = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.frame.size.width
                                                                    /2, 0) style:UITableViewStylePlain];
    self.tableSecond.scrollEnabled = NO;
    self.tableSecond.delegate = self;
    self.tableSecond.dataSource = self;
    self.tableSecond.autoresizesSubviews = NO;
    self.tableFirst.showsVerticalScrollIndicator =NO;

    [self insertSubview:self.tableSecond belowSubview:self.backView];
}


- (void)createTableViewThird{
    self.tableThird = [[UITableView alloc]initWithFrame:CGRectMake(self.tableViewWith*2, CGRectGetMaxY(self.backView.frame), self.frame.size.width
                                                                   /3, 0) style:UITableViewStylePlain];
    self.tableThird.scrollEnabled = NO;
    self.tableThird.delegate = self;
    self.tableThird.dataSource = self;
    self.tableThird.autoresizesSubviews = NO;
    [self insertSubview:self.tableThird belowSubview:self.backView];
}


#pragma mark - 表视图代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.cellHeight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableFirst) {
        return self.dataSourceFirst.count;
    }else if (tableView == self.tableSecond) {
        return self.dataSourceSecond.count;
    }else if (tableView == self.tableThird){
        return self.dataSourceThird.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableFirst) {
        static NSString *cellID = @"cellFirst";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell1 == nil) {
            cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }
        cell1.textLabel.text = self.dataSourceFirst[indexPath.row];
        cell1.textLabel.font = self.tableTitleFont ? [UIFont systemFontOfSize:self.tableTitleFont] : TableTitleDefalutFont;
        
        cell1.accessoryType = UITableViewCellAccessoryNone;

        if (!self.allData && !self.isNet) {
            //单组数据
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            cell1.backgroundColor = [UIColor whiteColor];
            cell1.textLabel.textColor = [UIColor blackColor];
         }else{
             if (indexPath.row == _tempSelectedProvinceIndex) {
                 cell1.backgroundColor = [UIColor whiteColor];
                 cell1.textLabel.textColor =[UIColor redColor];
             }else{
                 cell1.backgroundColor = [UIColor clearColor];
                 cell1.textLabel.textColor = [UIColor blackColor];

             }
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
         }
        return cell1;
        
    //表2
    }else if (tableView == self.tableSecond){
        static NSString *cellIde = @"cellSecond";
        
        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (cell2 == nil) {
            cell2 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIde];
        }
        if (!self.data) {
            cell2.selectionStyle = UITableViewCellSelectionStyleNone;
            cell2.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell2.selectionStyle = UITableViewCellSelectionStyleGray;
            cell2.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell2.textLabel.text = self.dataSourceSecond[indexPath.row];
        cell2.textLabel.font = self.tableTitleFont ? [UIFont systemFontOfSize:self.tableTitleFont] : TableTitleDefalutFont;
        
        //被选中颜色
        if(indexPath.row == _tempcityCellIndex){
            cell2.textLabel.textColor = [UIColor redColor];
        }else{
            cell2.textLabel.textColor =[UIColor blackColor];
        }
        return cell2;
    }else if (tableView == self.tableThird){
        static NSString *cellIde = @"cellThird";
        UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (cell3 == nil) {
            cell3 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIde];
        }
        cell3.textLabel.text = self.dataSourceThird[indexPath.row];
        cell3.selectionStyle = UITableViewCellSelectionStyleNone;
        cell3.textLabel.font = self.tableTitleFont ? [UIFont systemFontOfSize:self.tableTitleFont] : TableTitleDefalutFont;
        return cell3;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    __weak typeof(self)weakSelf = self;
    void (^complete)(void) = ^(void){
        CALayer *layer = self.bgLayers[weakSelf.lastSelectedIndex-100];
        layer.transform = CATransform3DMakeRotation(M_PI*2, 0, 0, 1);
        UIButton *btn = (id)[self viewWithTag:weakSelf.lastSelectedIndex];
        //隐藏各种表视图
        weakSelf.firstTableViewShow = NO;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(weakSelf.backView.frame), self.tableViewWith, 0);
        }];
        weakSelf.secondTableViewShow = NO;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.tableSecond.frame = CGRectMake(self.tableViewWith,CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
        }];
        weakSelf.thirdTableViewShow = NO;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.tableThird.frame = CGRectMake(self.tableViewWith * 2,CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
        }];
        [weakSelf hideCarverView];
        
        
        //=================有一级数据
        if (!weakSelf.dataSourceSecond && !weakSelf.dataSourceThird) {
            [btn setTitle:weakSelf.dataSourceFirst[indexPath.row] forState:UIControlStateNormal];
            
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstIndex:andSecondIndex:)]) {
                [_delegate menuCellDidSelected:weakSelf.lastSelectedIndex-100 firstIndex:indexPath.row andSecondIndex:0];
            }
            /*
             if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstContent:andSecondContent:)]) {
             [_delegate menuCellDidSelected:weakSelf.dataSourceFirst[indexPath.row] firstContent:weakSelf.dataSourceFirst[indexPath.row] andSecondContent:nil];
             }
             */
            
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstIndex:secondIndex:thirdIndex:)]) {
                [_delegate menuCellDidSelected:weakSelf.lastSelectedIndex-100 firstIndex:indexPath.row secondIndex:0 thirdIndex:0];
            }
            
            
            /*
             if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstContent:secondContent:thirdContent:)]) {
             [_delegate menuCellDidSelected:weakSelf.dataSourceFirst[indexPath.row] firstContent:weakSelf.dataSourceFirst[indexPath.row] secondContent:nil thirdContent:nil];
             }
             if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:menuIndex:firstContent:firstIndex:secondContent:secondIndex:thirdContent:thirdIndex:)]) {
             [_delegate menuCellDidSelected:weakSelf.dataSourceFirst[indexPath.row] menuIndex:weakSelf.lastSelectedIndex-100 firstContent:weakSelf.dataSourceFirst[indexPath.row] firstIndex:indexPath.row secondContent:nil secondIndex:-1 thirdContent:nil thirdIndex:-1];
             }
             */
        }

        
        
        //======================有二级数据
        if (weakSelf.dataSourceSecond && !weakSelf.dataSourceThird) {
            
            if (self.dataSourceSecond.count == 0) {
                [btn setTitle:@"不限" forState:UIControlStateNormal];
                //记录选中的索引
                _tempProvinceCellIndex = 0;
                _tempcityCellIndex = 0;
                if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstIndex:andSecondIndex:)]) {
                    
                    [_delegate menuCellDidSelected:weakSelf.lastSelectedIndex-100 firstIndex:0 andSecondIndex:0];
                }
                return ;
            }
            //地址字符串
            NSString *province = self.dataSourceFirst[weakSelf.lastSelectedCellIndex];
            NSString *city = self.dataSourceSecond[indexPath.row ];
            NSString *addressString = [NSString stringWithFormat:@"%@ %@",province,city];
            [btn setTitle:addressString forState:UIControlStateNormal];
            
            //记录选中的索引
            _tempProvinceCellIndex = weakSelf.lastSelectedCellIndex;
            _tempcityCellIndex = indexPath.row;
            
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstIndex:andSecondIndex:)]) {
                
                [_delegate menuCellDidSelected:weakSelf.lastSelectedIndex-100 firstIndex:weakSelf.lastSelectedCellIndex andSecondIndex:indexPath.row];
            }
            /*
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstContent:andSecondContent:)]) {
                [_delegate menuCellDidSelected:weakSelf.dataSourceSecond[indexPath.row]
                                  firstContent:weakSelf.dataSourceFirst[weakSelf.lastSelectedCellIndex]
                              andSecondContent:weakSelf.dataSourceSecond[indexPath.row]];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstIndex:secondIndex:thirdIndex:)]) {
                [_delegate menuCellDidSelected:weakSelf.lastSelectedIndex-100 firstIndex:weakSelf.lastSelectedCellIndex secondIndex:indexPath.row thirdIndex:-1];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstContent:secondContent:thirdContent:)]) {
                [_delegate menuCellDidSelected:weakSelf.dataSourceSecond[indexPath.row] firstContent:weakSelf.dataSourceFirst[weakSelf.lastSelectedCellIndex] secondContent:weakSelf.dataSourceSecond[indexPath.row] thirdContent:nil];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:menuIndex:firstContent:firstIndex:secondContent:secondIndex:thirdContent:thirdIndex:)]) {
                [_delegate menuCellDidSelected:weakSelf.dataSourceSecond[indexPath.row] menuIndex:weakSelf.lastSelectedIndex-100 firstContent:weakSelf.dataSourceFirst[weakSelf.lastSelectedCellIndex] firstIndex:weakSelf.lastSelectedCellIndex secondContent:weakSelf.dataSourceSecond[indexPath.row] secondIndex:indexPath.row thirdContent:nil thirdIndex:-1];
            }
          */
        }
        
        
        //======================有三级数据
        if (weakSelf.dataSourceSecond && weakSelf.dataSourceThird) {
            [btn setTitle:weakSelf.dataSourceThird[indexPath.row] forState:UIControlStateNormal];
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstIndex:andSecondIndex:)]) {
                
                [_delegate menuCellDidSelected:weakSelf.lastSelectedIndex-100 firstIndex:weakSelf.lastSelectedCellIndex andSecondIndex:weakSelf.lastSecondCellIndex];
                
            }
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstContent:andSecondContent:)]) {
                [_delegate menuCellDidSelected:weakSelf.dataSourceSecond[weakSelf.lastSecondCellIndex]
                                  firstContent:weakSelf.dataSourceFirst[weakSelf.lastSelectedCellIndex]
                              andSecondContent:weakSelf.dataSourceSecond[weakSelf.lastSecondCellIndex]];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstIndex:secondIndex:thirdIndex:)]) {
                [_delegate menuCellDidSelected:weakSelf.lastSelectedIndex-100 firstIndex:weakSelf.lastSelectedCellIndex secondIndex:weakSelf.lastSecondCellIndex thirdIndex:indexPath.row];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:firstContent:secondContent:thirdContent:)]) {
                [_delegate menuCellDidSelected:weakSelf.dataSourceThird[indexPath.row] firstContent:weakSelf.dataSourceFirst[weakSelf.lastSelectedCellIndex] secondContent:weakSelf.dataSourceSecond[weakSelf.lastSecondCellIndex] thirdContent:weakSelf.dataSourceThird[indexPath.row]];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(menuCellDidSelected:menuIndex:firstContent:firstIndex:secondContent:secondIndex:thirdContent:thirdIndex:)]) {
                [_delegate menuCellDidSelected:weakSelf.dataSourceThird[indexPath.row] menuIndex:weakSelf.lastSelectedIndex-100 firstContent:weakSelf.dataSourceFirst[weakSelf.lastSelectedCellIndex] firstIndex:weakSelf.lastSelectedCellIndex secondContent:weakSelf.dataSourceSecond[weakSelf.lastSecondCellIndex] secondIndex:weakSelf.lastSecondCellIndex thirdContent:weakSelf.dataSourceThird[indexPath.row]thirdIndex:indexPath.row];
            }
        }
        
        weakSelf.allData = nil;
        weakSelf.data = nil;
        weakSelf.dataSourceFirst = nil;
        weakSelf.dataSourceSecond = nil;
        weakSelf.dataSourceThird = nil;
    };
    
    //点击第一个表视图
    if (tableView == self.tableFirst) {
        NSInteger i = indexPath.row;
        //self.lastSelectedCellIndex = indexPath.row;
        if (self.isNet) {
            self.lastSelectedCellIndex = indexPath.row;
            UIButton *btn = (UIButton *)[self viewWithTag:self.lastSelectedIndex];
            if (_delegate && [_delegate respondsToSelector:@selector(netMenuClickMenuIndex:menuTitle:FirstIndex:firstContent:)]) {
                [_delegate netMenuClickMenuIndex:self.lastSelectedIndex-100 menuTitle:btn.titleLabel.text FirstIndex:i firstContent:self.dataSourceFirst[i]];
            }
        }else{
            if (self.allData) {
                self.lastSelectedCellIndex = indexPath.row;

                //当前第一个表视图显示的是省份
                _tempSelectedProvinceIndex = indexPath.row;
                //刷新选中背景
                [self.tableFirst reloadData];
                //取出二级数据
                self.dataSourceSecond = self.allData[i];
                if (self.dataSourceSecond.count == 0) {
                    //二级数据为空，说明省份选择的不限
                    complete();
                    return;
                 }
                [self.tableSecond reloadData];
                [self showSecondTabelView:self.secondTableViewShow];
             }else{
                self.lastSelectedCellIndex = indexPath.row;
                complete();
                
            }
        }
    }else if (tableView == self.tableSecond) {
        if (self.data) {
             NSInteger i = indexPath.row;
            self.lastSecondCellIndex = indexPath.row;
            self.dataSourceThird = self.data[i];
            [self.tableThird reloadData];
            [self showThirdTabelView:self.thirdTableViewShow];
        }else{
            
            complete();
        }
    }else if (tableView == self.tableThird){
        complete();
        
    }
    
}


//显示第二个表视图
- (void)showTableTwo{
    NSInteger i = _tempSelectedProvinceIndex;
    if (self.allData) {
        self.lastSelectedCellIndex = _tempSelectedProvinceIndex;
        //刷新选中背景
        [self.tableFirst reloadData];
        //取出二级数据
         self.dataSourceSecond = self.allData[i];
         if (self.dataSourceSecond.count == 0) {
             //二级数据为空，说明省份选择的不限
              return;
          }
        [self.tableSecond reloadData];
        [self showSecondTabelView:self.secondTableViewShow];
     }else{
         self.lastSelectedCellIndex = _tempSelectedProvinceIndex;
     }
        
}





- (void)drawBackMenu{
    if (!self.firstTableViewShow) {
        return;
    }
    [self netHideTable];
}



#pragma mark -- net

- (void)netHideTable{

    CALayer *layer = self.bgLayers[self.lastSelectedIndex-100];
    layer.transform = CATransform3DMakeRotation(M_PI*2, 0, 0, 1);
    self.firstTableViewShow = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
    }];
    self.secondTableViewShow = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableSecond.frame = CGRectMake(self.tableViewWith,CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
    }];
    self.thirdTableViewShow = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableThird.frame = CGRectMake(self.tableViewWith * 2,CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
    }];
    [self hideCarverView];
    self.allData = nil;
    self.data = nil;
    self.dataSourceSecond = nil;
    self.dataSourceThird = nil;
}

- (NSMutableArray *)allDataSource{
    if (_allDataSource == nil) {
        _allDataSource = [NSMutableArray array];
    }
    return _allDataSource;
}



- (void)netCreateMenuTitleArray:(NSArray *)menuTitleArray{
    self.tableViewWith = self.frame.size.width/2;
    self.isNet = YES;
    self.menuBaseHeight = self.frame.size.height;
    [self createMenuViewWithData:menuTitleArray];
    [self createTableViewFirst];
    [self createTableViewSecond];
}

- (void)netLoadSecondArray:(NSArray *)SecondArray{
    self.dataSourceSecond = [NSMutableArray arrayWithArray:SecondArray];
    [self.tableSecond reloadData];
    [self showSecondTabelView:self.secondTableViewShow];
}

- (void)netLoadFirstArray:(NSArray *)firstArray{
    [self createWithFirstData:firstArray];
    [self netShowCommentTable];
}

- (void)netShowCommentTable{
    NSInteger index = self.lastSelectedIndex;
    CGFloat TableViewW = self.cellHeight*self.dataSourceFirst.count;
    CGFloat MaxHeigth = self.tableViewMaxHeight ? self.tableViewMaxHeight : tableViewMaxHeightDefalut;
    if (TableViewW > MaxHeigth) {
        self.tableFirst.scrollEnabled = YES;
        TableViewW = MaxHeigth;
    }else{
        self.tableFirst.scrollEnabled = NO;
    }
    if (self.firstTableViewShow == NO) {
        [self showCarverView];
        CALayer *layer = self.bgLayers[index-100];
        layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
        [UIView animateWithDuration:0.2 animations:^{
            self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, TableViewW);
        }completion:^(BOOL finished) {
        }];
    }else{
        CALayer *layer = self.bgLayers[index-100];
        layer.transform = CATransform3DMakeRotation(M_PI*2, 0, 0, 1);
        self.firstTableViewShow = NO;
        self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, TableViewW);
        [UIView animateWithDuration:0.2 animations:^{
            self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
        }];
        self.secondTableViewShow = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.tableSecond.frame = CGRectMake(self.tableViewWith, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
            self.tableThird.frame = CGRectMake(self.tableViewWith * 2, CGRectGetMaxY(self.backView.frame), self.tableViewWith, 0);
        }];
        
        [self hideCarverView];
    }
}

@end
