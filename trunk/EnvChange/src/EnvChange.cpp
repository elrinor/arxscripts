#include <Windows.h>
#include <tchar.h>

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow) {
  UNREFERENCED_PARAMETER(hPrevInstance);
  UNREFERENCED_PARAMETER(lpCmdLine);

  DWORD result;

  if(SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0, (LPARAM) _T("Environment"), SMTO_NORMAL, 4000, &result) == 0)
    return 1;

  if(result != 0)
    return 1;

  return 0;
}