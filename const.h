/*
 *  const.h
 *  ImIn
 *
 *  Created by choipd on 10. 4. 29..
 *  Copyright 2010 edbear. All rights reserved.
 *
 */
/**
 * View tags' id
 */
#define SLIDER_GAUGE_VIEW 10000

#define MIN_TM_POSITION_X -185703
#define MAX_TM_POSITION_X 749767
#define MIN_TM_POSITION_Y -195041
#define MAX_TM_POSITION_Y 1064629

//#define DEFAULT_POSITION_X 193182
//#define DEFAULT_POSITION_Y 443401
#define DEFAULT_POSITION_X 202363
#define DEFAULT_POSITION_Y 443977

#define MAX_REQUEST_RETRY_COUNT 3

#define NAVIBAR_H 43

#define BADGE_WIDTH		90
#define BADGE_HEIGHT	90
#define BADGE_LABEL_H	14
#define BADGE_LABEL_GAP	0
#define BADGE_VIEW_H	(BADGE_HEIGHT+BADGE_LABEL_H+BADGE_LABEL_GAP)

#define FR_NONE		0
#define FR_ME		1
#define	FR_YOU		2
#define FR_TRUE		3

#define EMAIL_TYPE		0
#define OAUTH_TYPE		1
#define TWITTER_TYPE	2
#define FB_TYPE			3

#define SUBVIEW_WEB		0
#define TITLE_BOTTOM	1
#define TITLE           2
#define BOTTOM          3
#define HEARTCON        4
#define BIZWEBVIEW      5
#define WRITE_POST_RESULT 6

#define OLD_POSTFLOW    0
#define NEW_POSTFLOW    1


#define BADGE_IMAGE_TAPPED_NOTIFICATION @"badgeTapped"

enum IMIN_CELLTYPE {
	IMIN_CELLTYPE_UNKNOWN,
	IMIN_CELLTYPE_RECOMMEND,
	IMIN_CELLTYPE_NICKNAME,
	IMIN_CELLTYPE_INVITE_FACEBOOK,
	IMIN_CELLTYPE_INVITE_TWITTER,
	IMIN_CELLTYPE_INVITE_PHONEBOOK,
	IMIN_CELLTYPE_INVITE_ME2DAY,
    IMIN_CELLTYPE_WELCOME_RECOMMEND
};


typedef enum _BadgeAnimationType {
	BADGE_ANIMATION_TYPE1,
	BADGE_ANIMATION_TYPE2,
	BADGE_ANIMATION_TYPE3,
	BADGE_ANIMATION_TYPE4
} BadgeAnimationType;


typedef enum _AutoUpdateStatus {
	AUTO_UPDATE_STATUS_PREPARE,
	AUTO_UPDATE_STATUS_REQUESTED,
	AUTO_UPDATE_STATUS_RECEIVED,
	AUTO_UPDATE_STATUS_START_DOWNLOAD,
	AUTO_UPDATE_STATUS_COMPLETE_DOWNLOAD,
	AUTO_UPDATE_STATUS_USER_DENIED
} AutoUpdateStatus;


typedef enum _BadgeType {
	BADGE_TYPE_NORMAL,
	BADGE_TYPE_SET
} BadgeType;


#define SNS_IPHONE_SVCID @"-73913"
#define DEFAULT_PLAZA_RANGEX @"2000"
#define DEFAULT_PLAZA_RANGEY @"2000"
#define DEFAULT_MY_POI_LIST_RANGE @"2000"
#define DEFAULT_RANGEX @"100"
#define DEFAULT_RANGEY @"100"
#define DEFAULT_RANGE @"300"
#define DEFAULT_LEVEL @"1"
#define DEFAULT_MAXSCALE @"100"
#define SNS_DEVICE_MOBILE_APP	@"12"
#define SNS_DEVICE_MOBILE_APP_IPHONE	@"12"
#define SNS_DEVICE_MOBILE_APP_IPAD	@"22"
#define PLAZA_MAIN_THREAD_DEFAULT_ROWS_NUMBER @"25"
#define PLAZA_MAIN_THREAD_NEXT_ROWS_NUMBER @"25"

