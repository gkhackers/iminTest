// CoordTrans.h: interface for the CCoordTrans class.
//
//////////////////////////////////////////////////////////////////////

#ifdef __OBJC__
    #import <Foundation/Foundation.h>
#endif

#include <Math.h>

#define PI 3.14159265358979
#define EPSLN 0.0000000001
#define dX_W2B 128
#define dY_W2B -481
#define dZ_W2B -664
#define BESSEL 0
#define WGS84 1
#define TM_W 0
#define TM_M 1
#define TM_E 2
#define KATEC 3
#define UTM_Zone52 4
#define UTM_Zone51 5
// #define LON_LAT 6

/*extern double major[];
 extern double minor[];
 extern double SF[];
 extern double LonCen[];
 extern double LatCen[];
 extern double FN[];
 extern double FE[]; */
static double major_map[] = {6377397.155, 6378137.0};
static double minor_map[] = {6356078.96325, 6356752.3142};
static double SF[] = {1, 1, 1, 0.9999, 0.9996, 0.9996};
static double LonCen[] = {2.18171200985643, 2.21661859489632, 2.2515251799362,  2.23402144255274,
	2.25147473507269,  2.14675497995303};
static double LatCen[] = {0.663225115757845, 0.663225115757845, 0.663225115757845,  0.663225115757845, 0, 0};
static double FN[] = {500000, 500000,  500000, 600000, 0.0, 0.0};
static double FE[] = {200000, 200000, 200000, 400000, 500000, 500000};

class LonAndLat
{
public:
  double _lon;
  double _lat;
  double _h;

public:
  LonAndLat() {
    _lon = 0;
    _lat = 0;
    _h = 0;
  }
  LonAndLat(double lon, double lat) {
    _lon = lon;
    _lat = lat;
    _h = 0;
  }
  void setValues(double lon, double lat) {
    _lon = lon;
    _lat = lat;
    _h = 0;
  }
  void setLon(double lon){
    _lon = lon;
  }
  double getLon() {
    return _lon;
  }
  void setLat(double lat) {
    _lat = lat;
  }
  double getLat() {
    return _lat;
  }
  void setH(double h) {
    _h = h;
  }
  double getH() {
    return _h;
  }
};

class DMS
{
public:
  int _lonDeg;
  int _lonMin;
  double _lonSec;
  int _latDeg;
  int _latMin;
  double _latSec;
public:
  DMS() { }
  DMS(int lonDeg, int lonMin, int lonSec, int latDeg, int latMin, int latSec) {
    _lonDeg = lonDeg;
    _lonMin = lonMin;
    _lonSec = lonSec;
    _latDeg = latDeg;
    _latMin = latMin;
    _latSec = latSec;
  }
  int getLonDeg(){return _lonDeg;}
  void setLonDeg(int lonDeg){_lonDeg = lonDeg;}
  int getLonMin(){return _lonMin;}
  void setLonMin(int lonMin){_lonMin = lonMin;}
  int getLonSec(){return (int)_lonSec;}
  void setLonSec(int lonSec){_lonSec = (double)lonSec;}
  int getLatDeg(){return (int)_latDeg;}
  void setLatDeg(int latDeg){_latDeg = latDeg;}
  int getLatMin(){return _latMin;}
  void setLatMin(int latMin){_latMin = latMin;}
  int getLatSec(){return (int)_latSec;}
  void setLatSec(int latSec){_latSec = (double)latSec;}
};

class TM
{
public:
  double _x;
  double _y;
  double _h;
public:
  TM() {
    _x = 0;
    _y = 0;
    _h = 0;
  }
  TM(double x, double y) {
    _x = x;
    _y = y;
    _h = 0;
  }
  void setValues(double x, double y) {
    _x = x;
    _y = y;
    _h = 0;
  }
  void setX(double x) {
    _x = x;
  }
  double getX() {
    return _x;
  }
  void setY(double y) {
    _y = y;
  }
  double getY() {
    return _y;
  }
  double getH() {
    return _h;
  }
  void setH(double h) {
    _h = h;
  }
};

class Adjustment
{
public:
  int ind;
  double r_major, r_minor;
  double scale_factor;
  double lon_center, lat_origin;
  double false_northing, false_easting;
  double e0, e1, e2, e3;
  double e, es, esp, ml0;
};




