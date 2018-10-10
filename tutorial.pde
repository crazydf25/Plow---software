import processing.video.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*;
import KinectPV2.*;

KinectPV2 kinect;
boolean foundUsers = false;

ArrayList<Dot> dots = new ArrayList<Dot>();
float timeStamp = 0.0f;
int maxD = 4500; // 4.5mx
int minD = 0;  //  50cm

FFT fft;
Minim minim;
AudioPlayer player;
AudioSample c_select, enter;
BeatDetect beatD;

Movie[] video = new Movie[4];
PImage[] menu = new PImage[5];
PImage[] breath = new PImage[21];
PImage[] bar = new PImage[5];
PImage[] title = new PImage[2];
int Ba = 0;
Menu m;
int stage;

int textA=0;
Breathing breathing;
float cb;

Serial port;
int sensorNum = 2;
int dataNum = 500;
int[] rawData = new int[sensorNum];
float[] postProcessedDataArray = new float[sensorNum];
float[][] sensorHist = new float[sensorNum][dataNum];
boolean b_pause = false;
int dataIndex;
int points = 0;
float bpm = 113.8;

void setup(){
  size(displayWidth,displayHeight,P3D);
  minim = new Minim(this);
  //player = minim.loadFile("I Can Make You Dance (Part I) - Zapp.mp3");
  player = minim.loadFile("HOZIN对KID BOOGIE的第一首.mp3");
  //player = minim.loadFile("Stevie Salas - Body Slamm 2001 [Big Brother Bootsy Mix] - remix.mp3");
  player.loop();
  breathing = new Breathing();
  for(int i = 0; i<title.length; i++){
    title[i] = loadImage("interface " + i + ".png");
  }
  for(int i = 0; i<menu.length; i++){
    menu[i] = loadImage("interface 2.2-" + i + ".png");
  }
  for(int i = 0; i<bar.length; i++){
    bar[i] = loadImage("interface 2.3-" + i + ".png");
  }
  for(int i = 0; i<breath.length; i++){
    breath[i] = loadImage(i + ".png");
  }
  for(int i = 0; i < 4;i++){
    video[i] = new Movie (this, i+".mp4");
  }
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
   String portName = Serial.list()[Serial.list().length-1];//check the printed list
   port = new Serial(this, portName, 115200);
   port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
   port.clear();
  m = new Menu();
  stage = 1;
  kinect = new KinectPV2(this);
  kinect.enableBodyTrackImg(true);
  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonColorMap(true);
  kinect.init();
}

void draw(){
  background(40);
  cb = ((rawData[0]))*5;
  select();
  if(stage == 1){
    breathing.display1();
    if(Ba<20){
      Ba++;
    }else{
      Ba = 0;
    }
    tint(255,255);
    image(breath[Ba],width/2+300,0,1600,height);
    m.display1();
    if(cb>1000){
      stage = 2;
    }
  }
  if(stage == 2){
    for(int i = dots.size() - 1; i >= 0; i--) {
      Dot dot = dots.get(i);
      dot.display();
      if(dot.x > width + 5) dots.remove(i);
    }
    
    if(millis() - timeStamp > 0) {
      dots.add(new Dot(0));
      timeStamp += 80;
    }
    breathing.display2();
    for(int i = 0; i< video.length; i++){
      if(i == textA){
        video[i].loop();
        image(video[textA],0,0,width,height);
      }
    }
    if(textA != 4){
      skeleton();
    }
    if (textA == 4){
      freestyle();
    }
    m.display2();

  }
}

void movieEvent(Movie video){
  video.read();
}

void select(){
    if (rawData[1] == 0) {
      textA = 0; 
    }else if (rawData[1] == 1){
      textA = 1; 
    }else if (rawData[1] == 2){
      textA = 2; 
    }else if (rawData[1] == 3){
      textA = 3;
    }else if (rawData[1] >= 4){
      textA = 4;
    }
    println(textA);
}

void freestyle(){
  ArrayList<PImage> bodyTrackList = kinect.getBodyTrackUser();
  for (int i = 0; i < bodyTrackList.size(); i++) {
    PImage bodyTrackImg = (PImage)bodyTrackList.get(i);
    image(bodyTrackImg, 0, 0, width, height);
  }
}

void serialEvent(Serial port) {   
  String inData = port.readStringUntil('\n');  // read the serial string until seeing a carriage return
  dataIndex = 0;
  if (!b_pause) {
    //assign data index based on the header
    if (inData.charAt(0) == 'A') {  
      dataIndex = 0;
    }
    if (inData.charAt(0) == 'B') {  
      dataIndex = 1;
    }
    //data processing
    if (dataIndex>=0) {
      rawData[dataIndex] = int(trim(inData.substring(1))); //store the value
      postProcessedDataArray[dataIndex] = map(rawData[dataIndex], 0, 1024, 0, height); //scale the data (for visualization)
      appendArray(sensorHist[dataIndex], rawData[dataIndex]); //store the data to history (for visualization)
      return;
    }
  }
}

float[] appendArray (float[] _array, float _val) {
  float[] array = _array;
  float[] tempArray = new float[_array.length-1];
  arrayCopy(array, tempArray, tempArray.length);
  array[0] = _val;
  arrayCopy(tempArray, 0, array, 1, tempArray.length);
  return array;
}

void skeleton() {
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);
      drawBody(joints);
    }
  }
}

//DRAW BODY
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

//draw joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  //translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
 // translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX()+2000, joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX()+2000, joints[jointType2].getY(), joints[jointType2].getZ());
}