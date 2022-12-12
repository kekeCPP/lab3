#include <stdio.h>

char* inImage();
int getInt(char*);

int main()
{
    char* str = inImage();
    int res;
    res = getInt(str);
    printf("Talet är: %d\n", res);
    return 0;
}
