#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>

#if WD_DEBUG
#define WDLog NSLog
#else
#define WDLog(...)
#endif

#if WD_DEBUG
void PSBeginTiming();
#else
#define WDBeginTiming(...)
#endif

#if WD_DEBUG
void PSLogTiming(NSString *message); // intermediate message to log before end timing is called
#else
#define WDLogTiming(...)
#endif

#if WD_DEBUG
void PSEndTiming(NSString *message);
#else
#define WDEndTiming(...)
#endif

void HSVtoRGB(float h, float s, float v, float *r, float *g, float *b);
void RGBtoHSV(float r, float g, float b, float *h, float *s, float *v);

float PSSineCurve(float input);

void PSDrawCheckersInRect(CGContextRef ctx, CGRect dest, int size);
void PSDrawTransparencyDiamondInRect(CGContextRef ctx, CGRect dest);

void PSContextDrawImageToFill(CGContextRef ctx, CGRect bounds, CGImageRef imageRef);

CGSize PSSizeOfRectWithAngle(CGRect rect, float angle, CGPoint *upperLeft, CGPoint *upperRight);

CGPoint PSNormalizePoint(CGPoint vector);

float OSVersion();

CGRect PSGrowRectToPoint(CGRect rect, CGPoint pt);

NSData * PSSHA1DigestForData(NSData *data);

CGPoint PSSharpPointInContext(CGPoint pt, CGContextRef ctx);

CGPoint PSConstrainPoint(CGPoint pt);

CGRect PSRectFromPoint(CGPoint a, float width, float height);

CGPathRef PSConvertPathQuadraticToCubic(CGPathRef pathRef);

BOOL PSCollinear(CGPoint a, CGPoint b, CGPoint c);

BOOL PSLineInRect(CGPoint a, CGPoint b, CGRect test);

CGPathRef PSTransformCGPathRef(CGPathRef pathRef, CGAffineTransform transform);

BOOL PSLineSegmentsIntersectWithValues(CGPoint A, CGPoint B, CGPoint C, CGPoint D, float *r, float *s);
BOOL PSLineSegmentsIntersect(CGPoint A, CGPoint B, CGPoint C, CGPoint D);

CGRect PSShrinkRect(CGRect rect, float percentage);

CGAffineTransform PSTransformForOrientation(UIInterfaceOrientation orientation);

float PSRandomFloat();
int PSRandomIntInRange(int min, int max);
float PSRandomFloatInRange(float min, float max);

CGRect PSUnionRect(CGRect a, CGRect b);

void WDCheckGLError_(const char *file, int line);
#if WD_DEBUG
#define WDCheckGLError() WDCheckGLError_(__FILE__, __LINE__);
#else
#define WDCheckGLError()
#endif

NSString * generateUUID();

BOOL PSDeviceIsPhone();
BOOL PSDeviceIs4InchPhone();
BOOL PSUseModernAppearance();

BOOL PSCanUseScissorTest();

size_t PSGetTotalMemory();
BOOL PSCanUseHDTextures();

/******************************
 * WDQuad
 *****************************/

typedef struct {
    CGPoint     corners[4];
} PSQuad;

PSQuad PSQuadNull();
PSQuad PSQuadMake(CGPoint a, CGPoint b, CGPoint c, CGPoint d);
PSQuad PSQuadWithRect(CGRect rect, CGAffineTransform transform);
BOOL PSQuadEqualToQuad(PSQuad a, PSQuad b);
BOOL PSQuadIntersectsQuad(PSQuad a, PSQuad b);
CGPathRef PSQuadCreatePathRef(PSQuad q);
NSString * NSStringFromPSQuad(PSQuad quad);

/******************************
 * static inline functions
 *****************************/

static inline float PSIntDistance(int x1, int y1, int x2, int y2) {
    int xd = (x1-x2), yd = (y1-y2);
    return sqrt(xd * xd + yd * yd);
}

static inline CGPoint PSAddPoints(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint PsSubtractPoints(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGSize PSAddSizes(CGSize a, CGSize b) {
    return CGSizeMake(a.width + b.width, a.height + b.height);
}


static inline float WDDistance(CGPoint a, CGPoint b) {
    float xd = (a.x - b.x);
    float yd = (a.y - b.y);
    
    return sqrt(xd * xd + yd * yd);
}

static inline float WDClamp(float min, float max, float value) {
    return (value < min) ? min : (value > max) ? max : value;
}

static inline CGPoint PSCenterOfRect(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

static inline CGRect PSMultiplyRectScalar(CGRect r, float s) {
    return CGRectMake(r.origin.x * s, r.origin.y * s, r.size.width * s, r.size.height * s);
}

static inline CGSize PSMultiplySizeScalar(CGSize size, float s) {
    return CGSizeMake(size.width * s, size.height * s);
}

static inline CGPoint PSMultiplyPointScalar(CGPoint p, float s) {
    return CGPointMake(p.x * s, p.y * s);
}

static inline CGRect PSRectWithPoints(CGPoint a, CGPoint b) {
    float minx = MIN(a.x, b.x);
    float maxx = MAX(a.x, b.x);
    float miny = MIN(a.y, b.y);
    float maxy = MAX(a.y, b.y);
    
    return CGRectMake(minx, miny, maxx - minx, maxy - miny);
}

static inline CGRect PSRectWithPointsConstrained(CGPoint a, CGPoint b, BOOL constrained) {
    float minx = MIN(a.x, b.x);
    float maxx = MAX(a.x, b.x);
    float miny = MIN(a.y, b.y);
    float maxy = MAX(a.y, b.y);
    float dimx = maxx - minx;
    float dimy = maxy - miny;
    
    if (constrained) {
        dimx = dimy = MAX(dimx, dimy);
    }
    
    return CGRectMake(minx, miny, dimx, dimy);
}

static inline CGRect PSFlipRectWithinRect(CGRect src, CGRect dst)
{
    src.origin.y = CGRectGetMaxY(dst) - CGRectGetMaxY(src);
    return src;
}

static inline CGPoint PSFloorPoint(CGPoint pt)
{
    return CGPointMake(floor(pt.x), floor(pt.y));
}

static inline CGPoint PSRoundPoint(CGPoint pt)
{
    return CGPointMake(round(pt.x), round(pt.y));
}

static inline CGPoint PSAveragePoints(CGPoint a, CGPoint b)
{
    return PSMultiplyPointScalar(PSAddPoints(a, b), 0.5f);    
}

static inline CGSize PSRoundSize(CGSize size)
{
    return CGSizeMake(round(size.width), round(size.height));
}

static inline float PSMagnitude(CGPoint point)
{
    return WDDistance(point, CGPointZero);
}



