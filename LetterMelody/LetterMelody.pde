import processing.sound.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.datatransfer.*;
import javax.swing.*;
import java.io.*;
import java.awt.event.KeyEvent;

String alphabet = "abcdefghijklmnopqrstuvwxyz";
String blankSymbols = " ,.\n?:";
boolean ctrlOn = false;
//String alphabet = "qrstuopcdefgabjklmnhixyzvw";

// Oscillator and envelope 
TriOsc triOsc;
Env env; 

// Times and levels for the ASR envelope
float attackTime = 0.001;
float sustainTime = 0.004;
float sustainLevel = 0.05;
float releaseTime = 0.2;

// This is an octave in MIDI notes.
/*int[] midiSequence = { 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72
}; */

int [] midiRef = { 
  48, 50, 52, 53, 55, 57, 59,
  60, 62, 64, 65, 67, 69, 71,
  72, 74, 76, 77, 79, 81, 82,
  84, 86, 88, 89, 91
}; 

int[] midiSequence = { 
}; 

// Set the duration between the notes
int duration = 250;
// Set the note trigger
int trigger = 0; 

// An index to count up the notes
int note = 0; 
boolean loop = false;

int lineSpace = 5;
int rowSpace = 120;
int staffLength = 1880;
int staffCount = 8;

int trebleclefOffset = 0;
int currNoteIndex = trebleclefOffset;
boolean isPlaying = true;

PImage img;

int IndexOf(int[] array, int ele){
  for(int i=0;i<array.length;i++){
    if (array[i] == ele)
      return i;
  }
  return -1;
}

void DrawNote(char letter){
  if (blankSymbols.indexOf(letter) != -1){
    currNoteIndex++;
    return;
  }
  if (alphabet.indexOf(letter) == -1)
    return;
  
  currNoteIndex++;
  int indexLetter = alphabet.indexOf(letter);
  int midi = midiRef[indexLetter];

  int beginX = 60;
  int noteSpace = 30;
  int rowCap = (staffLength-beginX)/noteSpace;
  int x = beginX + (currNoteIndex%rowCap)*noteSpace;
  int relativeSpace = IndexOf(midiRef,midi) - midiRef.length/2;
  int currMiddleY = currNoteIndex/rowCap*rowSpace + rowSpace - 2*lineSpace;
  int y = - relativeSpace*lineSpace/2 + currMiddleY;
  int noteRad = 10;
  int barLen = 20;
  
  fill(255);
  //rotate(-PI/70);
  ellipse(x, y, noteRad, noteRad*0.6);
  int lineYOffset = 1;
  //rotate(PI/70);
  line(x+noteRad/2, y+lineYOffset, x+noteRad/2, y - barLen);
  
  //Add lines orspaces
  int relativeLineNum = relativeSpace/2;
  int identifier = relativeSpace > 0 ? 1 : -1;
  int additionalLineNum = 0;
  if (relativeLineNum > 2 || relativeLineNum < -2)
    additionalLineNum = relativeLineNum - identifier*2;
  for (int j=1;j<=identifier*additionalLineNum;j++){
    int currY = currMiddleY-identifier*lineSpace*(j+2);
    line(x-noteRad, currY, x+noteRad, currY);
  }
  
  //Letter
  textSize(14);
  fill(255);
  text(letter, x-noteRad/2, currMiddleY + 10*lineSpace); 
}

void DrawStaff(){
  //treble clef symbol
  img = loadImage("treble-clef-white.png");
  image(img, 40, 70, 30, 70);
  
  //Lines
  stroke(255);
  for (int j=0;j<staffCount;j++)
    for (int i=0;i<5;i++){
      int currY = lineSpace*i + rowSpace*j + rowSpace - 4*lineSpace;
      line(40, currY, staffLength, currY);
    }
}

void PlayNote(int midi){
  triOsc.play(midiToFreq(midi), 0.8);
  env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
}

void UpdateMidiSequenceFromData(){
  String[] rawdata = loadStrings("data.txt");  
  String data = "";
  for (int i=0; i<rawdata.length; i++)
    data += " " + rawdata[i];
  data = data.toLowerCase();
  
  for (int i=0;i<data.length();i++){
    int alphabetIndex = alphabet.indexOf(data.charAt(i));
    if (alphabetIndex != -1)
      midiSequence = append(midiSequence, midiRef[alphabetIndex]);
    else if (blankSymbols.indexOf(data.charAt(i)) != -1)
      midiSequence = append(midiSequence, 0);    
  }
}