#ifdef APP_STORE_FINAL
 
	#define RANKING_URL @"http://im-in.paran.com"
	#define SNS_IMG_SERVER @"http://snsgw.paran.com"

	#define PROTOCOL_TMP_IMG_UPLOAD @"http://snsgw.paran.com/sns-gw/api/tmpImgUpload.kth"
	#define PROTOCOL_XY_TO_ADDR @"http://snsgw.paran.com/sns-gw/api/xyToAddr.kth"
	#define PROTOCOL_PLAZA_POI_LIST @"http://snsgw.paran.com/sns-gw/api/plazaPoiList.kth"
	#define PROTOCOL_PLAZA_POST_LIST @"http://snsgw.paran.com/sns-gw/api/plazaPostList.kth"
	#define PROTOCOL_POST_LIST @"http://snsgw.paran.com/sns-gw/api/postList.kth"
	#define PROTOCOL_PLAZA_POST_LIST_BY_POI @"http://snsgw.paran.com/sns-gw/api/plazaPostListByPoi.kth"
	#define PROTOCOL_LOCAL_LIST @"http://snsgw.paran.com/sns-gw/api/localList.kth"
	#define PROTOCOL_POST_WRITE @"http://snsgw.paran.com/sns-gw/api/postWrite.kth"
	#define PROTOCOL_POI_LIST @"http://snsgw.paran.com/sns-gw/api/poiList.kth"

	#define PROTOCOL_POST_DELETE @"http://snsgw.paran.com/sns-gw/api/postDelete.kth"

	#define PROTOCOL_BADGE_LIST @"http://snsgw.paran.com/sns-gw/api/badgeList.kth"
	#define PROTOCOL_FEED_COUNT @"http://snsgw.paran.com/sns-gw/api/feedCount.kth"
	#define PROTOCOL_FEED_LIST @"http://snsgw.paran.com/sns-gw/api/feedList.kth"

	#define PROTOCOL_NEIGHBOR_LIST @"http://snsgw.paran.com/sns-gw/api/neighborList.kth"
	#define PROTOCOL_NEIGHBOR_ON @"http://snsgw.paran.com/sns-gw/api/neighborRegist.kth"
	#define PROTOCOL_NEIGHBOR_OFF @"http://snsgw.paran.com/sns-gw/api/neighborDelete.kth"

    #define PROTOCOL_RECOMEND_NEIGHBOR_REJECT @"http://snsgw.paran.com/sns-gw/api/neighborRecomReject.kth"

	#define PROTOCOL_COLUMBUS_LIST @"http://snsgw.paran.com/sns-gw/api/columbusList.kth"
	#define PROTOCOL_COLUMBUS_LIST_BY_POI @"http://snsgw.paran.com/sns-gw/api/columbusListByPoi.kth"

	#define PROTOCOL_CAPTAIN_AREA_LIST_BY_POI @"http://snsgw.paran.com/sns-gw/api/captainAreaListByPoi.kth"
	#define PROTOCOL_CAPTAIN_MSG_WRITE @"http://snsgw.paran.com/sns-gw/api/captainMsgWrite.kth"
	#define PROTOCOL_CAPTAIN_MSG_LIST @"http://snsgw.paran.com/sns-gw/api/captainMsgList.kth"
    #define PROTOCOL_CAPTAIN_AREA_LIST @"http://snsgw.paran.com/sns-gw/api/captainAreaList.kth"

	#define PROTOCOL_POI_SETTING @"http://snsgw.paran.com/sns-gw/api/getOption.kth"
	#define PROTOCOL_POI_SETTING_SAVE @"http://snsgw.paran.com/sns-gw/api/setOption.kth"

	#define PROTOCOL_SET_BLOCK @"http://snsgw.paran.com/sns-gw/api/setBlock.kth"
	#define PROTOCOL_PROFILE_SET @"http://snsgw.paran.com/sns-gw/api/profileUpdate.kth"

	#define PROTOCOL_SEARCH_USER @"http://snsgw.paran.com/sns-gw/api/searchUser.kth"
	#define PROTOCOL_ADMINRECOMLIST @"http://snsgw.paran.com/sns-gw/api/adminRecomList.kth"

	#define PROTOCOL_CP_NEIGHBOR_LIST @"http://snsgw.paran.com/sns-gw/api/cpNeighborList.kth"
	#define PROTOCOL_CP_MSG @"http://snsgw.paran.com/sns-gw/api/cpMsg.kth"
    #define PROTOCOL_SEND_MSG @"http://snsgw.paran.com/sns-gw/api/sendMsg.kth"

	#define PROTOCOL_POLICE @"http://snsgw.paran.com/sns-gw/api/police.kth"
	#define PROTOCOL_POIPOLICE @"http://snsgw.paran.com/sns-gw/api/poiPolice.kth"

	#define PROTOCOL_GET_NOTI @"http://snsgw.paran.com/sns-gw/api/getNoti.kth"
	#define PROTOCOL_SET_NOTI @"http://snsgw.paran.com/sns-gw/api/setNoti.kth"

	// For Paran Login
	#define PROTOCOL_USERAUTH @"https://user.paran.com/service/auth/login"
	#define PROTOCOL_SETAUTHTOKEN @"http://snsgw.paran.com/sns-gw/api/setAuthToken.kth"
	//@"http://snsgw.paran.com/sns/api/setAuthToken.kth"
	#define PROTOCOL_CREATESNS @"http://snsgw.paran.com/sns-gw/api/createSns.kth"
	#define SNS_CONSUMER_KEY @"app.imin.paran.com"
	#define SNS_SIGNATURE @"2c3f11a8cfbaec0d434cd93cbc69847067ad36b8"

	// For Token Check
	#define PROTOCOL_TOKEN_CHECK @"https://user.paran.com/service/auth/valid"

	// callbackUrl
	#define CALLBACK_URL @"http://im-in.paran.com/paranLoginCallBack.kth"

	//OAuth Login
	#define OAUTH_LOGIN_URL @"https://main.paran.com/oauth/login.do"

	//회원가입
	#define OAUTH_REGISTER_URL @"https://user.paran.com/paran/register.do"

	//글내보내기 설정
	#define OAUTH_URL @"https://main.paran.com/oauth/auth.do"

	//공통 OAuth인증 GW등록시 신청한 어플리케이션이름
	#define IMIN_APP_NAME @"imin"

	//개발환경세팅
	#define DEV_SETTING_URL @"http://user.paran.com/devmode.jsp?mode="

	//아이디찾기
	#define FIND_ID @"https://user.paran.com/paran/findid.do"

	//패스워드찾기
	#define FIND_PW @"https://user.paran.com/paran/findpw.do"

	//고객센터 URL
	#define HELP_URL @"http://help.paran.com/faq/mobile/index.jsp?nodeId=NODE0000001026&TBID=TBOX20110419000001"

	// 공지 관련
	#define NOTICE_BASEURL	@"http:/api.blog.paran.com/iminblog"
    
    // 선물하기
    #define HEARTCON_GIFT @"http://im-in.paran.com/mobile/gift/heartconIndex.kth"
    #define EVENT_LIST_URL @"http://im-in.paran.com/mobile/eventList.kth?isDataHtml=10"
    #define EVENT_BOX_URL @"http://im-in.paran.com/mobile/couponList.kth?isDataHtml=10"


