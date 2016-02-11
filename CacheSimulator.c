//
//  main.c
//  cache
//
//  Created by Dylan Wight on 10/28/15.
//  Copyright © 2015 Dylan Wight. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct cacheLine {
    int valid;
    int tag;
    struct cacheLine* next;
};

int isInCache(int tag, struct cacheLine* cache[]);
void loadNewCache(struct cacheLine* cache[]);
void overwriteOldestLine(int tag, struct cacheLine* cache[]);
void printCache(struct cacheLine* cache[]);

int cacheSize;        // cache size in bytes
int lineSize;           // length of cache lines in bytes
int numSets;            // number of sets in cache


int main(int argc, const char * argv[]) {

    struct cacheLine* cache[100];
    
    char addresses[1000];
    
    printf("Cache total size (in bytes)?: ");
    scanf("%d", &cacheSize);
    printf("Bytes per block?: ");
    scanf("%d", &lineSize);
    printf("How many sets?: ");
    scanf("%d", &numSets);
    printf("Input the list of addresses, seperated by commas: ");
    getchar();
    fgets(addresses, 1000, stdin);
    
    int commas = 0;
    for (int i = 0; i < 1000; i++) {
        if (addresses[i] == ',') {
            commas++;
        }
    }
    commas++;
    
    int test_set[1000];
    
    int j = 0;
    int number = 0;
    for (int i = 0; i < 1000; i++) {
        if (addresses[i] == ',' || addresses[i] == '\n') {
            test_set[j++] = number;
            number = 0;
        }
        else if (addresses[i] == '0'||addresses[i] == '1'||addresses[i] == '2'||addresses[i] == '3'||addresses[i] == '4'||addresses[i] == '5'||addresses[i] == '6'||addresses[i] == '7'||addresses[i] == '8'||addresses[i] == '9') {
            number = (number * 10) + ((int) addresses[i] - 48);
        }
        else {
            continue;
        }
    }
    
    loadNewCache(cache);
    
    for (int i = 0; i < commas; i++) {
        int address = test_set[i];
        if (isInCache(address, cache) == 0) {
            overwriteOldestLine(address/lineSize, cache);
        }
    }
    
    printCache(cache); 
    
}

int isInCache(int address, struct cacheLine* cache[]) {
    struct cacheLine* line = cache[address/lineSize % numSets];                           // find the first cache line in the correct set
    while (line != NULL) {
        if (line->tag == address/lineSize && line->valid == 1)
        {
            printf("%d,\tHIT\n", address);
            return 1;
        }
        line = line->next;
    }
    printf("%d,\tMISS\n", address);
    return 0;
}

void overwriteOldestLine(int tag, struct cacheLine* cache[]) {
    //struct cacheLine* = cache
    struct cacheLine* nextOldestLine = cache[tag % numSets];                // find 2nd oldest cacheLine in the set
    
    if (nextOldestLine->next == NULL) {
        nextOldestLine->valid = 1;
        nextOldestLine-> tag = tag;
        nextOldestLine->next = NULL;
    } else {
        while (nextOldestLine->next->next != NULL) {
            nextOldestLine = nextOldestLine->next;
        }
    
        nextOldestLine->next->valid = 1;                                        // overwrite oldest line
        nextOldestLine->next->tag = tag;
        nextOldestLine->next->next = cache[tag % numSets];
    
        cache[tag % numSets] = nextOldestLine->next;                            // set new cacheLine as head
    
        nextOldestLine->next = NULL;                                            // set nextOldestLine as tail
    }
}

void loadNewCache(struct cacheLine* cache[]) {
    for (int set = 0; set < numSets; set++) {
        struct cacheLine* oldLine = malloc(sizeof(oldLine));
        struct cacheLine* newLine;
                   
        oldLine->valid = 0;
        oldLine->tag = 0;
        oldLine->next = NULL;
                   
        for (int i = 1; i < (cacheSize / lineSize / numSets); i++) {
            newLine = malloc(sizeof(newLine));
            newLine->valid = 0;
            newLine->tag = 0;
            newLine->next = oldLine;            // point to last cacheLine made
            
            oldLine = newLine;                  // move new cacheLine to old
        }
        
        cache[set] = oldLine;                  // sets last next pointer in each set to NULL
    }
}

void printCache(struct cacheLine* cache[]) {
    for (int set = 0; set < numSets; set++) {
        printf("\ncache set [%d]\n", set);
        struct cacheLine* line = cache[set];
        while (line != NULL) {
            printf("   Valid?: %d Tag: %d\n", line->valid, line->tag);
            line = line->next;
        }
    }
}




