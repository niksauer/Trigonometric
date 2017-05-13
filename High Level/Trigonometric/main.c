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

// function prototypes
void unitTest();
void userInput();

int factorial(int x);
double modulo(double x, double y);
double taylor(double x, int approximations);
double optimizedTaylor(double x, int approximations);
double sinus0(double x);
double sinus(double x);
double cosinus(double x);
double tangens(double x);


int main(int argc, const char * argv[]) {
    userInput();
    return 0;
}

void unitTest() {
    double customResult = tangens(7.9565);
    double result = tan(7.9565);
    double diff = fabs(customResult-result);
    char * acceptable = (diff < MAX_DIFF) ? "yes" : "no";
    
    printf("custom(x): %f\n", customResult);
    printf("proper(x): %f\n", result);
    printf("error acceptable: %s with difference: %f\n", acceptable, diff);
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
        
        printf("x%d = % 02.8lf -> \t sin: % 02.8lf (diff: % 02.8lf) \t cos: % 02.8lff (diff: % 02.8lf) \t tan: % 02.8lf (diff: % 02.8lf) \n", i, xValue, sinResult, fabs(sinResult-sin(xValue)), cosResult, fabs(cosResult-cos(xValue)), tanResult, fabs(tanResult-tan(xValue)));
    }
}

int factorial(int x) {
    if (x == 1) {
        return 1;
    } else {
        return x * factorial(x-1);
    }
}

double modulo(double x, double y) {
    int quotient = (int) x / y;
    
    return (x - (quotient * y));
}

double taylor(double x, int approximations) {
    double res = 0;
    
    for (int i = 0; i < approximations; i++) {
        double step = 0;
        double counter = pow(x, 2*i+1);
        double denominator = factorial(2*i+1);
        
        step = pow(-1, i) * (counter/denominator);
        res = res + step;
    }
    
    return res;
}

double optimizedTaylor(double x, int approximations) {
    // first taylor term
    double counter = pow(x, 2*0+1);
    double denominator = factorial(2*0+1);
    double firstTaylorTerm = counter / denominator;
    
    if (approximations == 1) {
        return firstTaylorTerm;
    } else {
        double res = firstTaylorTerm;
        double lastTerm = firstTaylorTerm;
        
        for (int i = 1; i < approximations; i++) {
            double nextTerm = lastTerm * (pow(x, 2) / ((2*i) * (2*i+1)));
            
            res = res + (pow(-1, i) * nextTerm);
//            printf("lastTerm: %f, nextTerm: %f, res: %f\n", lastTerm, nextTerm, res);
            
            lastTerm = nextTerm;
        }
        
        return res;
    }
}

double sinus0(double x) {
    int approximations = 6;
    
    return optimizedTaylor(x, approximations);
}

double sinus(double x) {
    if (x >= -M_PI_2 && x <= M_PI_2) {
        return sinus0(x);
    } else {
        int periodOffset;
        
        if (x > 0) {
            periodOffset = (int) ((x + M_PI_2) / M_PI);
        } else {
            periodOffset = (int) ((x - M_PI_2) / M_PI);
        }
        
        int isOdd = modulo(periodOffset, 2);
        
        if (isOdd) {
            return sinus0(periodOffset*M_PI - x);
        } else {
            return sinus0(x - periodOffset*M_PI);
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
        return sinus(x)/cosinus(x);
    }
}
