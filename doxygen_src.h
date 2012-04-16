/*
 *  doxygen_src.h
 *  ImIn
 *
 *  Created by Myungjin Choi on 11. 1. 4..
 *  Copyright 2011 KTH. All rights reserved.
 *
 */
/**
 
 @page development_guide 개발 가이드

 @page operation_guide 운영 가이드
  @par Crash Report
 
 - 앱이 비정상적으로 종료된 경우 크래시 리포트를 발송할 수 있으며, 해당 크래시 리포트는 MacDevCrashReports.com 사이트에 취합된다.
 - 취합된 크래시 리포트는 크래시 발생 지점에 대해서 우리가 인식할 수 있도록 심볼파일과 매칭시켜서 크래시 지점의 callstack를 보여준다.
 - 해당 callstack에 대한 symbolication는 CI서버를 통해서 주기적으로 처리된다.
 
  @par "그래픽 데이터 관리"
 
 - 그래픽 데이터는 images폴더 내에 모두 보관되며, iPhone4용 고해상도 이미지는 원래 이미지 이름과 확장자 사이에 @x2를 붙여서 관리한다.
  - 예) aButton.png의 고해상도 이미지는 aButton@2x.png
 
 @page db_schema 테이블 정의서
 
 */