//    #define PROTOCOL_IS_DENY_WORD @"http://snsgw.paran.com/sns-gw/api/isDenyWord.kth"
//    // BLOG API
//    #define PROTOCOL_BLOG_API @"http://snsgw.paran.com/sns-gw/api/blogAPI.kth"
//    // For APNS
//    #define PROTOCOL_REGISTER_DEVICE @"http://snsgw.paran.com/sns-gw/api/registerDevice.kth"
//    #define PROTOCOL_PROFILEINFO @"http://snsgw.paran.com/sns-gw/api/profileInfo.kth"
//    #define PROTOCOL_SET_DELIVERY @"http://snsgw.paran.com/sns-gw/api/setDelivery.kth"
//    #define PROTOCOL_SET_DELIVERY_OPTION @"http://snsgw.paran.com/sns-gw/api/setDeliveryOption.kth"
//    #define PROTOCOL_GET_DELIVERY @"http://snsgw.paran.com/sns-gw/api/getDelivery.kth"
//    #define PROTOCOL_DEL_DELIVERY @"http://snsgw.paran.com/sns-gw/api/delDelivery.kth"
//    #define PROTOCOL_MYHOME_INFO @"http://snsgw.paran.com/sns-gw/api/homeInfo.kth"
//    #define PROTOCOL_RECOMEND_NEIGHBOR_LIST @"http://snsgw.paran.com/sns-gw/api/neighborRecomList.kth"
    #define PROTOCOL_CMT_LIST @"http://snsgw.paran.com/sns-gw/api/cmtList.kth"
