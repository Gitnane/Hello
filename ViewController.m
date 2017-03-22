//
//  ViewController.m
//  HelloBaiduMap
//
//  Created by 海南福泽科技  on 17/3/17.
//  Copyright © 2017年 abc. All rights reserved.
//

#import "ViewController.h"
#import "BMKClusterManager.h"
#import "BMKClusterItem.h"

/*
 *点聚合Annotation
 */
@interface ClusterAnnotation : BMKPointAnnotation

///所包含annotation个数
@property (nonatomic, assign) NSInteger size;

@end

@implementation ClusterAnnotation

@synthesize size = _size;

@end

@interface ViewController ()<BMKMapViewDelegate>
{
    BMKClusterManager *_clusterManager;//点聚合管理类
    NSInteger _clusterZoom;//聚合级别
}
@property (nonatomic, strong) BMKMapView *mapView;
@end

@implementation ViewController
@synthesize mapView = _mapView;
//在您的ViewController.m文件中添加BMKMapView的创建代码，示例如下
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    self.view = _mapView;
    _mapView.mapType = BMKMapTypeStandard;//设置地图为空白类型
    //[_mapView setTrafficEnabled:YES];//开启实时路况的核心代码,打开实时路况图层
    //[_mapView setTrafficEnabled:NO];//关闭实时路况的核心代码,关闭实时路况图层
    //_mapView.mapType = BMKMapTypeSatellite;//开启卫星图的方法,切换为卫星图

    //由卫星图切换为普通矢量图的核心代码如下：
    //切换为普通地图
    //[_mapView setMapType:BMKMapTypeStandard];

    //打开百度城市热力图图层（百度自有数据）
    [_mapView setBaiduHeatMapEnabled:YES];

    //关闭百度城市热力图图层（百度自有数据）
    //[_mapView setBaiduHeatMapEnabled:NO];

    //添加一个PointAnnotation
   /* BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
    CLLocationCoordinate2D coor;
    coor.latitude = 39.915;
    coor.longitude = 116.404;
    annotation.coordinate = coor;
    annotation.title = @"这里是北京";
    [_mapView addAnnotation:annotation];
    //if (annotation != nil) {//删除标注方法
    //[_mapView removeAnnotation:annotation];
    //}
    */
    //初始化点聚合管理类
    _clusterManager = [[BMKClusterManager alloc] init];
    //向点聚合管理类中添加点，核心代码如下
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(39.915, 116.404);
    for (NSInteger i = 0; i < 20; i++) {
        double lat =  (arc4random() % 100) * 0.001f;
        double lon =  (arc4random() % 100) * 0.001f;
        BMKClusterItem *clusterItem = [[BMKClusterItem alloc] init];
        clusterItem.coor = CLLocationCoordinate2DMake(coor.latitude + lat, coor.longitude + lon);
        [_clusterManager addClusterItem:clusterItem];
    }

    //获取聚合后的点，并添加到地图中，核心代码如下
    ///获取聚合后的标注
    _clusterZoom = (NSInteger)_mapView.zoomLevel;
    NSArray *array = [_clusterManager getClusters:_clusterZoom];
    NSMutableArray *clusters = [NSMutableArray array];
    for (BMKCluster *item in array) {
        ClusterAnnotation *annotation = [[ClusterAnnotation alloc] init];
        annotation.coordinate = item.coordinate;
        annotation.size = item.size;
        annotation.title = [NSString stringWithFormat:@"我是%ld个", item.size];
        [clusters addObject:annotation];
    }
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotations:clusters];

    //设置隐藏地图标注
    //[_mapView setShowMapPoi:NO];
  /*  //在地图上添加折线
    // 添加折线覆盖物
    CLLocationCoordinate2D coors[2] = {0};
    coors[0].latitude = 39.315;
    coors[0].longitude = 116.304;
    coors[1].latitude = 39.515;
    coors[1].longitude = 116.504;
    BMKPolyline* polyline = [BMKPolyline polylineWithCoordinates:coors count:2];
    [_mapView addOverlay:polyline];*/

    //添加分段纹理绘制折线覆盖物，核心代码如下
    //构建顶点数组
    CLLocationCoordinate2D coords[5] = {0};
    coords[0].latitude = 39.965;
    coords[0].longitude = 116.404;
    coords[1].latitude = 39.925;
    coords[1].longitude = 116.454;
    coords[2].latitude = 39.955;
    coords[2].longitude = 116.494;
    coords[3].latitude = 39.905;
    coords[3].longitude = 116.654;
    coords[4].latitude = 39.965;
    coords[4].longitude = 116.704;
    //构建分段纹理索引数组
    NSArray *textureIndex = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:0],
                             [NSNumber numberWithInt:1],
                             [NSNumber numberWithInt:2],
                             [NSNumber numberWithInt:1], nil];
    //构建BMKPolyline,使用分段纹理
    BMKPolyline* polyLine = [BMKPolyline polylineWithCoordinates:coords count:5 textureIndex:textureIndex];
    //添加分段纹理绘制折线覆盖物
    [_mapView addOverlay:polyLine];

    //添加弧线覆盖物
    //传入的坐标顺序为起点、途经点、终点
    CLLocationCoordinate2D coordsArc[3] = {0};
    coordsArc[0].latitude = 39.9374;
    coordsArc[0].longitude = 116.350;
    coordsArc[1].latitude = 39.9170;
    coordsArc[1].longitude = 116.360;
    coordsArc[2].latitude = 39.9479;
    coordsArc[2].longitude = 116.373;
    BMKArcline *arcline = [BMKArcline arclineWithCoordinates:coordsArc];
    [_mapView addOverlay:arcline];

    // 添加多边形覆盖物
    CLLocationCoordinate2D coordsPolygon[3] = {0};
    coordsPolygon[0].latitude = 39;
    coordsPolygon[0].longitude = 116;
    coordsPolygon[1].latitude = 38;
    coordsPolygon[1].longitude = 115;
    coordsPolygon[2].latitude = 38;
    coordsPolygon[2].longitude = 117;
    BMKPolygon* polygon = [BMKPolygon polygonWithCoordinates:coordsPolygon count:3];
    [_mapView addOverlay:polygon];

    // 添加圆形覆盖物
    CLLocationCoordinate2D coorCircle;
    coorCircle.latitude = 39.915;
    coorCircle.longitude = 116.404;
    BMKCircle* circle = [BMKCircle circleWithCenterCoordinate:coorCircle radius:5000];
    [_mapView addOverlay:circle];

    //添加图片图层覆盖物(第一种:根据指定经纬度坐标生成)
    /*CLLocationCoordinate2D coors;
    coors.latitude = 39.800;
    coors.longitude = 116.404;
    BMKGroundOverlay* ground = [BMKGroundOverlay groundOverlayWithPosition:coors zoomLevel:11 anchor:CGPointMake(0.0f,0.0f) icon:[UIImage imageNamed:@"test.png"]];
    [_mapView addOverlay:ground];*/

    //添加图片图层覆盖物(第二种:根据指定区域生成)
    CLLocationCoordinate2D coors[2] = {0};
    coors[0].latitude = 39.815;
    coors[0].longitude = 116.404;
    coors[1].latitude = 39.915;
    coors[1].longitude = 116.504;
    BMKCoordinateBounds bound;
    bound.southWest = coors[0];
    bound.northEast = coors[1];
    BMKGroundOverlay* ground2 = [BMKGroundOverlay groundOverlayWithBounds: bound icon:[UIImage imageNamed:@"test.png"]];
    [_mapView addOverlay:ground2];

    //添加热力图
    [self addHeatMap];

    // 在线下载，将图片存放于开发者提供的服务中，提供给SDK一个URL模板，适用于图片需要随时变更，下面举例说明添加在线瓦片图层的步骤：
    //1.根据URL模版（即指向相关图层图片的URL）创建BMKURLTileLayer对象。
    BMKURLTileLayer *urlTileLayer = [[BMKURLTileLayer alloc] initWithURLTemplate:@"http://api0.map.bdimg.com/customimage/tile?&x={x}&y={y}&z={z}&udt=20150601&customid=light"];
    //2.设置BMKURLTileLayer的可见最大/最小Zoom值。
    urlTileLayer.maxZoom = 300;//18;
    urlTileLayer.minZoom = 300;//16;
    //3.设定BMKURLTileLayer的可渲染区域。
    urlTileLayer.visibleMapRect = BMKMapRectMake(32994258, 35853667, 3122, 5541);
    //4.将BMKURLTileLayer对象添加到BMKMapView中
    [_mapView addOverlay:urlTileLayer];
    //5. 实现BMKMapViewDelegate回调，核心代码如下
    /*- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay {
        if ([overlay isKindOfClass:[BMKTileLayer class]]) {
            BMKTileLayerView *view = [[BMKTileLayerView alloc] initWithTileLayer:overlay];
            return view;
        }
        return nil;
    }*/
}
//自2.0.0起，BMKMapView新增viewWillAppear、viewWillDisappear方法来控制BMKMapView的生命周期，并且在一个时刻只能有一个BMKMapView接受回调消息，因此在使用BMKMapView的viewController中需要在viewWillAppear、viewWillDisappear方法中调用BMKMapView的对应的方法，并处理delegate，代码如下：
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    _mapView.delegate = self;
    // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    _mapView.delegate = nil; // 不用时，置nil
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;//设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

