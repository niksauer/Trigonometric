//
//  main.c
//  Trigonometric
//
//  Created by Niklas Sauer on 24.04.17.
//  Copyright © 2017 DHBW Stuttgart. All rights reserved.
//

#include <stdio.h>
#include <math.h>

// global definitions
#define MAX_DIFF    0.00001
#define PI          3.141592653589793238462643383279502884197169399375105820974
#define PI_2        1.570796326794896619231321691639751442098584699687552910487

// function prototypes
void sineUnitTest();
void userInput();

int factorial(int x);
double power(double x, double e);
int modulo(int x, int y);

double taylorSeries(double x, int approximations);
double optimizedTaylorSeries(double x, int approximations);

double sine0(double x);
double sine(double x);
double cosine(double x);
double tangent(double x);

// function implementations
int main(int argc, const char * argv[]) {
//    sineUnitTest();
    userInput();
    return 0;
}


void sineUnitTest() {
    int xMin = -5.4287;
    int xMax = 23.1381;
    double partition = (xMax - xMin) / 20;
    
    for (int i= 0; i < 20; i++) {
        double xValue = xMin + i*partition;
        double custom = sine(xValue);
        double real = sin(xValue);
        double diff = fabs(real-custom);
        char * acceptable = (diff < MAX_DIFF) ? "yes" : "no";
        
        printf("custom sin: % 02.8lf \t accept: %s, with diff: % 02.8lf \n", custom, acceptable, diff);
    }
}

void userInput() {
    int numberOfValuesInInterval;
    double xMin;
    double xMax;
    
    printf("Please input the desired number (n) of equidistent values in interval [x(min), x(max)]:\n");
    scanf("%d", &numberOfValuesInInterval);
    
    printf("Please specify the interval start: x(min)\n");
    scanf("%lf", &xMin);
    
    printf("Please specify the interval end: x(max)\n");
    scanf("%lf", &xMax);
    
    double partition = ((xMax - xMin) / numberOfValuesInInterval);
    
    for (int i = 0; i < numberOfValuesInInterval; i++) {
        double xValue = xMin + i*partition;
        double sinResult = sine(xValue);
        double cosResult = cosine(xValue);
        double tanResult = tangent(xValue);
        
        printf("x%d = % 08.8lf -> \t sin: % 02.8lf (diff: % 02.8lf) \t cos: % 02.8lf (diff: % 02.8lf) \t tan: % 02.8lf (diff: % 02.8lf) \n", i, xValue, sinResult, fabs(sinResult-sin(xValue)), cosResult, fabs(cosResult-cos(xValue)), tanResult, fabs(tanResult-tan(xValue)));
    }
}


int factorial(int x) {
    if (x <= 1) {
        return 1;
    } else {
        return x * factorial(x-1);
    }
}

double power(double x, double e) {
    if (e == 0) {
        return 1;
    } else {
        return x * power(x, e-1);
    }
}

int modulo(int x, int y) {
    int result = x;
    
    while (result >= y) {
        result = result-y;
    }
    
    return result;
}


double taylorSeries(double x, int approximations) {
    double result = 0;
    
    for (int i = 0; i < approximations; i++) {
        double step = 0;
        double nominator = power(x, 2*i+1);
        double denominator = factorial(2*i+1);
        
        step = power(-1, i) * (nominator/denominator);
        result = result + step;
    }
    
    return result;
}

double optimizedTaylorSeries(double x, int approximations) {
    double numerator = power(x, 2*0+1);
    double denominator = factorial(2*0+1);
    double firstTaylorTerm = numerator / denominator;
    
    if (approximations == 1) {
        return firstTaylorTerm;
    } else {
        double result = firstTaylorTerm;
        double lastTerm = firstTaylorTerm;
        
        for (int i = 1; i < approximations; i++) {
            double nextTerm = lastTerm * (power(x, 2) / ((2*i) * (2*i+1)));
            result = result + (power(-1, i) * nextTerm);
            lastTerm = nextTerm;
        }
        
        return result;
    }
}


double sine0(double x) {
    int approximations = 6;
    
    return optimizedTaylorSeries(x, approximations);
}

double sine(double x) {
    if (x >= -M_PI_2 && x <= M_PI_2) {
        return sine0(x);
    } else {
        if (x < 0) {
            x = -x + M_PI;
        }
        
        int sign = 1;
        
        while (x > M_PI_2) {
            x = x - M_PI;
            sign = -sign;
        }
        
        return (sine0(x) * sign);
    }
}

double cosine(double x) {
    return sine(M_PI_2 - x);
}

double tangent(double x) {
    double cosResult = cosine(x);
    
    if (cosResult == 0) {
        return NAN;
    } else {
        return sine(x) / cosResult;
    }
}
