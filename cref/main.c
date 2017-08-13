#include <stdlib.h>
#include <stdio.h>

#include <Windows.h>
#include <WinCred.h>
#define SECURITY_WIN32
#include <Security.h>

int main(int argc, char* argv[])
{
	const int size = sizeof(HRESULT);
	const auto v = IID_IUnknown;

	void* ptr = AcquireCredentialsHandle;

	return EXIT_SUCCESS;
}

