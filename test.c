#include <stdio.h>

void inImage();
int getInt(char*);
int getText(char buf[], int n);
void setInPos(int pos);
int getInPos();
char getChar();
char* putInt(int a);

int main()
{
    // inImage();

    // int a;
    // setInPos(0);
    // a = getInPos();
    // printf("INPOS: %d\n", a);

    // char b;
    // b = getChar();
    // printf("RETURNED CHARACTER: %c\n", b);
    // a = getInPos();
    // printf("INPOS: %d\n", a);

    // char buf[64];
    // a = getText(buf, 4);
    // printf("GET TEXT TRANSFERRED %d CHARACTERS\n", a);
    char* a = putInt(2048);
    printf("THE QUOTIENT IS: %s\n", a);

    return 0;
}
