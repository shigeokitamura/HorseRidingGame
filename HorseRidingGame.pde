import processing.serial.*;
import cc.arduino.*;
import ddf.minim.*;

//Arduino arduino;
Minim minim;
AudioPlayer player;
AudioSnippet sound1, sound2;

PImage bg, neck;

float x, y, z;
float tx, ty, tz;
float rotX, rotY;
float mX, mY;
float frameCounter;
float xComp, zComp;
float angle = 0;

float vY = 0.0;

boolean canJump = true;
boolean moveUP = false, moveDOWN = false, moveLEFT = false, moveRIGHT = false;

int groundHeight = 0; //地面の高さ
int standHeight = 200; //視点の高さ
int dragMotionConstant = 50;
int pushMotionConstant = 100;
int movementSpeed = 150; //移動速度、大きいほど遅い
float sensitivity = 15;
int stillBox = 50;
float camBuffer = 10;
int cameraDistance = 1000;

int NUM = 4; //センサーの数
int[] sensors = new int[NUM];
int[] sensors_ave = new int[NUM];
String[] sensors_value = new String[NUM];
int average = 0;
int forward = 0;
int[] forward_ave = new int[30];
int backward = 0;
int[] backward_ave = new int[30];
int left = 0;
int[] left_ave = new int[30];
int right = 0;
int[] right_ave = new int[30];
int ws;
int ad;
String ws_str, ad_str;

float oscillation = 0; //上下の揺れ
float angle_star = 0;

boolean gameStart = false;
int gameFlag = 0;
int bestScore = 0;
int[] place_starX = new int[100];
int[] place_starZ = new int[100];
int limitTime = 180;
int startTime;
int gameTime;

Field field;

public void init() {
  frame.removeNotify();
  frame.setUndecorated(true);
  frame.addNotify();
  
  super.init();
}

void setup() {
  //size(displayWidth, displayHeight, P3D);
  size(800, 600, P3D);
  
  frame.setLocation(0,0);
  
  frameRate(60);
  
  bg = loadImage("sky.png"); //背景画像を読み込む
  bg.resize(width, height);
  neck = loadImage("neck.png");
  neck.resize(width/3, width/3*(width/height));
  noStroke();
  
  //カメラ初期化
  x = width/2;
  //x = 0;
  y = height/2;
  y -= standHeight;
  z = (height/2.0) / tan(PI*60.0 / 360.0);
  //z = 0;
  tx = width/2;
  ty = height/2;
  tz = 0;
  rotX = 0;
  rotY = 0;
  xComp = tx - x;
  zComp = tz - z;
  
  for(int i = 0; i < 10; i++) {
    forward_ave[i] = 0;
    backward_ave[i] = 0;
  }
  
  field = new Field(0, 0);
  
  starXZ();
  
  //arduino = new Arduino(this, Arduino.list()[5]);
  minim = new Minim(this);
  player = minim.loadFile("BGM.mp3");
  player.loop();
  sound1 = minim.loadSnippet("bell1.mp3");
  sound2 = minim.loadSnippet("bell2.mp3");
}

void draw() {
  background(bg);
  
  cameraUpdate();
  locationUpdate();
  keepLocation();
  jumpManager(5);
  
  field.drawGrass();
  field.drawSand();
  field.drawScoreboard(limitTime - (gameTime/1000), bestScore, gameStart);
  field.drawWall();
  field.draw_practice();
  field.drawSection();
  //field.draw_20x40();
  
  angle_star += (PI/60);
  
  game(gameStart);
  
  
  //sensor();
  
  //最前面に表示
  beginCamera();
  hint(DISABLE_DEPTH_TEST);
  camera();
  fill(255, 255, 0);
  textSize(16);
  textAlign(LEFT);
  text("FPS:" + (int)frameRate + " " + ws_str + " " + ad_str
  /*+ "  X:" + (int)x
  + "  Y:" + (int)y
  + "  Z:" + (int)z
  + "  W:" + sensors_value[0]
  + "  A:" + sensors_value[1]
  + "  S:" + sensors_value[2]
  + "  D:" + sensors_value[3]
  + "  WS:"+ ws_str
  + "  AD:"+ ad_str*/
  , 0, 16);
  imageMode(CENTER);
  image(neck, width/2, height-neck.height/2);
  hint(ENABLE_DEPTH_TEST);
  endCamera();
  
  //カメラ設定
  camera(x, y, z, tx, ty, tz, 0, 1, 0);
}

