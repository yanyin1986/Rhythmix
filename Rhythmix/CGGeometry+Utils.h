//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <math.h>

//typedef CGPoint CGVector;

#define MAX_VERTEX_COUNT 8
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

CGRect CGRectConsume(CGRect r, CGPoint pt);

CGPoint CGRectCenter(CGRect r);
CGRect CGRectCenterToPoint(CGRect original, CGPoint newCenter);
CGRect CGRectCenterToRect(CGRect original, CGRect otherRect);

CGFloat CGPointDistanceToPoint(CGPoint point1, CGPoint point2);

//任意四边形，a,b,c,d为顺时针方向定点
/*
typedef struct Quadrangular {
    CGPoint a, b, c, d;
} Quad;

typedef struct Trig {
    CGPoint a, b, c;
} Trig;
*/

typedef struct Polygon {
    NSUInteger vtxCount;
    CGPoint    vertices[MAX_VERTEX_COUNT];
} Polygon;

/**
 * @brief 向量数学，为CGPoint， CGSize提供向量常用运算符
 *
 */
#pragma mark - Vector Math
/**
 * @brief 向量取反
 *
 * @param p 指定取反向量
 * @return 指定向量反方向向量
 */
static inline CGPoint CGPointNeg(CGPoint p)
{
    return  CGPointMake(-p.x, -p.y);
}

/**
 * @brief 两个向量相加 p1 + p2
 *
 * @param p1 向量1
 * @param p2 向量2
 * @return 指定向量相加的和向量
 */
static inline CGPoint CGPointAdd(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

/**
 * @brief 向量减法 p1 - p2
 *
 * @param p1 被减向量
 * @param p2 减掉向量
 * @return 差向量
 */
static inline CGPoint CGPointSub(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

/**
 * @brief 向量乘法，p1 * v
 *
 * @param p1 xiangl
 * @param <#param#>
 * @return <#return#>
 * @exception <#exception throw#>
 * @note <#note#>
 */
static inline CGPoint CGPointMul(CGPoint p1, CGFloat v)
{
    return CGPointMake(p1.x * v, p1.y * v);
}

/**
 * @brief <#brief#>
 *
 * @param <#param#>
 * @param <#param#>
 * @return <#return#>
 * @exception <#exception throw#>
 * @note <#note#>
 */
static inline CGPoint CGPointFitScale(CGPoint p1)
{
    CGPoint p = CGPointMul(p1,  [UIScreen mainScreen].scale);
    p.x = roundf(p.x);
    p.y = roundf(p.y);
    return CGPointMul(p, 1 / [UIScreen mainScreen].scale);
}

/**
 * @brief <#brief#>
 *
 * @param <#param#>
 * @param <#param#>
 * @return <#return#>
 * @exception <#exception throw#>
 * @note <#note#>
 */
static inline CGFloat CGPointCrossMul(CGPoint p1, CGPoint p2)
{
    return p1.x * p2.y - p2.x * p1.y;
}

/**
 * @brief <#brief#>
 *
 * @param <#param#>
 * @param <#param#>
 * @return <#return#>
 * @exception <#exception throw#>
 * @note <#note#>
 */
static inline CGFloat CGPointDotMul(CGPoint p1, CGPoint p2)
{
    return p1.x * p2.x + p1.y * p2.y;
}

/**
 * @brief <#brief#>
 *
 * @param <#param#>
 * @param <#param#>
 * @return <#return#>
 * @exception <#exception throw#>
 * @note <#note#>
 */
static inline CGFloat CGPointSqrLen(CGPoint p)
{
    return p.x * p.x + p.y * p.y;
}

/**
 * @brief <#brief#>
 *
 * @param <#param#>
 * @param <#param#>
 * @return <#return#>
 * @exception <#exception throw#>
 * @note <#note#>
 */
static inline CGFloat CGPointLen(CGPoint p)
{
    return sqrtf(CGPointSqrLen(p));
}

/**
 * @brief <#brief#>
 *
 * @param <#param#>
 * @param <#param#>
 * @return <#return#>
 * @exception <#exception throw#>
 * @note <#note#>
 */
static inline CGPoint CGPointNormalize(CGPoint p)
{
    double len = CGPointLen(p);
    CGPoint normal = CGPointMake(p.x / len, p.y / len);
    if (ABS(normal.x) > 1) {
        normal.x /= ABS(normal.x);
    }
    
    if (ABS(normal.y) > 1) {
        normal.y /= ABS(normal.y);
    }
    
    return normal;
}

static inline CGPoint CGPointDiv(CGPoint p1, CGFloat v)
{
    return CGPointMake(p1.x / v, p1.y / v);
}

static inline CGPoint CGPointRatio(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x / p2.x, p1.y / p2.y);
}

static inline CGPoint CGPointMulPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x * p2.x, p1.y * p2.y);
}