class CCoordTrans
{
public:
  CCoordTrans() { }
  virtual ~CCoordTrans();

  /**
  * 경위도 좌표를 TM유형좌표로 변환
  * 타원체를 먼저 변경한다음 경위도 좌표를 TM 좌표로 변환
  * @param inputL 입력 경위도 좌표
  * @param inputEllipse 입력 경위도 좌표에 대한 타원체 유형(WGS84, BESSEL) 보통 GPS값은 WGS84임
  * @param targetCoordinates 출력 좌표계(TM_W, TM_M, TM_E, KATEC, UTM_Zone52, UTM_Zone51중의 하나이어야함)
  * @return TM TM계열의 좌표
  */
public:
  static TM convLLToTM(LonAndLat inputL, int inputEllipse, int targetCoordinates)
  {
    LonAndLat LL;
    LL.setValues(inputL.getLon(), inputL.getLat());
    Adjustment A;
    //convert degree to radian
    LL._lon = inputL._lon * PI / 180.0f;
    LL._lat = inputL._lat * PI / 180.0f;
    // 타원체를 먼저 변경한다.
    LonAndLat outputL;
    /*if (inputEllipse != BESSEL)  */outputL = datumTrans(LL, inputEllipse,  BESSEL);
    //System.out.println("타원체 변경후:"+outputL._lon*180/PI+"  "+outputL._lat*180/PI);
    //Adjustment A = new Adjustment();
    // 경위도 좌표를 TM좌표로 변경한다.
    setAdjustment(BESSEL, targetCoordinates, A);
    TM T = LLtoTM(outputL, A);
    T._h = outputL._h;
    return T;
  }

  /**
  * TM유형좌표를 경위도 좌표로 변환
  * 먼저 TM 좌표를 경위도로 변환한다음 타원체를 변경한다.
  * @param T 입력 경위도 좌표
  * @param inputCoordinates  입력 좌표계(TM_W, TM_M, TM_E, KATEC, UTM_Zone52, UTM_Zone51중의 하나이어야함)
  * @param targetEllipse 출력 경위도 좌표에 대한 타원체 유형(WGS84, BESSEL) 보통 GPS값은 WGS84임
  * @return LonAndLat 경위도좌표
  */
  static LonAndLat convTMToLL(TM inputT, int inputCoordinates, int targetEllipse)
  {
    TM tm;
    tm.setValues(inputT.getX(), inputT.getY());
    Adjustment A;
    // TM좌표 -> 경위도로 변환
    //Adjustment A = new Adjustment();
    setAdjustment(BESSEL, inputCoordinates, A);
    LonAndLat inputL = TMToLL(tm, A);
    //System.out.println("좌표변환후 :"+inputL._lon +"  "+inputL._lat);
    //System.out.println(inputL._lon*180.0f/PI+"   "+inputL._lat*180.0f/PI);
    // 타원체를 변경한다.
    LonAndLat outputL = datumTrans(inputL, BESSEL, targetEllipse);
    outputL._lon = outputL._lon*180.0f/PI;
    outputL._lat = outputL._lat*180.0f/PI;
    return outputL;
  }
  /**
  * TM유형좌표간의 변환
  * @param inputT 입력 TM 계열 좌표
  * @param inCoord 입력 좌표계(TM_W, TM_M, TM_E, KATEC, UTM_Zone52, UTM_Zone51중의 하나이어야함)
  * @param outCoord 출력 좌표계(TM_W, TM_M, TM_E, KATEC, UTM_Zone52, UTM_Zone51중의 하나이어야함)
  * @return TM 출력 TM계열 좌표
  */
  static TM convTMToTM(TM inputT, int inCoord, int outCoord)
  {
    TM tm;
    tm.setValues(inputT.getX(), inputT.getY());
    Adjustment A;
    //Adjustment A = new Adjustment();
    setAdjustment(BESSEL, inCoord, A);
    //System.out.println("inputT"+inputT._x+" " +inputT._y);
    LonAndLat outputL = TMToLL(tm, A);
    //System.out.println("outputL"+outputL._lon+" "+outputL._lat);

    setAdjustment(BESSEL, outCoord, A);
    TM outputT = LLtoTM(outputL, A);
    //System.out.println("TM 변환후"+outputT._x+" "+outputT._y);
    outputT._h = outputL._h;
    return outputT;
  }

