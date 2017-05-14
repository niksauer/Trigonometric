//
//  main.c
//  Trigonometric
//
//  Created by Niklas Sauer on 24.04.17.
//  Copyright © 2017 DHBW Stuttgart. All rights reserved.
//

#include <stdio.h>
#include <math.h>

// global definition
#define MAX_DIFF 0.00001
#define PI 3.1415926535897932384626433832795028841971693993751058209749445923078164
#define PI_2 1.57079632679

// function prototypes
void unitTest();
void userInput();

int factorial(int x);
double power(double x, double e);
int modulo(int x, int y);

double taylorSeries(double x, int approximations);
double optimizedTaylorSeries(double x, int approximations);

double sinus0(double x);
double sinus(double x);
double cosinus(double x);
double tangens(double x);


int main(int argc, const char * argv[]) {
    unitTest();
//    userInput();
    return 0;
}

void unitTest() {
    int xMin = -12;
    int xMax = 23;
    double partition = (xMax - xMin) / 20;
    
    for (int i= 0; i < 20; i++) {
        double xValue = xMin + i*partition;
        double custom = sinus(xValue);
        double real = sin(xValue);
        double diff = fabs(real-custom);
        printf("custom sin: % 02.8lf \t real: % 02.8lf \t diff: % 02.8lf \n", custom, real, diff);
    }
    
//    double customResult = tangens(7.9565);
//    double result = tan(7.9565);
//    double diff = fabs(customResult-result);
//    char * acceptable = (diff < MAX_DIFF) ? "yes" : "no";
//    
//    printf("custom(x): %f\n", customResult);
//    printf("proper(x): %f\n", result);
//    printf("error acceptable: %s with difference: %f\n", acceptable, diff);
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
        double sinResult = sinus(xValue);
        double cosResult = cosinus(xValue);
        double tanResult = tangens(xValue);
        
        printf("x%d = % 02.8lf -> \t sin: % 02.8lf (diff: % 02.8lf) \t cos: % 02.8lf (diff: % 02.8lf) \t tan: % 02.8lf (diff: % 02.8lf) \n", i, xValue, sinResult, fabs(sinResult-sin(xValue)), cosResult, fabs(cosResult-cos(xValue)), tanResult, fabs(tanResult-tan(xValue)));
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



double sinus0(double x) {
    int approximations = 6;
    
    return optimizedTaylorSeries(x, approximations);
}

double sinus(double x) {
    if (x >= -M_PI_2 && x <= M_PI_2) {
        return sinus0(x);
    } else {
        int periodOffset;
        
        if (x < -M_PI_2) {
            periodOffset = (int) ((x - M_PI_2) / M_PI);
        } else {
            periodOffset = (int) ((x + M_PI_2) / M_PI);
        }
        
        int isOdd = modulo(periodOffset, 2);
        
        if (isOdd) {
            return sinus0(periodOffset * M_PI - x);
        } else {
            return sinus0(x - periodOffset * M_PI);
        }
    }
}

double cosinus(double x) {
    return sinus(M_PI_2 - x);
}

double tangens(double x) {
    int undefined = (modulo(x-M_PI_2, M_PI) == 0);
    
    if (undefined) {
        return 99;
    } else {
        return sinus(x) / cosinus(x);
    }
}