/*- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 5.0;

        return polylineView;
    }
    return nil;
}*/

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.lineWidth = 5;
        //1.使用分段纹理图片绘制
       /* polylineView.isFocus = YES;// 是否分段纹理绘制（突出显示），默认YES
        //加载分段纹理图片，必须否则不能进行分段纹理绘制
        [polylineView loadStrokeTextureImages:
         [NSArray arrayWithObjects:[UIImage imageNamed:@"poi_1.png"],
          [UIImage imageNamed:@"poi_2.png"],
          [UIImage imageNamed:@"poi_3.png"],nil]];*/

        ///2. 使用分段颜色绘制时，必须设置（内容必须为UIColor）
         polylineView.colors = [NSArray arrayWithObjects:[UIColor greenColor], [UIColor redColor], [UIColor yellowColor], nil];
        return polylineView;
    }

    //绘制弧形
    if ([overlay isKindOfClass:[BMKArcline class]]) {
        BMKArclineView* arclineView = [[BMKArclineView alloc] initWithOverlay:overlay];
        arclineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        arclineView.lineWidth = 5.0;
        return arclineView;
    }

    //绘制多边形
    if ([overlay isKindOfClass:[BMKPolygon class]]){
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polygonView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polygonView.lineWidth = 5.0;

        return polygonView;
    }

    //绘制圆
    if ([overlay isKindOfClass:[BMKCircle class]]) {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
        circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        circleView.lineWidth = 10.0;

        return circleView;
    }
    //添加图片图层
    if ([overlay isKindOfClass:[BMKGroundOverlay class]]) {
        BMKGroundOverlayView *groundView = [[BMKGroundOverlayView alloc] initWithOverlay:overlay];
        return groundView;
    }

    //添加在线瓦片图层
    if ([overlay isKindOfClass:[BMKTileLayer class]]) {
        BMKTileLayerView *view = [[BMKTileLayerView alloc] initWithTileLayer:overlay];
        return view;
    }
    return nil;
}

