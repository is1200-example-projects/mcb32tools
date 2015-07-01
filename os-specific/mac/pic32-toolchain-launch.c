#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <libgen.h>

int main(int argc, char **argv) {
	struct stat s;
	char message[4096];

	snprintf(message, 4096, "echo 'display dialog \"MCB32Tools must be installed directly in the applications directory, not in a subdirectory, and with the file name %s\" with title \"Error\" with icon stop buttons {\"OK\"}' | osascript", basename(MAC_APP_PATH));
	if (stat("$PREFIX_DATA_ROOT/Resources/Toolchain", &s) < 0 || !S_ISDIR(s.st_mode)) {
		system(message);
		return 1;
	}

	return system("osascript << EOF\n"
			"tell application \"Terminal\"\n"
			"	do script \". '$PREFIX_DATA_ROOT/Resources/Toolchain/environment'\"\n"
			"end tell\n"
			"EOF\n");
}
