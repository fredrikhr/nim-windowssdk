#include <stdlib.h>
#include <stdio.h>

#include <Windows.h>
#include <WinCred.h>
#define SECURITY_WIN32
#include <Security.h>

int main(int argc, char* argv[])
{
	const int size = sizeof(CLSCTX);
	const auto v = _NDIS_ERROR_TYPEDEF_(0x80340002L);

	void* ptr = CoInitialize;

	return EXIT_SUCCESS;
}