static inline CGPoint CGPointRound(CGPoint p)
{
    return CGPointMake(roundf(p.x), roundf(p.y));
}

static inline CGPoint CGPointFromSize(CGSize size)
{
    return CGPointMake(size.width, size.height);
}

static inline CGPoint CGPointMiddle(CGPoint s, CGPoint e)
{
    CGPoint midPoint = CGPointZero;
	midPoint.x = (s.x + e.x) / 2.0;
	midPoint.y = (s.y + e.y) / 2.0;
	return midPoint;
}

// 根据center 在 prevSize中的比例来对应到currSize中的点
static inline CGPoint CGPointTranslateBetweenTwoSize(CGPoint point, CGSize prevSize,CGSize currSize)
{
    CGFloat xRatio = point.x / prevSize.width;
    CGFloat yRatio = point.y / prevSize.height;
    
    CGPoint center = CGPointMake(xRatio * currSize.width,
                                 yRatio * currSize.height);
    center.x = center.x < 0 ? 0 : center.x;
    center.x = center.x > currSize.width ? currSize.width : center.x;
    center.y = center.y < 0 ? 0 : center.y;
    center.y = center.y > currSize.height ? currSize.height : center.y;
    
    return center;
}

#pragma mark -
#pragma mark CGVector + Util

/**
 *	获取向量
 *
 *	@param	from	出发的点
 *	@param	to      结束的点
 *
 *	@return	向量
 */
CG_INLINE CGVector CGVectorFrom(CGPoint from, CGPoint to)
{
    return CGVectorMake(to.x - from.x, to.y - from.y);
}

/**
 *	反向量
 *
 *	@param	v	向量
 *
 *	@return	向量的反方向
 */
CG_INLINE CGVector CGVectorNegative(CGVector v)
{
    return CGVectorMake(-v.dx, -v.dy);
}

/**
 *	向量相加
 *
 *	@param	v1	向量1
 *	@param	v2	向量2
 *
 *	@return	向量相加后的结果
 */
CG_INLINE CGVector CGVectorAdd(CGVector v1, CGVector v2)
{
    return CGVectorMake(v1.dx + v2.dx, v1.dy + v2.dy);
}

/**
 *	向量相减
 *
 *	@param	v1  向量1
 *	@param	v2  向量2
 *
 *	@return	相减之后的向量
 */
CG_INLINE CGVector CGVectorSub(CGVector v1, CGVector v2)
{
    return CGVectorMake(v1.dx - v2.dx, v1.dy - v2.dy);
}

/**
 *	向量放大
 *
 *	@param	v1      向量
 *	@param  scale   缩放量
 *
 *	@return	缩放后的向量
 */
CG_INLINE CGVector CGVectorMul(CGVector v1, CGFloat scale)
{
    return CGVectorMake(v1.dx * scale, v1.dy * scale);
}

/**
 *	向量缩小
 *
 *	@param	v1      向量
 *	@param  scale   缩放量
 *
 *	@return	缩放后的向量
 */
CG_INLINE CGVector CGVectorDiv(CGVector v1, CGFloat scale)
{
    return CGVectorMake(v1.dx / scale, v1.dy / scale);
}

/**
 *	向量缩放
 *
 *	@param	v1      向量
 *	@param  scale   缩放量 
 *
 *	@return	缩放后的向量
 */
CG_INLINE CGVector CGVectorRatio(CGVector v1, CGVector scale)
{
    return CGVectorMake(v1.dx / scale.dx, v1.dy / scale.dy);
}

/**
 *	向量叉积
 *
 *	@param	v1      向量1
 *	@param	v2      向量2
 *
 *	@return	向量叉积, A ∧ B = Ax By - Ay Bx
 */
