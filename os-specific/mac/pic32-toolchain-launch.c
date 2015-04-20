#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <libgen.h>

int main(int argc, char **argv) {
	struct stat s;
	char message[4096];

	snprintf(message, 4096, "echo 'display dialog \"You must install this toolchain directly under /Applications with the filename %s\"' | osascript", basename(PREFIX_APP_PATH));
	if (stat("$PREFIX_DATA_ROOT/Resources/Toolchain", &s) < 0 || !S_ISDIR(s.st_mode)) {
		system(message);
		return 1;
	}

	return system("open -a Terminal.app $PREFIX_DATA_ROOT/MacOS/launchterm");
}