  static LonAndLat convWGS84ToBESSEL(LonAndLat in)
  {
    LonAndLat inputL;
    inputL._lon = in._lon * PI / 180.0f;
    inputL._lat = in._lat * PI / 180.0f;
    LonAndLat outputL = CCoordTrans::datumTrans(inputL, WGS84, BESSEL);
    outputL._lon = outputL._lon*180.0f/PI;
    outputL._lat = outputL._lat*180.0f/PI;
    return outputL;
  }


  /**
  * 타원체 변환 루틴 Molodensky Datum Transformation fuction
  */
  static LonAndLat datumTrans(LonAndLat inputL, int inputEllipse, int outputEllipse)
  {
    // input_Phi, input_Lamda, input_H
    // inputL._lon, inputL._lat, inputL._h
    // output_Phi, output_Lamda, output_H
    // ouputL._lon, outputL._lat, outputL._h
    // delta_X, delta_Y, delta_Z
    LonAndLat outputL;
    double input_a = major_map[inputEllipse];
    double input_b = minor_map[inputEllipse];
    double output_a = major_map[outputEllipse];
    double output_b = minor_map[outputEllipse];
    double delta_a, delta_f, delta_Phi, delta_Lamda, delta_H;
    double Rm, Rn;
    double temp, es_temp;
    int gap = inputEllipse - outputEllipse;
    double delta_X = gap*dX_W2B;
    double delta_Y = gap*dY_W2B;
    double delta_Z = gap*dZ_W2B;

    temp = input_b / input_a;
    es_temp = 1.0f - temp*temp;
    delta_a = output_a - input_a;
    delta_f = input_b / input_a - output_b / output_a;

    Rm =(input_a * (1.0f - es_temp)) / pow((1.0f - es_temp * sin(inputL._lat) * sin(inputL._lat)), (3.0f/2.0f));
    Rn = input_a / pow((1.0f - es_temp * sin(inputL._lat) * sin(inputL._lat)), (1.0f/ 2.0f));
    delta_Phi = ((((-delta_X * sin(inputL._lat) * cos(inputL._lon) - delta_Y * sin(inputL._lat) * sin(inputL._lon))
          + delta_Z * cos(inputL._lat)) + delta_a * Rn * es_temp * sin(inputL._lat) * cos(inputL._lat) / input_a)
          + delta_f * (Rm / temp + Rn * temp) * sin(inputL._lat) * cos(inputL._lat)) / (Rm + inputL._h);
    //System.out.println(delta_Phi);
    delta_Lamda = ((-delta_X) * sin(inputL._lon) + delta_Y * cos(inputL._lon)) / ((Rn + inputL._h) * cos(inputL._lat));
    delta_H = delta_X * cos(inputL._lat) * cos(inputL._lon) + delta_Y * cos(inputL._lat) * sin(inputL._lon)
      + delta_Z * sin(inputL._lat) - delta_a * input_a / Rn + delta_f * temp * Rn * sin(inputL._lat) * sin(inputL._lat);
    //System.out.println(delta_Lamda);

    outputL._lat = inputL._lat + delta_Phi;
    outputL._lon = inputL._lon + delta_Lamda;
    outputL._h = inputL._h + delta_H;

    return outputL;
  }

  // ellipse - 현재 타원체를 입력받는다.
  // coordinates - 현재 좌표계를 입력받는다.

public:
  static void setAdjustment(int ellipse, int coordinates, Adjustment &A)
  {
    A.r_major = major_map[ellipse];
    A.r_minor = minor_map[ellipse];
    A.scale_factor = SF[coordinates];
    A.lon_center = LonCen[coordinates];
    A.lat_origin = LatCen[coordinates];
    A.false_northing = FN[coordinates];
    A.false_easting = FE[coordinates];
    double temp = A.r_minor / A.r_major;
    A.es = 1.0f - temp*temp;
    A.e = sqrt(A.es);
    A.e0 = e0fn(A.es);
    A.e1 = e1fn(A.es);
    A.e2 = e2fn(A.es);
    A.e3 = e3fn(A.es);
    A.ml0 = A.r_major * mlfn(A.e0, A.e1, A.e2, A.e3, A.lat_origin);
    A.esp = A.es / (1.0f - A.es);
    if(A.es < 0.00001f)
      A.ind = 1;
    else
      A.ind = 0;
  }