CG_INLINE CGFloat CGVectorCrossMul(CGVector v1, CGVector v2)
{
    return v1.dx * v2.dy - v2.dx * v1.dy;
}

/**
 *	向量点积
 *
 *	@param	v1      向量1
 *	@param	v2      向量2
 *
 *	@return	向量点积，A • B = AxBx + AyBy
 */
CG_INLINE CGFloat CGVectorDotMul(CGVector v1, CGVector v2)
{
    return v1.dx * v2.dx + v1.dy * v2.dy;
}

/**
 *	向量模长的平方
 *
 *	@param	v       向量
 *
 *	@return	模长的平方
 */
CG_INLINE CGFloat CGVectorSqrLen(CGVector v)
{
    return v.dx * v.dx + v.dy * v.dy;
}

/**
 *	向量模长
 *
 *	@param	v       向量
 *
 *	@return	模长
 */
CG_INLINE CGFloat CGVectorLen(CGVector v)
{
    return sqrtf(CGVectorSqrLen(v));
}

/**
 *	向量单位化，返回模长为1和原向量方向相同的向量
 *
 *	@param	v       向量
 *
 *	@return 单位向量
 */
CG_INLINE CGVector CGVectorNormalize(CGVector v)
{
    double len = CGVectorLen(v);
    return CGVectorMake(v.dx / len, v.dy / len);
}

/**
 *	计算旋转的角度，支持方向（正，负），但是向量转动的角度超过90度会有错误
 *
 *	@param	from	旋转前的向量
 *	@param	to      旋转后的向量
 *
 *	@return         旋转的角度
 */
CG_INLINE CGFloat angleFromVectorTo(CGVector from, CGVector to)
{
    return asinf(CGVectorCrossMul(from, to) / (CGVectorLen(from) * CGVectorLen(to)));
}

/**
 *	计算两个向量之间的夹角，不支持方向
 *
 *	@param	from	向量1
 *	@param	to      向量2
 *
 *	@return         夹角的角度
 */
CG_INLINE CGFloat angleBetweenVectors(CGVector from, CGVector to)
{
    return acosf(CGVectorDotMul(from, to) / (CGVectorLen(from) * CGVectorLen(to)));
}


#pragma mark -
#pragma mark CGSize + Utils

static inline CGSize CGSizeAdd(CGSize s1, CGSize s2)
{
    return CGSizeMake(s1.width + s2.width, s1.height + s2.height);
}

static inline CGSize CGSizeSub(CGSize s1, CGSize s2)
{
    return CGSizeMake(s1.width - s2.width, s1.height - s2.height);
}

static inline CGSize CGSizeMul(CGSize s1, CGFloat v)
{
    return CGSizeMake(s1.width * v, s1.height * v);
}

static inline CGSize CGSizeFitScale(CGSize s1)
{
    CGSize size = CGSizeMul(s1,  [UIScreen mainScreen].scale);
    size.width = roundf(size.width);
    size.height = roundf(size.height);
    return CGSizeMul(size, 1 / [UIScreen mainScreen].scale);
}

static inline CGSize CGSizeDiv(CGSize s1, CGFloat v)
{
    return CGSizeMake(s1.width / v, s1.height / v);
}

static inline CGSize CGSizeRatio(CGSize s1, CGSize s2)
{
    return CGSizeMake(s1.width / s2.width, s1.height / s2.height);
}

static inline CGSize CGSizeMulSize(CGSize s1, CGSize s2)
{
    return CGSizeMake(s1.width * s2.width, s1.height * s2.height);
}

static inline CGFloat CGSizeMaxSide(CGSize size)
{
    return MAX(size.width, size.height);
}

static inline CGFloat CGSizeMinSide(CGSize size)
{
    return MIN(size.width, size.height);
}

static inline CGPoint CGPointAddSize(CGPoint p, CGSize s)
{
    return CGPointMake(p.x + s.width, p.y + s.height);
}

static inline CGSize CGSizeAddPoint(CGSize s, CGPoint p)
{
    return CGSizeMake(s.width + p.x, s.height + p.y);
}

