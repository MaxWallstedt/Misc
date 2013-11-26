#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

/* The amount os µs each number represents */
#define DELAY 1000

void *sleep_print(void *i)
{
	int num = (int)i;
	usleep(num * DELAY);
	fprintf(stdout, "%d\n", num);
	pthread_exit(NULL);
}

int main(int argc, char *argv[])
{
	int i;
	int rc;
	pthread_t *threads = malloc(sizeof(pthread_t) * (argc - 1));
	pthread_attr_t attr;

	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

	for (i = 1; i < argc; ++i) {
		rc = pthread_create(&threads[i - 1],
		                    &attr,
		                    sleep_print,
		                    (void *)atoi(argv[i]));

		if (rc) {
			fprintf(stderr, "ERROR: pthread_create returned error code %d\n", rc);
			exit(-1);
		}
	}

	pthread_attr_destroy(&attr);

	for (i = 1; i < argc; ++i) {
		rc = pthread_join(threads[i - 1], NULL);

		if (rc) {
			fprintf(stderr, "ERROR: pthread_join returned error code %d\n", rc);
			exit(-1);
		}
	}

	free(threads);
	pthread_exit(NULL);
}
