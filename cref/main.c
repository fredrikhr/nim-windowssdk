#include <stdlib.h>
#include <stdio.h>

#include <Windows.h>
#define SECURITY_WIN32
#include <Security.h>

int main(int argc, char* argv[])
{
	const int size = sizeof(BOOL);
	const auto v = SEC_E_INSUFFICIENT_MEMORY;

	void* ptr = AcquireCredentialsHandle;

	return EXIT_SUCCESS;
}