static inline CGSize CGSizeAspectFill(CGSize origin, CGSize target)
{
    CGSize ratio = CGSizeRatio(target, origin);
    return CGSizeMul(origin, MAX(ratio.width, ratio.height));
}

static inline CGSize CGSizeAspectFit(CGSize origin, CGSize target)
{
    CGSize ratio = CGSizeRatio(target, origin);
    return CGSizeMul(origin, MIN(ratio.width, ratio.height));
}

static inline BOOL CGSizeEqualWithEpsilon(CGSize s1, CGSize s2, CGFloat epsilon)
{
    return (ABS(s1.width - s2.width) < epsilon &&
            ABS(s1.height - s2.height) < epsilon);
}

static inline CGSize CGSizeAbs(CGSize size)
{
    return CGSizeMake(ABS(size.width), fabs(size.height));
}

static inline CGFloat triangleArea2(CGPoint a, CGPoint b, CGPoint c)
{
    return ABS(a.x * b.y + b.x * c.y + c.x * a.y - b.x * a.y - c.x * b.y - a.x * c.y);
}

static inline CGRect CGRectMakeWithOriginAndSize(CGPoint origin, CGSize size)
{
    return (CGRect){.origin = origin, .size = size};
}

static inline CGRect CGRectMakeWithAnchorPointAndSize(CGPoint anchorPoint, CGPoint point, CGSize size)
{
    CGPoint origin =  CGPointSub(point, CGPointMulPoint(anchorPoint, CGPointFromSize(size)));
    return CGRectMakeWithOriginAndSize(origin,size);
}

static inline CGRect CGRectMakeWithCenterAndSize(CGPoint center, CGSize size)
{
    return CGRectMake(center.x - size.width / 2, center.y - size.height / 2, size.width, size.height);
}

static inline CGRect CGRectAspectRectToFill(CGRect rect, CGSize size)
{
    CGFloat ratio1 = rect.size.width / rect.size.height;
    CGFloat ratio2 = size.width / size.height;
    CGFloat scale = 0;
    if (ratio1 > ratio2) {
        scale = rect.size.width / size.width;
    } else {
        scale = rect.size.height / size.height;
    }
    
    CGSize scaledSize = CGSizeMul(size, scale);
    CGSize delta = CGSizeDiv(CGSizeSub(scaledSize, rect.size), 2);
    CGPoint point = CGPointSub(rect.origin, CGPointFromSize(delta));
    CGRect result = {
        .origin = point,
        .size  = scaledSize,
    };
    
    return result;
}

// 面积浮点误差范围
#define AREA_EPSILON 0.1f

static inline BOOL polygonIsRect(const Polygon *p)
{
    return (p->vtxCount == 4 &&
            p->vertices[0].y == p->vertices[1].y &&
            p->vertices[1].x == p->vertices[2].x &&
            p->vertices[2].y == p->vertices[3].y &&
            p->vertices[3].x == p->vertices[0].x);
}

static inline void setPolygonWithRect(Polygon *p, CGRect r)
{
    p->vtxCount = 4;
    p->vertices[0] = r.origin;
    p->vertices[1] = CGPointMake(r.origin.x + r.size.width, r.origin.y);
    p->vertices[2] = CGPointAddSize(r.origin, r.size);
    p->vertices[3] = CGPointMake(r.origin.x, r.origin.y + r.size.height);
}

static inline Polygon polygonWithCGRect(CGRect r)
{
    Polygon p;
    setPolygonWithRect(&p, r);
    return p;
}

static inline CGRect polygonToCGRect(const Polygon *p)
{
    assert(p && p->vtxCount == 4);
    CGPoint size = CGPointSub(p->vertices[2], p->vertices[0]);
    return (CGRect){.origin = p->vertices[0], .size = {size.x, size.y}};
}
/**
 * @brief 计算四边形的外接矩形
 *
 * @param q 任意四边形
 * @return 返回四边形的外接矩形CGRect
 * @note 此处不使用循环，便于编译器做内联展开和自动向量化
 */
