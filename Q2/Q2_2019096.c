/* Name: Rupanshoo Saxena
   Roll_Number: 2019096 */

/*WITH RACE CONDITION*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/file.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#define maxfilesize 1000000

int main(){
   int num, menuChoice=0, fileSize;
   int filedes ;

   FILE *fptr;
   char fileName[70];
   char fileContents[maxfilesize];
   char ch;

   while(1){
      printf("\nWelcome to Text Editor:\nEnter your choice : \n1. Enter name of file you want to load\n2. Exit\n");
      scanf("%d",&menuChoice);
      if(menuChoice != 1){exit(0);}
      else{
         printf("Enter file name: ");
         scanf("%s",fileName);   

         // printf("%s",fileName);

         filedes = open(fileName, O_RDWR | O_APPEND);

         if((fptr = fdopen(filedes, "a+")) == 0){
            perror("File doesn't exist, creating new file...");
            exit(EXIT_FAILURE);
         }

         int i=0;

         //saving contents saved in the opened file to an array.
         while (1) { 
            if(i<maxfilesize){      //less than max file size
               ch = fgetc(fptr);   // Read a Character 
               if (ch == EOF)     // Check for End of File 
                  break;

               // printf("%c",ch);
               fileContents[i] = ch;
               i++;   
            }
         }

         printf("%s\n",fileContents);
         fileSize = sizeof(fileContents);

         int st = flock(filedes, LOCK_EX | LOCK_NB);


         if(st!=0){   //Locked file
            printf("Warning: File is already open...you are not advised to write in this file \n");  //advisory warning
            char appendInput[maxfilesize - fileSize];
            printf("\nEnter text to append: ");
            scanf("%s",appendInput);
            if(sizeof(appendInput)>maxfilesize-fileSize){  //if input is greater than the file space available
               perror("File space full...exiting...");
               exit(EXIT_FAILURE);
            }
            fprintf(fptr,"%s",appendInput);
            fclose(fptr);
            close(filedes);
            // sleep(1);
            continue;
         }
         else if(st == -1){perror("flock() failed!! exiting....");exit(EXIT_FAILURE);}

         char appendInput[maxfilesize - fileSize];         
         printf("\nEnter text to append: ");
         scanf("%s",appendInput);
         if(sizeof(appendInput)>maxfilesize-fileSize){   //if input is greater than the file space available
               perror("File space full...exiting...");
               exit(EXIT_FAILURE);
            }
         fprintf(fptr,"%s",appendInput);
         fclose(fptr);
         close(filedes);
      }
   }
}