  /**
  * Function for converting TM X, Y to longitude and latitude
  */
  static LonAndLat TMToLL(TM T, Adjustment &A)
  {
    //System.out.println("A.e0"+A.e0);
    LonAndLat L;
    double con, phi, delta_phi, sin_phi, cos_phi, tan_phi;
    double c, cs, t, ts, n, r, d, ds, f, h, g, temp;
    long max_iter = 6;
    long i;
    if (A.ind != 0) {
      f = exp(T._x / (A.r_major * A.scale_factor));
      g = 0.5 * (f - 1.0f / f);
      temp = A.lat_origin + T._y / (A.r_major * A.scale_factor);
      h = cos(temp);
      con = sqrt((1.0f - h * h) / (1.0f + g * g));
      L._lat= asinz(con);
      if (temp < 0)
        L._lat = -L._lat;
      if ((g == 0) && (h == 0))
        L._lon = A.lon_center;
      else
        L._lon = atan(g / h) + A.lon_center;
    }
    // TM to LL inverse equations from here
    T._x = T._x - A.false_easting;
    T._y = T._y - A.false_northing;
    con = (A.ml0 + T._y / A.scale_factor) / A.r_major;
    phi = con;
    i = 0;
    while (true) {
      delta_phi = ((con + A.e1 * sin(2.0f * phi) - A.e2 * sin(4.0f * phi)
          + A.e3 * sin(6.0f * phi)) / A.e0) - phi;
      phi = phi + delta_phi;
      if (dabs(delta_phi) <= EPSLN)
        break;
      if (i >= max_iter) {
        //!ShowMessage("Latitude failed to convert...");
        //System.out.println("Latitude failed to convert...");
      }
      i++;
    }
    if (dabs(phi) < (PI / 2.0f)) {
      sin_phi = sin(phi);
      cos_phi = cos(phi);
      tan_phi = tan(phi);
      c = A.esp * (cos_phi * cos_phi);
      cs = c * c;
      t = tan_phi * tan_phi;
      ts = t * t;
      con = 1.0f - A.es * sin_phi * sin_phi;
      n = A.r_major / sqrt(con);
      r = n * (1.0f - A.es) / con;
      d = T._x / (n * A.scale_factor);
      ds = d * d;
      L._lat = phi - (n * tan_phi * ds / r) * (0.5f - ds / 24.0f *
            (5.0f + 3.0f * t + 10.0f * c - 4.0f * cs - 9.0f * A.esp - ds / 30.0f *
            (61.0f + 90.0f * t + 298.0f * c + 45.0f * ts - 252.0f * A.esp - 3.0f * cs)));
      L._lon = A.lon_center + (d *
            (1.0f - ds / 6.0f *
            (1.0f + 2.0f * t + c - ds / 20.0f *
            (5.0f - 2.0f * c + 28.0f * t - 3.0f * cs + 8.0f * A.esp + 24.0f * ts))) / cos_phi);
  //    *lat = 127.2866484932;
  //    *lon = 37.4402108468;
    } else {
      L._lat = PI/2.0f * sin(T._y);
      L._lon = A.lon_center;
    }
    return L;
  }