static inline CGRect externalRectOfPolygon(const Polygon *p)
{
    assert(p && p->vtxCount >= 3);
    CGPoint min = p->vertices[0];
    CGPoint max = p->vertices[0];
    
    for (int i = 1; i < p->vtxCount; i++) {
        min.x = min.x > p->vertices[i].x ? p->vertices[i].x : min.x;
        min.y = min.y > p->vertices[i].y ? p->vertices[i].y : min.y;
        max.x = max.x < p->vertices[i].x ? p->vertices[i].x : max.x;
        max.y = max.y < p->vertices[i].y ? p->vertices[i].y : max.y;
    }
    
    return CGRectMake(min.x, min.y, max.x - min.x, max.y - min.y);
}

static inline void polygonTransplate(const Polygon *src, Polygon *dst, CGPoint offset)
{
    dst->vtxCount = src->vtxCount;
    for (int i = 0; i < src->vtxCount; i++) {
        dst->vertices[i] = CGPointAdd(src->vertices[i], offset);
    }
}

static inline Polygon polygonWithPoints(CGPoint points[], int count)
{
    Polygon p;
    p.vtxCount = count;
    for (int i = 0; i < count; i++) {
        p.vertices[i] = points[i];
    }
    return p;
}


static inline BOOL pointInTriangle(CGPoint p, CGPoint a, CGPoint b, CGPoint c)
{
    return (CGPointCrossMul(CGPointSub(b, a), CGPointSub(p, a)) < 0
            && CGPointCrossMul(CGPointSub(c, b), CGPointSub(p, b)) < 0
            && CGPointCrossMul(CGPointSub(a, c), CGPointSub(p, c)) < 0);
}

// 点是否在多边形内部
// 少于3边返回no
// 多于3边，取一个原点，分割成多个三角形判断
static inline BOOL pointInsidePolygon(const Polygon polygon, CGPoint p)
{
    if (polygon.vtxCount < 3) {
        return NO;
    }
    
    CGPoint originPoint = polygon.vertices[0];
    for (int i = 2; i < polygon.vtxCount; i++) {
        if (pointInTriangle(p, originPoint, polygon.vertices[i], polygon.vertices[i-1])) {
            return YES;
        }
    }
    return NO;
}

typedef enum {
    LineIntersectTypeCross,
    LineIntersectTypeParallel,
    LineIntersectTypeSame,
} LineIntersectType;

static inline BOOL floatEqual(CGFloat x, CGFloat y)      // eqaul, x == y
{
    const CGFloat EPSILON = 0.001;     //计算精度
    return (ABS(x - y) < EPSILON);
}

static inline BOOL floatEqualWithEpsilon(CGFloat x, CGFloat y, CGFloat epsilon)
{
    return ABS(x - y) < epsilon;
}

static inline LineIntersectType
getIntersectOf(CGPoint L11, CGPoint L12, CGPoint L21, CGPoint L22, CGPoint *intersect)
{
    
    //L1: a1x+b1y=c1
    CGFloat a1 = L12.y - L11.y;
    CGFloat b1 = L11.x - L12.x;
    CGFloat c1 = L12.x * L11.y - L11.x * L12.y ;
    
    //L2: a2x+b2y=c2
    CGFloat a2 = L22.y - L21.y;
    CGFloat b2 = L21.x - L22.x;
    CGFloat c2 = L22.x * L21.y - L21.x * L22.y;
    
    if (floatEqual(a1 * b2, b1 * a2)) {
        if (floatEqual((a1 + b1) * c2, (a2 + b2) * c1)) {
            return LineIntersectTypeSame;
        } else {
            intersect->x = ABS(c2 - c1) / sqrtf(a1 * a1 + b1 * b1);
            return LineIntersectTypeParallel;
        }
    } else {
        intersect->x = (b2 * c1 - b1 * c2) / (a2 * b1 - a1 * b2);
        intersect->y = (a1 * c2 - a2 * c1) / (a2 * b1 - a1 * b2);
        return LineIntersectTypeCross;
    }
}

