#define _CRT_SECURE_NO_WARNINGS
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <windowsx.h>

#pragma comment(lib, "user32.lib")
#pragma comment(lib, "imm32.lib")

#define API extern __declspec(dllexport)

#ifndef GWL_WNDPROC
#define GWL_WNDPROC (-4)
#endif

typedef int (__cdecl *RGSSEVAL)(void *);
typedef UINT (WINAPI *GETREADINGSTRING)(HIMC, UINT, LPWSTR, PINT, BOOL*, PUINT);
typedef BOOL (WINAPI *SHOWREADINGWINDOW)(HIMC, BOOL);

static HWND window_hwnd = NULL;
static WNDPROC oldWndProc = NULL;
static RGSSEVAL RGSSEval = NULL;
static CHAR rubyCode[4096] = "";

static HIMC himc = NULL;
static HKL hkl = NULL;
static WCHAR composition[4096] = L"";
static GETREADINGSTRING GetReadingString = NULL;
static SHOWREADINGWINDOW ShowReadingWindow = NULL;

CHAR *inspect(WCHAR str[], LONG len) {
	if (str == NULL) return NULL;

	int result_size = 1 + len * 8 + 1 + 1;
	if (len > 0) {
		result_size -= 2;
	}

	CHAR *result = (CHAR *)malloc(result_size * sizeof(CHAR));
	if (result == NULL) return NULL;

	strcpy(result, "[");
	for (int i = 0; i < len; i++) {
		char temp[16];
		sprintf(temp, "0x%04lX", (DWORD)str[i]);
		strcat(result, temp);

		if (i < len - 1) {
			strcat(result, ", ");
		}
	}
	strcat(result, "]");

	return result;
}

void setupApi() {
	CHAR file[MAX_PATH + 1];
	if (!ImmGetIMEFileNameA(hkl, file, MAX_PATH)) {
		return;
	}

	HMODULE hime = LoadLibrary(file);
	if (!hime) {
		return;
	}

	GetReadingString = (GETREADINGSTRING)GetProcAddress(hime, "GetReadingString");
	ShowReadingWindow = (SHOWREADINGWINDOW)GetProcAddress(hime, "ShowReadingWindow");

	if (ShowReadingWindow) {
		HIMC himc = ImmGetContext(window_hwnd);
		if (himc) {
			ShowReadingWindow(himc, FALSE);
			ImmReleaseContext(window_hwnd, himc);
		}
	}
}

LRESULT WINAPI newWndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {

	if (msg == WM_MOUSEWHEEL) {
		int delta = (SHORT)HIWORD(wp);
		sprintf(rubyCode, "CALLBACKS.on_mousewheel %d", delta);
		RGSSEval(rubyCode);
	}

	if (msg == WM_INPUTLANGCHANGE) {
		hkl = GetKeyboardLayout(0);
		setupApi();
		sprintf(rubyCode, "CALLBACKS.on_langchange 0x%p", hkl);
		RGSSEval(rubyCode);
	}

	if (msg == WM_IME_STARTCOMPOSITION) {
		sprintf(rubyCode, "CALLBACKS.on_composition_start");
		RGSSEval(rubyCode);
	}

	if (msg == WM_IME_COMPOSITION) {
		himc = ImmGetContext(hwnd);
		LONG cursor = ImmGetCompositionStringW(himc, GCS_CURSORPOS, 0, 0);

		if (lp & GCS_COMPSTR) {
			LONG length = ImmGetCompositionStringW(himc, GCS_COMPSTR, 0, 0);
			length = ImmGetCompositionStringW(himc, GCS_COMPSTR, composition, length);
			if (length < 0) length = 0;
			length /= sizeof(WCHAR);
			composition[length] = 0;

			CHAR *data = inspect(composition, length);
			sprintf(rubyCode, "CALLBACKS.on_composition %ld, %ld, %s", cursor, length, data);
			if (data) free(data);
			RGSSEval(rubyCode);
		}

		if (lp & GCS_RESULTSTR) {
			LONG length = ImmGetCompositionStringW(himc, GCS_RESULTSTR, 0, 0);
			length = ImmGetCompositionStringW(himc, GCS_RESULTSTR, composition, length);
			if (length < 0) length = 0;
			length /= sizeof(WCHAR);
			composition[length] = 0;

			CHAR *data = inspect(composition, length);
			sprintf(rubyCode, "CALLBACKS.on_composition_result %ld, %ld, %s", cursor, length, data);
			if (data) free(data);
			RGSSEval(rubyCode);
		}

		ImmReleaseContext(hwnd, himc);
	}

	return CallWindowProc(oldWndProc, hwnd, msg, wp, lp);
}

API WNDPROC WINAPI enable(HWND hwnd) {
	if (oldWndProc) return NULL;

	window_hwnd = hwnd;
	oldWndProc = (WNDPROC)GetWindowLong(hwnd, GWL_WNDPROC);
	RGSSEval = (RGSSEVAL)GetProcAddress(GetModuleHandle("RGSS301.dll"), "RGSSGetInt");

	himc = ImmGetContext(hwnd);
	ImmAssociateContext(hwnd, himc);
	COMPOSITIONFORM cof = {
		.dwStyle = CFS_RECT,
		.ptCurrentPos = { .x = 20, .y = 32 },
		.rcArea = { .left = 20, .top = 20, .right = 140, .bottom = 52 }
	};
	ImmSetCompositionWindow(himc, &cof);
	ImmReleaseContext(hwnd, himc);

	hkl = GetKeyboardLayout(0);
	setupApi();

	SetWindowLong(hwnd, GWL_WNDPROC, (LONG)newWndProc);
	return oldWndProc;
}

API LONG WINAPI candidateList(HWND hwnd, PCANDIDATELIST p) {
	HIMC himc = ImmGetContext(hwnd);
	if (!himc) return -1;
	DWORD bufSize = ImmGetCandidateList(himc, 0, NULL, 0);
	if (!p) return bufSize;
	ImmGetCandidateList(himc, 0, p, bufSize);
	ImmReleaseContext(hwnd, himc);
	return 0;
}
