//
//  This content is released under the MIT License: http://www.opensource.org/licenses/mit-license.html
//

#import "CGGeometry+Utils.h"

#define PG_EPS      1e-4
#define PG_MIN(A,B)	({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#define PG_MAX(A,B)	({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __b : __a; })
#define PG_ABS(A)	({ __typeof__(A) __a = (A); __a < 0 ? -__a : __a; })

const CropMetaData CropMetaDataZero = {0,{0,0,0,0},{1,0,0,1,0,0}};

CGRect CGRectConsume(CGRect r, CGPoint pt){	
	return CGRectUnion(r, CGRectMake(pt.x, pt.y, 0, 0));
}

CGPoint CGRectCenter(CGRect r){
	return CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));	
}


CGRect CGRectCenterToPoint(CGRect original, CGPoint newCenter){
	CGPoint oldCenter = CGRectCenter(original);	
	original.origin.x += (newCenter.x - oldCenter.x);
	original.origin.y += (newCenter.y - oldCenter.y);
	return original;
}


CGRect CGRectCenterToRect(CGRect original, CGRect otherRect){
	return CGRectCenterToPoint(original, CGRectCenter(otherRect));	 
}


CGFloat CGPointDistanceToPoint(CGPoint point1, CGPoint point2) {
    CGFloat xDiff = point1.x - point2.x;
    CGFloat yDiff = point1.y - point2.y;
    return sqrt(xDiff*xDiff + yDiff*yDiff);
}


CGLine CGLineMake(CGPoint point1, CGPoint point2)
{
	CGLine line;
	line.point1.x = point1.x;
	line.point1.y = point1.y;
	line.point2.x = point2.x;
	line.point2.y = point2.y;
	return line;
}

NSValue* CGLinesIntersectAtPoint(CGLine line1, CGLine line2)
{
	CGFloat mua,mub;
	CGFloat denom,numera,numerb;
    
	double x1 = line1.point1.x;
	double y1 = line1.point1.y;
	double x2 = line1.point2.x;
	double y2 = line1.point2.y;
	double x3 = line2.point1.x;
	double y3 = line2.point1.y;
	double x4 = line2.point2.x;
	double y4 = line2.point2.y;
    
	denom  = (y4-y3) * (x2-x1) - (x4-x3) * (y2-y1);
	numera = (x4-x3) * (y1-y3) - (y4-y3) * (x1-x3);
	numerb = (x2-x1) * (y1-y3) - (y2-y1) * (x1-x3);
    
	/* Are the lines coincident? */
	if (PG_ABS(numera) < PG_EPS && PG_ABS(numerb) < PG_EPS && PG_ABS(denom) < M_PI) {
		return [NSValue valueWithCGPoint:CGPointMake( (x1 + x2) / 2.0 , (y1 + y2) / 2.0)];
	}
    
	/* 是否平行 */
	if (PG_ABS(denom) < PG_EPS) {
		return nil;
	}
    
	/* 交点是否超出 */
	mua = numera / denom;
	mub = numerb / denom;
	if (mua < 0 || mua > 1 || mub < 0 || mub > 1) {
		return nil;
	}
	return [NSValue valueWithCGPoint:CGPointMake(x1 + mua * (x2 - x1), y1 + mua * (y2 - y1))];
}

BOOL CGLineAcrossRect(CGRect rect, CGLine line)
{
	CGLine top		= CGLineMake( CGPointMake( CGRectGetMinX(rect), CGRectGetMinY(rect) ), CGPointMake( CGRectGetMaxX(rect), CGRectGetMinY(rect) ) );
	CGLine right	= CGLineMake( CGPointMake( CGRectGetMaxX(rect), CGRectGetMinY(rect) ), CGPointMake( CGRectGetMaxX(rect), CGRectGetMaxY(rect) ) );
	CGLine bottom	= CGLineMake( CGPointMake( CGRectGetMinX(rect), CGRectGetMaxY(rect) ), CGPointMake( CGRectGetMaxX(rect), CGRectGetMaxY(rect) ) );
	CGLine left		= CGLineMake( CGPointMake( CGRectGetMinX(rect), CGRectGetMinY(rect) ), CGPointMake( CGRectGetMinX(rect), CGRectGetMaxY(rect) ) );
    
    return CGLinesIntersectAtPoint(line, top) || CGLinesIntersectAtPoint(right, line) || CGLinesIntersectAtPoint(bottom, line) || CGLinesIntersectAtPoint(left, line);
}