//    #define PROTOCOL_CMT_WRITE @"http://snsgw.paran.com/sns-gw/api/cmtWrite.kth"
//    #define PROTOCOL_CMT_DELETE @"http://snsgw.paran.com/sns-gw/api/cmtDelete.kth"


#else

	#define RANKING_URL @"http://imindev.paran.com/sns"
	#define SNS_IMG_SERVER @"http://imindev.paran.com"

	#define PROTOCOL_TMP_IMG_UPLOAD @"http://imindev.paran.com/sns-gw/api/tmpImgUpload.kth"
	#define PROTOCOL_XY_TO_ADDR @"http://imindev.paran.com/sns-gw/api/xyToAddr.kth"
	#define PROTOCOL_PLAZA_POI_LIST @"http://imindev.paran.com/sns-gw/api/plazaPoiList.kth"
	#define PROTOCOL_PLAZA_POST_LIST @"http://imindev.paran.com/sns-gw/api/plazaPostList.kth"
	#define PROTOCOL_POST_LIST @"http://imindev.paran.com/sns-gw/api/postList.kth"
	#define PROTOCOL_PLAZA_POST_LIST_BY_POI @"http://imindev.paran.com/sns-gw/api/plazaPostListByPoi.kth"
	#define PROTOCOL_LOCAL_LIST @"http://imindev.paran.com/sns-gw/api/localList.kth"
	#define PROTOCOL_POST_WRITE @"http://imindev.paran.com/sns-gw/api/postWrite.kth"
	#define PROTOCOL_POI_LIST @"http://imindev.paran.com/sns-gw/api/poiList.kth"
	#define PROTOCOL_POST_DELETE @"http://imindev.paran.com/sns-gw/api/postDelete.kth"

	#define PROTOCOL_BADGE_LIST @"http://imindev.paran.com/sns-gw/api/badgeList.kth"
	#define PROTOCOL_FEED_COUNT @"http://imindev.paran.com/sns-gw/api/feedCount.kth"
	#define PROTOCOL_FEED_LIST @"http://imindev.paran.com/sns-gw/api/feedList.kth"

	#define PROTOCOL_NEIGHBOR_LIST @"http://imindev.paran.com/sns-gw/api/neighborList.kth"
	#define PROTOCOL_NEIGHBOR_ON @"http://imindev.paran.com/sns-gw/api/neighborRegist.kth"
	#define PROTOCOL_NEIGHBOR_OFF @"http://imindev.paran.com/sns-gw/api/neighborDelete.kth"

    #define PROTOCOL_RECOMEND_NEIGHBOR_REJECT @"http://imindev.paran.com/sns-gw/api/neighborRecomReject.kth"

	#define PROTOCOL_COLUMBUS_LIST @"http://imindev.paran.com/sns-gw/api/columbusList.kth"
	#define PROTOCOL_COLUMBUS_LIST_BY_POI @"http://imindev.paran.com/sns-gw/api/columbusListByPoi.kth"

	#define PROTOCOL_CAPTAIN_AREA_LIST_BY_POI @"http://imindev.paran.com/sns-gw/api/captainAreaListByPoi.kth"
	#define PROTOCOL_CAPTAIN_MSG_WRITE @"http://imindev.paran.com/sns-gw/api/captainMsgWrite.kth"
	#define PROTOCOL_CAPTAIN_MSG_LIST @"http://imindev.paran.com/sns-gw/api/captainMsgList.kth"
    #define PROTOCOL_CAPTAIN_AREA_LIST @"http://imindev.paran.com/sns-gw/api/captainAreaList.kth"

	#define PROTOCOL_POI_SETTING @"http://imindev.paran.com/sns-gw/api/getOption.kth"
	#define PROTOCOL_POI_SETTING_SAVE @"http://imindev.paran.com/sns-gw/api/setOption.kth"

	#define PROTOCOL_SET_BLOCK @"http://imindev.paran.com/sns-gw/api/setBlock.kth"
	#define PROTOCOL_PROFILE_SET @"http://imindev.paran.com/sns-gw/api/profileUpdate.kth"

	#define PROTOCOL_SEARCH_USER @"http://imindev.paran.com/sns-gw/api/searchUser.kth"

	#define PROTOCOL_CP_NEIGHBOR_LIST @"http://imindev.paran.com/sns-gw/api/cpNeighborList.kth"
	#define PROTOCOL_ADMINRECOMLIST @"http://imindev.paran.com/sns-gw/api/adminRecomList.kth"
	#define PROTOCOL_CP_MSG @"http://imindev.paran.com/sns-gw/api/cpMsg.kth"
    #define PROTOCOL_SEND_MSG @"http://imindev.paran.com/sns-gw/api/sendMsg.kth"

	#define PROTOCOL_POLICE @"http://imindev.paran.com/sns-gw/api/police.kth"
	#define PROTOCOL_POIPOLICE @"http://imindev.paran.com/sns-gw/api/poiPolice.kth"

	#define PROTOCOL_GET_NOTI @"http://imindev.paran.com/sns-gw/api/getNoti.kth"
	#define PROTOCOL_SET_NOTI @"http://imindev.paran.com/sns-gw/api/setNoti.kth"

	// For Paran Login
	#define PROTOCOL_USERAUTH @"https://user.paran.com/service/auth/login"
	//setAuthTokenEx.kth API 테스트를 위해 잠시 적용했습니다.
	//#define PROTOCOL_SETAUTHTOKEN @"http://imindev.paran.com/sns-gw/api/setAuthToken.kth"
	#define PROTOCOL_SETAUTHTOKEN @"http://imindev.paran.com/sns-gw/api/setAuthTokenEx.kth"
	#define PROTOCOL_CREATESNS @"http://imindev.paran.com/sns-gw/api/createSns.kth"
	#define SNS_CONSUMER_KEY @"app.imin.paran.com"
	#define SNS_SIGNATURE @"2c3f11a8cfbaec0d434cd93cbc69847067ad36b8"

	// For Token Check
	#define PROTOCOL_TOKEN_CHECK @"https://user.paran.com/service/auth/valid"

	// callbackUrl
	#define CALLBACK_URL @"http://imindev.paran.com/sns/paranLoginCallBack.kth"

	//OAuth Login
	#define OAUTH_LOGIN_URL @"https://main.paran.com/oauth/login.do"

	//회원가입
	#define OAUTH_REGISTER_URL @"https://user.paran.com/paran/register.do"

	//글내보내기 설정
	#define OAUTH_URL @"https://main.paran.com/oauth/auth.do"

	//공통 OAuth인증 GW등록시 신청한 어플리케이션이름
	#define IMIN_APP_NAME @"imindev"

	//개발환경세팅
	#define DEV_SETTING_URL @"http://user.paran.com/devmode.jsp?mode="

	//아이디찾기
	#define FIND_ID @"https://user.paran.com/paran/findid.do"

	//패스워드찾기
	#define FIND_PW @"https://user.paran.com/paran/findpw.do"

	//고객센터 URL
	#define HELP_URL @"http://help.paran.com/faq/mobile/index.jsp?nodeId=NODE0000001026&TBID=TBOX20110419000001"

	// 공지 관련
	#define NOTICE_BASEURL	@"http:/api.blog.paran.com/iminblog"

    // 선물하기
    #define HEARTCON_GIFT @"http://imindev.paran.com/sns/mobile/gift/heartconIndex.kth"
    #define EVENT_LIST_URL @"http://imindev.paran.com/sns/mobile/eventList.kth?isDataHtml=10"
    #define EVENT_BOX_URL @"http://imindev.paran.com/sns/mobile/couponList.kth?isDataHtml=10"


