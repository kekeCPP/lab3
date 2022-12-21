#include <stdio.h>

void inImage();
int getInt();
int getText(char* buf, int n);
int getText2(char* buf, int n);
void setInPos(int pos);
int getInPos();
char getChar();
void putInt(int a);
void putText(char* string);
void setOutPos(int pos);
int getOutPos();
void putChar(char a);
void outImage();

int main()
{
    char* test = "THIS IS A TEST PROMPT FOR DEBUGGING";
    char* headMsg = "Start av testprogram. Skriv in 5 tal!";
    char* endMsg = "Slut på testprogrammet";
    char buf[64];
    int sum = 0;
    int count = 0;
    int temp = 0;
    int rdi;
    int rdx;
    int rsi;
    int rax;


    putText(headMsg);
    outImage();
    inImage();
    count = 5;

    while (count > 0)
    {
        rax = getInt();
        temp = rax;
        if (rax < 0)
        {
            rax = getOutPos();
            rax--;
            rdi = rax;
            setOutPos(rdi);
        }

        rdx = temp;
        sum = sum + rdx;
        rdi = rdx;
        printf("RDI = %d\n", rdi);
        printf("OUTPOS: %d\n", getOutPos());
        putInt(rdi);
        rdi = 43;
        putChar('+');
        count--;
    }

    rax = getOutPos();
    rax--;
    rdi = rax;
    setOutPos(rdi);
    rdi = 61;
    putChar('=');
    rdi = sum;
    putInt(rdi);
    outImage();
    rsi = 12;
    getText(buf, rsi);
    putText(buf);
    rdi = 125;
    putInt(rdi);
    outImage();
    putText(endMsg);
    outImage();

    return 0;
}
