#include <stdio.h>

void inImage();
int getInt(char*);
int getText(char buf[], int n);
void setInPos(int pos);
int getInPos();
char getChar();
char* putInt(int a);
int putText(char* string);
void setOutPos(int pos);
int putChar(char a);

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
    // int a = putText("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
    // printf("THE STRING IS: %d\n", a);
    // int b = putChar('g');
    // printf("THE POSITION IS: %d\n", b);

    return 0;
}