//    #define PROTOCOL_IS_DENY_WORD @"http://imindev.paran.com/sns-gw/api/isDenyWord.kth"
//    // For APNS
//    #define PROTOCOL_REGISTER_DEVICE @"http://imindev.paran.com/sns-gw/api/registerDevice.kth"
//
//    // BLOG API
//    #define PROTOCOL_BLOG_API @"http://imindev.paran.com/sns-gw/api/blogAPI.kth"
//    #define PROTOCOL_PROFILEINFO @"http://imindev.paran.com/sns-gw/api/profileInfo.kth"
//    #define PROTOCOL_SET_DELIVERY @"http://imindev.paran.com/sns-gw/api/setDelivery.kth"
//    #define PROTOCOL_SET_DELIVERY_OPTION @"http://imindev.paran.com/sns-gw/api/setDeliveryOption.kth"
//    #define PROTOCOL_GET_DELIVERY @"http://imindev.paran.com/sns-gw/api/getDelivery.kth"
//    #define PROTOCOL_DEL_DELIVERY @"http://imindev.paran.com/sns-gw/api/delDelivery.kth"
//    #define PROTOCOL_MYHOME_INFO @"http://imindev.paran.com/sns-gw/api/homeInfo.kth"
//    #define PROTOCOL_RECOMEND_NEIGHBOR_LIST @"http://imindev.paran.com/sns-gw/api/neighborRecomList.kth"
    #define PROTOCOL_CMT_LIST @"http://imindev.paran.com/sns-gw/api/cmtList.kth"
//    #define PROTOCOL_CMT_WRITE @"http://imindev.paran.com/sns-gw/api/cmtWrite.kth"
//    #define PROTOCOL_CMT_DELETE @"http://imindev.paran.com/sns-gw/api/cmtDelete.kth"

#endif

// Network Error Code
#define NETWORK_ERROR_NOCONNECT 1001
#define NETWORK_ERROR_TIMEOUT	1002
#define NETWORK_ERROR_SERVER	1003
#define NETWORK_ERROR_NORMAL	1000

// Netwrok Error MSG
#define NETWORK_MSG_TIMOUT @"네트웍 접속이 원활하지 않습니다.\n잠시후 다시 시도해주세요."
#define NETWORK_MSG_NOCONNECTION @"데이터에 접근하려면,\n에어플레인 모드를 끄거나\nWi-Fi를 사용하십시오."
#define NETWORK_MSG_SERVERERROR @"서버 점검중입니다."

// GPS 오류 관련 MSG
#define GPS_MSG_OUTOFBOUND @"GPS 측정 현재 위치 좌표가\n서비스 지원 범위를 벗어났습니다."
#define GPS_MSG_NOGPS	@"GPS 수신정보가 없습니다.\n아이폰 위치정보 설정을 확인하세요."