void stop() {
  player.close();
  sound1.close();
  sound2.close();
  minim.stop();
  super.stop();
}

public void keyPressed() {
  if(key == 'w') {
    //moveZ = -10;
    moveUP = true;
  }else if(key == 's') {
    //moveZ = 10;
    //moveDOWN = true;
    moveUP = false;
  }else if(key == 'a') {
    //moveX = -10;
    moveLEFT = true;
  }else if(key == 'd') {
    //moveX = 10;
    moveRIGHT = true;
  }
}

public void keyReleased() {
  if(key == 'w') {
    moveUP = false;
    //moveZ = 0;
  }else if(key == 's') {
    moveDOWN = false;
    //moveZ = 0;
  }else if(key == 'a') {
    moveLEFT = false;
    //moveX = 0;
  }else if(key == 'd') {
    moveRIGHT = false;
    //moveX = 0;
  }
}

public void cameraUpdate() { //視点移動用関数
  int diffX = mouseX - width/2;
  //int diffX = ad;
  if(diffX > 300) diffX = 300;
  if(diffX < -300) diffX = -300;
  //int diffY = mouseY - width/2;
  float diffY = sin(oscillation) * 30;
  oscillation += PI/(movementSpeed/2);
  //println(diffY);
  if(abs(diffX) > stillBox) {
    xComp = tx - x;
    zComp = tz - z;
    angle = correctAngle(xComp, zComp);
    
    angle += diffX/(sensitivity*10);
    
    if(angle < 0) {
      angle += 360;
    }else if(angle >= 360) {
      angle -= 360;
    }
    
    tx = cameraDistance * sin(radians(angle)) + x;
    tz = -cameraDistance * cos(radians(angle)) + z;
    
  }
  if(abs(diffY) > stillBox) {
    ty += diffY/(sensitivity/1.5);
  }
  /*
  if(moveUP == true) {
    ty += diffY/(sensitivity/1.5);
  }
  */
}

public float correctAngle(float xc, float zc) {
  float newAngle = -degrees(atan(xc/zc));
  if(xComp > 0 && zComp > 0) {
    newAngle = (90 + newAngle) + 90;
  }else if(xComp < 0 && zComp > 0) {
    newAngle = newAngle + 180;
  }else if(xComp < 0 && zComp < 0) {
    newAngle = (90 + newAngle) + 270;
  }
  return newAngle;
}

public void locationUpdate() { //場所移動
  if(moveUP == true) {
    if(movementSpeed < 75) movementSpeed = 75;
    if(movementSpeed > 500) {
      movementSpeed = 500;
      if(ws < 100) {
        moveUP = false;
      }
    }
    //println(movementSpeed);
    z  += zComp/movementSpeed;
    tz += zComp/movementSpeed;
    x  += xComp/movementSpeed;
    tx += xComp/movementSpeed;
  }else if(moveDOWN == true) {
    z  -= zComp/movementSpeed;
    tz -= zComp/movementSpeed;
    x  -= xComp/movementSpeed;
    tx -= xComp/movementSpeed;
  }
  if(moveRIGHT == true) {
    z  += xComp/movementSpeed;
    tz += xComp/movementSpeed;
    x  -= zComp/movementSpeed;
    tx -= zComp/movementSpeed;
  }
  if(moveLEFT == true) {
    z  -= xComp/movementSpeed;
    tz -= xComp/movementSpeed;
    x  += zComp/movementSpeed;
    tx += zComp/movementSpeed;
  }
}