//添加热力图
-(void)addHeatMap{
    //创建热力图数据类
    BMKHeatMap* heatMap = [[BMKHeatMap alloc] init];
    //创建渐变色类
    UIColor* color1 = [UIColor blueColor];
    UIColor* color2 = [UIColor yellowColor];
    UIColor* color3 = [UIColor redColor];
    NSArray*colorInitialArray = [[NSArray alloc] initWithObjects:color1,color2,color3, nil];
    BMKGradient* gradient = [[BMKGradient alloc] initWithColors:colorInitialArray startPoints:@[@"0.08f", @"0.4f", @"1f"]];

    //如果用户自定义了渐变色则按自定义的渐变色进行绘制否则按默认渐变色进行绘制
    heatMap.mGradient = gradient;

    //创建热力图数据数组
    NSMutableArray* data = [NSMutableArray array];
    int num = 1000;
    for(int i = 0; i<num; i++)
    {
        //创建BMKHeatMapNode
        BMKHeatMapNode* heapmapnode_test = [[BMKHeatMapNode alloc] init];
        //此处示例为随机生成的坐标点序列，开发者使用自有数据即可
        CLLocationCoordinate2D coor;
        float random = (arc4random()%1000)*0.001;
        float random2 = (arc4random()%1000)*0.003;
        float random3 = (arc4random()%1000)*0.015;
        float random4 = (arc4random()%1000)*0.016;
        if(i%2==0){
            coor.latitude = 39.915+random;
            coor.longitude = 116.403+random2;
        }else{
            coor.latitude = 39.915-random3;
            coor.longitude = 116.403-random4;
        }
        heapmapnode_test.pt = coor;
        //随机生成点强度
        heapmapnode_test.intensity = arc4random()*900;
        //添加BMKHeatMapNode到数组
        [data addObject:heapmapnode_test];
    }
    //将点数据赋值到热力图数据类
    heatMap.mData = data;
    //调用mapView中的方法根据热力图数据添加热力图
    [_mapView addHeatMap:heatMap];
    
}
//删除热力图
-(void)removeHeatMap{
    [_mapView removeHeatMap];
}
//自定义覆盖物   暂时处理
/*- (void)glRender  {
    //自定义overlay绘制
    CustomOverlay *customOverlay = [self customOverlay];
    if (customOverlay.pointCount >= 3) {
        [self renderRegionWithPoints:customOverlay.points pointCount:customOverlay.pointCount fillColor:self.fillColor usingTriangleFan:YES];//绘制多边形
    }else
    {
        [self renderLinesWithPoints:customOverlay.points pointCount:customOverlay.pointCount strokeColor:self.strokeColor lineWidth:self.lineWidth looped:NO];//绘制线
    }
}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
