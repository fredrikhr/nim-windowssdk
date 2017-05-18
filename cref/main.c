#include <stdlib.h>
#include <stdio.h>

#include <Windows.h>
#include <WinCred.h>
#define SECURITY_WIN32
#include <Security.h>

int main(int argc, char* argv[])
{
	const int size = sizeof(BOOL);
	const auto v = SEC_E_SECPKG_NOT_FOUND;

	void* ptr = AcquireCredentialsHandle;

	return EXIT_SUCCESS;
}

