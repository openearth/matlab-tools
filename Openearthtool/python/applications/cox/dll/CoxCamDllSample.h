
// CoxCamDllSample.h : PROJECT_NAME 응용 프로그램에 대한 주 헤더 파일입니다.
//

#pragma once

#ifndef __AFXWIN_H__
	#error "PCH에 대해 이 파일을 포함하기 전에 'stdafx.h'를 포함합니다."
#endif

#include "resource.h"		// 주 기호입니다.
#include <stdint.h>
#include "CoxCamDll.h"
#
/* User Message */
#define MY_MESSAGE1	(WM_USER + 1)	// OnErrorNotificationUserHandler
#define MY_MESSAGE2 (WM_USER + 2)	// OnDisplayImageHandler


#define MIN_SPAN	1		// 1.0
#define MAX_SPAN	100		// 100.0


// CCoxCamDllSampleApp:
// 이 클래스의 구현에 대해서는 CoxCamDllSample.cpp을 참조하십시오.
//

class CCoxCamDllSampleApp : public CWinApp
{
public:
	CCoxCamDllSampleApp();

// 재정의입니다.
public:
	virtual BOOL InitInstance();

// 구현입니다.

	DECLARE_MESSAGE_MAP()
};

extern CCoxCamDllSampleApp theApp;