//计算点到线段的距离
static inline double msDistancePointToSegment(CGPoint p1,CGPoint p2,CGPoint p)
{
    double l; /* length of line ab */
    double r,s;
    
    l =  CGPointDistanceToPoint(p1,p2);
    if(floatEqualWithEpsilon(l ,0.0, 0.1)) /* a = b */
        return CGPointDistanceToPoint(p1,p);
    
    r = ((p1.y - p.y)*(p1.y - p2.y) - (p1.x - p.x)*(p2.x - p1.x))/(l*l);
    
    if(r > 1) /* perpendicular projection of P is on the forward extention of p1p2 */
        return(MIN(CGPointDistanceToPoint(p,p2),CGPointDistanceToPoint(p ,p1)));
    
    if(r < 0) /* perpendicular projection of P is on the backward extention of p1p2 */
        return(MIN(CGPointDistanceToPoint(p,p2),CGPointDistanceToPoint(p ,p1)));
    
    s = ((p1.y - p.y)*(p2.x - p1.x) - (p1.x - p.x)*(p2.y - p1.y))/(l*l);
    
    return(fabs(s*l));
}

static inline CGFloat maxCornerRadiusOfPolgyon(const Polygon *p)
{
    const CGPoint *points = &(p->vertices[0]);
    
    CGFloat minRadius = CGFLOAT_MAX;
    
    if (polygonIsRect(p)) {
        CGRect rect = polygonToCGRect(p);
        CGFloat min = MIN(rect.size.width, rect.size.height);
        return min / 2;
    } else if (p->vtxCount == 3) {
        CGPoint ab = CGPointSub(p->vertices[1], p->vertices[0]);
        CGPoint ac = CGPointSub(p->vertices[2], p->vertices[0]);
        CGPoint bc = CGPointSub(p->vertices[2], p->vertices[1]);
        
        return ABS(CGPointCrossMul(ab, ac)) / (CGPointLen(ab) + CGPointLen(ac) + CGPointLen(bc));
    }
    
    NSInteger count = p->vtxCount;
    for (NSInteger i = 0; i < count; i++) {
        NSInteger prev = (i + count - 1) % count;
        NSInteger next = (i + 1) % count;
        NSInteger nextNext = (i + 2) % count;
        
        CGPoint inter = CGPointZero;
        CGFloat radius = CGFLOAT_MAX;
        
        CGPoint ad = CGPointSub(points[prev], points[i]);
        CGPoint ab = CGPointSub(points[next], points[i]);
        CGPoint bc = CGPointSub(points[next], points[nextNext]);
        
        CGFloat crossResult = ABS(CGPointCrossMul(ad, bc));
        
        if (floatEqualWithEpsilon(crossResult, 0, 0.01f)) {
            radius = ABS(CGPointCrossMul(ad, ab) * 0.5f) / CGPointLen(ad);
        } else {
            getIntersectOf(points[prev], points[i], points[next], points[nextNext], &inter);
            
            CGPoint ia = CGPointSub(points[i], inter);
            CGPoint ib = CGPointSub(points[next], inter);
            
            radius = ABS(CGPointCrossMul(ia, ib)) / (CGPointLen(ia) + CGPointLen(ib) - CGPointLen(ab));
        }
        
        if (radius < minRadius) {
            minRadius = radius;
        }
    }
    
    return minRadius;
}

static inline CGPoint midPointOfPolygon(const Polygon *p, NSInteger edgeIdx)
{
    assert(p && p->vtxCount > edgeIdx);
    CGPoint from = p->vertices[edgeIdx];
    CGPoint to = p->vertices[(edgeIdx + 1) % p->vtxCount];
    return CGPointMul(CGPointAdd(from, to), 0.5);
}

static inline CGPoint edgeOfPolygon(const Polygon *p, NSInteger edgeIdx)
{
    assert(p && p->vtxCount > edgeIdx);
    CGPoint from = p->vertices[edgeIdx];
    CGPoint to = p->vertices[(edgeIdx + 1) % p->vtxCount];
    return CGPointSub(to, from);
}

