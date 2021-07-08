#include <kit_sys.h>


int main(int argc, char **argv)
{
    printf("hello kit unit case......\n");
    struct passwd *pw;
    char *userspec = "tcpdump";

    pw = getpwnam(userspec);
    printf("pw_uid is %d\n", pw->pw_uid);
    printf("pw_gid is %d\n", pw->pw_gid);
    printf("pw_name is %s\n",pw->pw_name);
    printf("pw_passwd is %s\n", pw->pw_passwd);
    printf("pw_gecos is %s\n", pw->pw_gecos);
    printf("pw_dir is %s\n", pw->pw_dir);
    printf("pw_shell is %s\n", pw->pw_shell);
    return 0;
}
