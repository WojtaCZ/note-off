#include <iostream>
#include <fstream>
#include <array>

using namespace std;

int main(int argc, char * argv[]){

    //Check if we got all the needed parameters
    if(argc != 3){
        cout << "Invalid number of arguments" << endl;
        exit(1);
    }

    //Open the input file
    ifstream inputFile(argv[1], std::ifstream::binary);

    //Check if the file opened succesfully
    if(!inputFile){
        cout << "Couldn't open input file" << endl;
        exit(1);
    }

    //Create an output file
    ofstream outputFile(argv[2], std::ofstream::binary);

    //Check if it was created
    if(!outputFile){
        cout << "Couldn't create output file" << endl;
        exit(1);
    }

    //Jump to the beginning, skipping the MThd header
    if(!inputFile.seekg(4)){
        cout << "Reached EOF during header skipping" << endl;
        exit(1);
    }

    //Get the four bytes defining header size (needs ot be size of five to also fit the null character which get always returns)
    char header[5];
    if(!inputFile.get(header, 5)){
        cout << "Couldt't get header size" << endl;
        exit(1);
    }

    int mthdSize = header[0] << 12| header[1] << 8 | header[2] << 4 | header[3];

    cout << "Skipping MThd of size " << mthdSize << " bytes" << endl;

    //Get back to the beginning 
    inputFile.seekg(0);

    //Buffer to fit the MThd + size + content + MTrk + size + null terminator
    char headerBuffer[4 + 4 + mthdSize + 4 + 4 + 1];

    //Copy whole header to the output file
    inputFile.read(headerBuffer, sizeof(headerBuffer));
    outputFile.write(headerBuffer, sizeof(headerBuffer)-1);

    //Skip the MThd with MTrk and MTrk size
    if(!inputFile.seekg(mthdSize+4+4)){
        cout << "Reached EOF during header skipping" << endl;
        exit(1);
    }

    //Go through the whole file
    char c;
    //Note counter
    int counter;
    //Helper arrays
    char noteOn[3], noteOff[3];
    while(inputFile.get(c)){
        //If we got a note on event
        if((c & 0xF0) == 0x90){

            cout << "Got a " << hex << (int)c << " at " << std::dec << inputFile.tellg() << endl;
            char note;
            char velocity;

            //Get the note and its velocity
            if(!inputFile.get(note)){
                cout << "Got EOF while trying to get note" << endl;
                exit(1);
            }

            if(!inputFile.get(velocity)){
                cout << "Got EOF while trying to get velocity" << endl;
                exit(1);
            }
            
            //If the velocity is 0
            if(velocity == 0){
                //Construct a note off event
                noteOff[0] = (c & 0x0F) | 0x80;
                noteOff[1] = note;
                noteOff[2] = 0;
                //Write it to the output
                outputFile.write(noteOff, 3);
                //Increment note counter
                counter++;
            }else{
                //Construct a note on event
                noteOff[0] = c;
                noteOff[1] = note;
                noteOff[2] = velocity;
                //Write it to the output
                outputFile.write(noteOn, 3);
            }
        }else{
            outputFile.put(c);
        }
    }

    inputFile.close();
    outputFile.close();

    cout << "Successfuly replaced " << counter << " notes" << endl;
}