static inline CGPoint CGPointRotate(CGPoint p, CGPoint rotation)
{
    return CGPointMake(p.x * rotation.x - p.y * rotation.y, p.x * rotation.y + p.y * rotation.x);
}

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_floor(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return floor(cgfloat);
#else
    return floorf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_round(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_sqrt(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return sqrt(cgfloat);
#else
    return sqrtf(cgfloat);
#endif
}

static inline CGSize maxInnerSizeOfRotatedSize(CGSize src, CGPoint rotation, CGSize dest)
{
    CGPoint a = CGPointMake(src.width /  2, src.height / 2);
    CGPoint b = CGPointMake(a.x, -a.y);
    CGPoint c = CGPointMake(-a.x, -a.y);
    CGPoint d = CGPointMake(-a.x, a.y);
    
    CGPoint a1 = CGPointRotate(a, rotation);
    CGPoint b1 = CGPointRotate(b, rotation);
    CGPoint c1 = CGPointRotate(c, rotation);
    CGPoint d1 = CGPointRotate(d, rotation);
    
    CGPoint list[] = {a1, b1, c1, d1};
    
    CGFloat slope = dest.height / dest.width;
    
    int sign = (list[0].y - list[0].x * slope > 0 ? 1 : -1);
    CGSize result = CGSizeZero;
    
    for (int i = 1; i < 4; i++) {
        int tmpSign = (list[i].y - list[i].x * slope > 0 ? 1 : -1);
        if (tmpSign != sign) {
            CGPoint ab = CGPointSub(list[i -1], list[i]);
            
            CGPoint p1 = CGPointZero;
            if (ab.x == 0) {
                p1.x = list[i].x;
                p1.y = p1.x * slope;
            } else {
                CGFloat t = ab.y / ab.x;
                p1.x = (list[i].x * t - list[i].y)  / (t - slope);
                p1.y = slope * p1.x;
            }
            
            CGPoint p2 = CGPointMake(-p1.x, -p1.y);
            result = CGSizeMake(ABS(p1.x - p2.x), ABS(p1.y - p2.y));
            break;
        } else {
            sign =  tmpSign;
        }
    }
    
    return result;
}

static inline CGFloat scaleForCGAffineTransform(CGAffineTransform trans)
{
    return sqrtf(powf(trans.a, 2) + powf(trans.c, 2));
}

#pragma mark -  UIEdgeInsetsMake tools
static inline UIEdgeInsets UIEdgeInsetsMakeMul(UIEdgeInsets edgeInset, CGFloat ratio)
{
    return UIEdgeInsetsMake(edgeInset.top * ratio, edgeInset.left * ratio, edgeInset.bottom * ratio, edgeInset.right * ratio);
}

static inline UIEdgeInsets UIEdgeInsetsFromRects(CGRect from, CGRect to)
{
    CGSize deltaSize = CGSizeSub(to.size, from.size);
    CGPoint deltaPos = CGPointSub(to.origin, from.origin);
    UIEdgeInsets insets = {
        .top   = deltaPos.y,
        .left  = deltaPos.x,
        .bottom= (deltaPos.y + deltaSize.height) * -1,
        .right = (deltaPos.x + deltaSize.width) * -1
    };
    
    return insets;
}


// 背景裁剪元数据
typedef struct BackgroundCropMetaData {
    CGFloat             containerWidth;     // 容器宽度
    CGRect              cropRect;           // 截取框大小
    CGAffineTransform   transform;          // 容器的transform
} CropMetaData;

extern const CropMetaData CropMetaDataZero;

static inline BOOL CropDataIsZero(CropMetaData data)
{
    return CGRectIsEmpty(data.cropRect);
}

static inline BOOL CropDataIsEqual(CropMetaData data1,CropMetaData data2)
{
    return (floatEqual(data1.containerWidth, data2.containerWidth)
            && CGRectEqualToRect(data1.cropRect, data2.cropRect)
            && CGAffineTransformEqualToTransform(data1.transform, data2.transform));
}

static inline CGSize SizeForImageCropped(CropMetaData cropMetaData,CGSize originImageSize)
{
    if (CropDataIsZero(cropMetaData)) {
        return originImageSize;
    }

    CGFloat scaleForCropTransform = scaleForCGAffineTransform(cropMetaData.transform);
    
    CGFloat scale = originImageSize.width / (cropMetaData.containerWidth * scaleForCropTransform);
    CGSize size = CGSizeMul(cropMetaData.cropRect.size, scale);
    return size;
}

/**
 * 边缘检测 让tile不能过分超出canvas
 **/
typedef struct {
	CGPoint point1;
	CGPoint point2;
} CGLine;

CGLine CGLineMake(CGPoint point1, CGPoint point2);

NSValue* CGLinesIntersectAtPoint(CGLine line1, CGLine line2);

BOOL CGLineAcrossRect(CGRect rect, CGLine line);