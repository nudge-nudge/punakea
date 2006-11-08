/*
 *  appstarter.c
 *  punakea
 *
 *  Created by Johannes Hoffart on 08.11.06.
 *  Copyright 2006 nudge:nudge. All rights reserved.
 *
 */

#include "appstarter.h"

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
		execl("../MacOs/Punakea","-noBrowser YES");
		printf("Punakea started");
	}
	else // parent
	{
		wait(NULL);
		exit(0);
	}
}
