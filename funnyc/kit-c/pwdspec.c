#include <kit_unit_case.h>


int main(int argc, char **argv)
{
    static int user_id = -1;
    char *userspec = "juntaoduan";
    struct passwd *pw;

    printf("hello pwdspec unit case......\n");

    pw = getpwnam(userspec);
    user_id = pw->pw_uid;
    printf("user_id is %d\n", user_id);
    return 0;
}