public void keepLocation() { //馬場の外に出られないように
  if(x > 4900) x = 4900;
  if(x < -2900) x = -2900;
  if(z > 2900) z = 2900;
  if(z < -2900) z = -2900;
}

public void jumpManager(int magnitude) { //ジャンプ
  if(keyPressed == true && key == ' ' && canJump == true) {
    vY -= magnitude;
    if(vY < -10) {
      canJump = false;
    }
  }else if(y < groundHeight + standHeight) {
    vY++;
  }else if(y >= groundHeight + standHeight) {
    vY = 0;
    y = groundHeight + standHeight;
  }
  if(canJump != true && keyPressed != true) {
    //println("Jump Reset!");
    canJump = true;
  }
  y += vY; 
}
/*
public void sensor() {
  for(int i = 0; i < NUM; i++) {
    sensors[i] = arduino.analogRead(i);
    sensors[i] *= 100;
  }
  sensors[0] *= 2;
  //sensors[2] *= 2;
  sensors[3] *= 2;
  forward_ave[average] = sensors[0];
  backward_ave[average] = sensors[2];
  left_ave[average] = sensors[1];
  right_ave[average] = sensors[3];
  average++;
  if(average >= 30) {
    average = 0;
    forward = 0;
    backward = 0;
    left = 0;
    right = 0;
    for(int i = 0; i < 10; i++) {
      forward += forward_ave[i];
      backward += backward_ave[i];
      left += left_ave[i];
      right += right_ave[i];
    }
    forward /= 30;
    backward /= 30;
    left /= 30;
    right /= 30;
    sensors_value[0] = nf(forward, 3);
    sensors_value[1] = nf(left, 3);
    sensors_value[2] = nf(backward, 3);
    sensors_value[3] = nf(right, 3);
    ws = forward - backward;
    ad = right - left;
    //ad = sensors[3]-sensors[1];
    ws_str = nf(ws, 3);
    ad_str = nf(ad, 3);
    //movementSpeed -= ws/30;
    ad -= 50;
    if(keyPressed) {
      if(key == CODED) {
        if(keyCode == LEFT) {
          ad = -150;
        }else if(keyCode == RIGHT) {
          ad = 150;
        }
      }
    }
    
    //println(sensors_value[1], sensors_value[3]);
    println(ws, ad);
  }
  if(ws > 100) {
    moveUP = true;
  }
}
*/

void game(boolean start) {
  if(start == false) {
    field.drawStar(place_starX[0], place_starZ[0], angle_star, gameFlag);
    if(x > -200 && x < 200 && z > -200 && z < 200) {
      gameStart = true;
      gameFlag = 1;
      startTime = millis();
      sound1.rewind();
      sound1.play();
    }
  }else if(start == true) {
    gameTime = millis() - startTime;
    //println(gameTime / 1000);
    field.drawStar(place_starX[gameFlag], place_starZ[gameFlag], angle_star, gameFlag);
    if(x > (place_starX[gameFlag] - 200) && x < (place_starX[gameFlag] + 200)
    && z > (place_starZ[gameFlag] - 200) && z < (place_starZ[gameFlag] + 200)) {
      gameFlag++;
      sound2.rewind();
      sound2.play();
    }
    if(limitTime - (gameTime/1000) < 0) {
      gameStart = false;
      if(gameFlag > bestScore) {
        bestScore = gameFlag;
      }
      gameFlag = 0;
      starXZ();
      sound1.rewind();
      sound1.play();
    }
  }
}

void starXZ() {
  place_starX[0] = 0;
  place_starZ[0] = 0;
  for(int i = 1; i < 100; i++) {
    place_starX[i] = (int)random(-2800, 4800);
    place_starZ[i] = (int)random(-2800, 2800);
  }
}

