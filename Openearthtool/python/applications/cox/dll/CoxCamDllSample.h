
// CoxCamDllSample.h : PROJECT_NAME ���� ���α׷��� ���� �� ��� �����Դϴ�.
//

#pragma once

#ifndef __AFXWIN_H__
	#error "PCH�� ���� �� ������ �����ϱ� ���� 'stdafx.h'�� �����մϴ�."
#endif

#include "resource.h"		// �� ��ȣ�Դϴ�.
#include <stdint.h>
#include "CoxCamDll.h"
#
/* User Message */
#define MY_MESSAGE1	(WM_USER + 1)	// OnErrorNotificationUserHandler
#define MY_MESSAGE2 (WM_USER + 2)	// OnDisplayImageHandler


#define MIN_SPAN	1		// 1.0
#define MAX_SPAN	100		// 100.0


// CCoxCamDllSampleApp:
// �� Ŭ������ ������ ���ؼ��� CoxCamDllSample.cpp�� �����Ͻʽÿ�.
//

class CCoxCamDllSampleApp : public CWinApp
{
public:
	CCoxCamDllSampleApp();

// �������Դϴ�.
public:
	virtual BOOL InitInstance();

// �����Դϴ�.

	DECLARE_MESSAGE_MAP()
};

extern CCoxCamDllSampleApp theApp;