void AppendMidiSequence(String s){
  for (int i=0;i<s.length();i++){
    int midi = LetterToMidi(s.charAt(i));
    if (midi == 0){
        if (midiSequence[midiSequence.length-1] != 0 )
          midiSequence = append(midiSequence, midi);  
    }
    else
      midiSequence = append(midiSequence, midi);
  }
}

void AppendMidiSequenceFromClipboard(){
  Clipboard cb = Toolkit.getDefaultToolkit().getSystemClipboard();
  try {
     Transferable t = cb.getContents(null);
     if (t.isDataFlavorSupported(DataFlavor.stringFlavor)){
       String clipboardContent = (String)t.getTransferData(DataFlavor.stringFlavor);
       clipboardContent = clipboardContent.toLowerCase();
       System.out.println(clipboardContent);
       AppendMidiSequence(clipboardContent);
       DrawMidiSequence();
       isPlaying = true;
     }
  } catch (UnsupportedFlavorException ex) {
      System.out.println("");
  }catch (IOException ex) {
      System.out.println("");
  }
}

void mousePressed(){
  if (mouseButton == LEFT)
    isPlaying = !isPlaying;
  else if(mouseButton == RIGHT)
    AppendMidiSequenceFromClipboard();
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == CONTROL) {
      ctrlOn = false;
      println("ctrl off");
    } 
  }
}

void keyPressed() {
  //Ctrl
  if (key == CODED) {
    println(key);
    if (keyCode == CONTROL) {
      if (!ctrlOn){
        ctrlOn = true;
        println("ctrl on");
      }
    } 
  }

  //Avoid inputting command letter
  if (ctrlOn)
    return;
  
  //Backspace to delete
  if (key == BACKSPACE) {
    if (midiSequence.length > 0){
      println("BACKSPACE");
      midiSequence = shorten(midiSequence);
      DrawMidiSequence();
    }
    return;
  }

  //Non alpabet char
  int indexLetter = alphabet.indexOf(key); 
  if(indexLetter == -1){
    if (midiSequence.length > 0){
      if (midiSequence[midiSequence.length-1] == 0)
        return;
    }
    midiSequence = append(midiSequence, 0);
    DrawMidiSequence();
    return;
  }
  
  //alphabet char
  int midi = midiRef[indexLetter];
  midiSequence = append(midiSequence, midi);
  DrawMidiSequence();
  PlayNote(midi);
}

char MidiToLetter(int midi){
  if(midi == 0)
    return ' ';
  else if (IndexOf(midiRef,midi) > -1)
    return alphabet.charAt(IndexOf(midiRef, midi));
  else
    return '?'; 
}

int LetterToMidi(char c){
  int indexLetter = alphabet.indexOf(c); 
  return indexLetter>=0?midiRef[indexLetter]:0;
}

void ResetScreen(){
  background(0);
  DrawStaff();
  currNoteIndex = 0;
}

void DrawMidiSequence(){
  ResetScreen();
  for(int i=0;i<midiSequence.length;i++){
    char currLetter=MidiToLetter(midiSequence[i]);
    //println(currLetter);
    DrawNote(currLetter);
  }
}

void setup() {
  //size(640, 950);
  fullScreen();
  ResetScreen();
  //UpdateMidiSequenceFromData();
  
  // Create triangle wave and envelope 
  triOsc = new TriOsc(this);
  env  = new Env(this);
  
  loop();
}

void draw() { 
    // If value of trigger is equal to the computer clock and if not all 
    // notes have been played yet, the next note gets triggered.
    if (isPlaying){
      if ((millis() > trigger) && (note<midiSequence.length)) {
    
        // midiToFreq transforms the MIDI value into a frequency in Hz which we use 
        //to control the triangle oscillator with an amplitute of 0.8
        triOsc.play(midiToFreq(midiSequence[note]), 0.8);
    
        // The envelope gets triggered with the oscillator as input and the times and 
        // levels we defined earlier
        env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
    
        // Create the new trigger according to predefined durations and speed
        trigger = millis() + duration;
    
        // Advance by one note in the midiSequence;
        note++; 
    
        // Loop the sequence
        if (note == midiSequence.length )
          isPlaying = false;
        /*if (loop && note == midiSequence.length) 
            note = 0;*/
      }  
    }
    else
      note=0;
} 

// This function calculates the respective frequency of a MIDI note
float midiToFreq(int note) {
  return (pow(2, ((note-69)/12.0)))*440;
}