  /**
  * Function for converting longitude, latitude to TM X, Y
  */
public:
  static TM LLtoTM(LonAndLat L, Adjustment &A)
  {
    TM T;
    double delta_lon;
    double sin_phi, cos_phi;
    double al, als, b=0, c, t, tq;
    double con, n, ml;

    // LL to TM forward equations from here;
    delta_lon = L._lon - A.lon_center;
    sin_phi = sin(L._lat);
    cos_phi = cos(L._lat);

    if (A.ind != 0) {
      b =  cos_phi * sin(delta_lon);
      //!if ((dabs(dabs(b) - 1.0f)) < 0.0000000001f) 
        //!ShowMessage("The point is going to the unlimited value...\n"); abcde
        //!System.out.println("The point is going to the unlimited value...");
    } 
    else {
      T._x = 0.5f * A.r_major * A.scale_factor * log((1.0f + b) / 1.0f- b);
      con = acos(cos_phi * cos(delta_lon) / sqrt(1.0f - b * b));
      if (L._lat < 0) {
        con = -con;
        T._y = A.r_major * A.scale_factor * (con - A.lat_origin);
      }
    }

    al = cos_phi * delta_lon;
    als = al * al;
    c = A.esp * cos_phi * cos_phi;
    tq = tan(L._lat);
    t = tq * tq;
    con = 1.0f - A.es * sin_phi * sin_phi;
    n = A.r_major / sqrt(con);
    ml = A.r_major * mlfn(A.e0, A.e1, A.e2, A.e3, L._lat);

    T._x = A.scale_factor * n * al * (1.0f + als / 6.0f *
      (1.0f - t + c + als / 20.0f *
      (5.0f - 18.0f * t + t * t + 72.0f * c - 58.0f * A.esp)
      )
            ) + A.false_easting;
    T._y = A.scale_factor * (ml - A.ml0 + n * tq *
      (als *
      (0.5f + als / 24.0f *
      (5.0f - t + 9.0f * c + 4.0f * c * c + als / 30.0f *
      (61.0f - 58.0f * t + t * t + 600.0f * c - 330.0f * A.esp)
      )))) + A.false_northing;
    return T;
  }
  static double dms2d(int lonDeg, int lonMin, double lonSec)
  {
    double lon;
    lon = (double)lonDeg + (double)lonMin/60 + (double)lonSec / 3600;
    return lon;
  }
  static LonAndLat dms2d(DMS dms)
  {
    LonAndLat outputL;
    outputL._lon = dms2d(dms._lonDeg, dms._lonMin, dms._lonSec);
    outputL._lat = dms2d(dms._latDeg, dms._latMin, dms._latSec);
    return outputL;
  }
  static DMS d2dms(LonAndLat inputL)
  {
    DMS dms;
    double deltaLon, deltaLat;
    deltaLon = inputL._lon - (int)inputL._lon;
    deltaLat = inputL._lat - (int)inputL._lat;

    dms._lonMin = (int)(deltaLon * 60);
    dms._latMin = (int)(deltaLat * 60);
    dms._lonSec = (deltaLon * 60 - dms._lonMin) * 60;
    dms._latSec = (deltaLat * 60 - dms._latMin) * 60;

    if (dms._lonSec >= 60){
      dms._lonSec = dms._lonSec - 60;
      dms._lonMin = dms._lonMin + 1;
      if (dms._lonMin >= 60){
        dms._lonMin = dms._lonMin - 60;
        dms._lonDeg = (int)inputL._lon + 1;
      } else {
        dms._lonDeg = (int)inputL._lon;
      }
    } else{
      dms._lonDeg = (int)inputL._lon;
    }

    if (dms._latSec >= 60) {
      dms._latSec = dms._latSec - 60;
      dms._latMin = dms._latMin + 1;
      if (dms._latMin >= 60) {
        dms._latMin = dms._latMin - 60;
        dms._latDeg = (int)inputL._lat + 1;
      } else{
        dms._latDeg = (int)inputL._lat;
      }
    } else {
      dms._latDeg = (int)inputL._lat;
    }
    return dms;
  }
public:
  static double dabs(double x)
  {
    if(x>=0) return x;
    else return -x;
  }

  static double cube(double x)
  {
    return x*x*x;
  }

  static double e0fn(double x)
  {
    return (1.0f - 0.25f*x*(1.0f + x / 16.0f * (3+1.25f*x)));
  }
  static double e1fn(double x)
  {
    return(0.375f * x * (1. + 0.25f*x*(1.0f + 0.46875f*x)));
  }
  static double e2fn(double x)
  {
    return(0.05859375f*x*x*(1.0f+0.75f*x));
  }
  static double e3fn(double x)
  {
    return (x * x * x * (35.0f / 3072.0f));
  }
  static double e4fn(double x)
  {
    double con, com;
    con = 1.0f + x;
    com = 1.0f - x;
    return (sqrt(pow(con, con) * pow(com, com)));
  }
  static double mlfn(double e0, double e1, double e2, double e3, double phi)
  {
    return (e0 * phi - e1 * sin(2.0f * phi) + e2 * sin(4.0f * phi) - e3 * sin(6.0f * phi));
  }
  static double acos(double x)
  {
    return (atan(-x / sqrt(-x * x + 1.0f)) + 2.0f * atan(1));
  }
  static double asin(double x)
  {
    return (atan(x / sqrt(-x * x + 1.0f)));
  }
  static double asinz(double con)
  {
    if (dabs(con) > 1.0f)
      if (con > 1.0f)
        con = 1.0f;
      else
        con = -1.0f;
    return asin(con);
  }
};
