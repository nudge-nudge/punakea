/*
 *  appstarter.c
 *  punakea
 *
 *  Created by Johannes Hoffart on 08.11.06.
 *  Copyright 2006 nudge:nudge. All rights reserved.
 *
 * NOT NEEDED ANYMORE! keeping for reference
 */

#include <sys/types.h>
#include <sys/param.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

int main()
{	
	pid_t pid;
	
	pid = fork();
	if (pid < 0) // error
	{
		fprintf(stderr, "could not fork");
		exit(-1);
	}
	else if (pid == 0) // child process
	{
		char current_path[MAXPATHLEN];
		char *relative_executable_path = "MacOs/Punakea";
		char *not_needed_string = "Resources";
		
		//get current path
		getcwd(current_path,MAXPATHLEN);
		
		// get base path length
		int base_path_length = strlen(current_path)-strlen(not_needed_string);

		// get final path
		char final_path[base_path_length + strlen(relative_executable_path)];
		
		int i;
		
		for (i=0;i<base_path_length;i++)
			final_path[i] = current_path[i];
		
		int j;
		
		for (j=0;j<strlen(relative_executable_path);j++)
		{
			i++;
			final_path[i] = relative_executable_path[j];
		}
		
		//printf("path: %s\n",final_path);
				
		//execl(final_path, NULL);
		chdir("/Applications/Punakea.app/Contents/MacOs");
		system("./Punakea -noBrowser YES");
		//execl("Punakea",NULL);
//		execl("/usr/bin/open","-b","eu.nudgenudge.punakea",NULL);

		//execl("open","/Applications/TextMate.app",NULL);
		//execl("/bin/ls","/Users/darklight/",NULL);
		
		//execlp("/bin/pwd",NULL);
		printf("Punakea started\n");
	}
	else // parent
	{
		wait(NULL);
		printf("done\n");
		exit(0);
	}
}
