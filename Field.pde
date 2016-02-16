class Field {
  int x;
  int y;
  int z;
  PImage img_grass = loadImage("grass.png");
  PImage img_sand = loadImage("sand.png");
  PImage img_wall = loadImage("wall.png");
  
  PShape practice = loadShape("practice.obj");
  PShape practice_cross = loadShape("practice_cross.obj");
  PShape practice_oxer = loadShape("practice_oxer.obj");
  PShape cone = loadShape("cone.obj");
  PShape section_pole = loadShape("section.obj");
  
  Field(int x1, int y1) {
    x = x1;
    y = y1;
  }
  
  void drawGrass() {
    pushMatrix();
    translate(0, 401, 0);
    rotateX(PI/2);
    textureMode(NORMAL);
    textureWrap(REPEAT);
    beginShape();
    texture(img_grass);
    vertex(x-8000, y-8000, 0, 0);
    vertex(x+8000, y-8000, 2, 0);
    vertex(x+8000, y+8000, 2, 2);
    vertex(x-8000, y+8000, 0, 2);
    endShape();
    popMatrix();
  }
  
  void drawSand() {
    pushMatrix();
    translate(0, 400, 0);
    rotateX(PI/2);
    textureMode(NORMAL);
    beginShape();
    texture(img_sand);
    vertex(x-5000, y-3000, 0, 0);
    vertex(x+5000, y-3000, 1, 0);
    vertex(x+5000, y+3000, 1, 1);
    vertex(x-5000, y+3000, 0, 1);
    endShape();
    popMatrix();
  }
  
  void drawWall() {
    pushMatrix();
    translate(0, 0, 3000);
    textureMode(NORMAL);
    textureWrap(REPEAT);
    beginShape();
    texture(img_wall);
    vertex(x-5000, y+250, 0, 0);
    vertex(x+5000, y+250, 50, 0);
    vertex(x+5000, y+400, 50, 1);
    vertex(x-5000, y+400, 0, 1);
    endShape();
    popMatrix();
    
    pushMatrix();
    translate(0, 0, -3000);
    textureMode(NORMAL);
    textureWrap(REPEAT);
    beginShape();
    texture(img_wall);
    vertex(x-5000, y+250, 0, 0);
    vertex(x+5000, y+250, 50, 0);
    vertex(x+5000, y+400, 50, 1);
    vertex(x-5000, y+400, 0, 1);
    endShape();
    popMatrix();
    
    pushMatrix();
    translate(5000, 0, 0);
    rotateY(PI/2);
    textureMode(NORMAL);
    textureWrap(REPEAT);
    beginShape();
    texture(img_wall);
    vertex(x-3000, y+250, 0, 0);
    vertex(x+3000, y+250, 30, 0);
    vertex(x+3000, y+400, 30, 1);
    vertex(x-3000, y+400, 0, 1);
    endShape();
    popMatrix();
    
    pushMatrix();
    translate(-5000, 0, 0);
    rotateY(PI/2);
    textureMode(NORMAL);
    textureWrap(REPEAT);
    beginShape();
    texture(img_wall);
    vertex(x-3000, y+250, 0, 0);
    vertex(x+3000, y+250, 30, 0);
    vertex(x+3000, y+400, 30, 1);
    vertex(x-3000, y+400, 0, 1);
    endShape();
    popMatrix();
  }
  
  void draw_practice() {
    pushMatrix();
    translate(-4000, 400, 0);
    rotateX(PI);
    rotateY(PI/2);
    rotateY(PI);
    shape(practice, 0, 0);
    translate(0, 0, 500);
    shape(practice_cross, 0, 0);
    translate(0, 0, -1000);
    rotateY(PI);
    shape(practice_oxer, 0, 0);
    popMatrix();
  }
  
  void drawSection() {
    pushMatrix();
    translate(-3000, 400, 2800);
    rotateX(PI);
    scale(2);
    shape(cone, 0, 0);
    for(int i = 1; i < 15; i++) {
      int j = 200;
      translate(0, 0, j);
      shape(cone, 0, 0);
      j += 200;
    }
    popMatrix();
    pushMatrix();
    translate(-3000, 260, 0);
    rotateX(PI/2);
    shape(section_pole, 0, 0);
    popMatrix();
  }
  
  void draw_20x40() {
    pushMatrix();
    translate(-1000, 390, 0);
    fill(200);
    box(20, 20, 4000);
    translate(2000, 0, 0);
    box(20, 20, 4000);
    popMatrix();
    pushMatrix();
    translate(0, 390, -2000);
    rotateY(PI/2);
    box(20, 20, 2000);
    popMatrix();
    pushMatrix();
    translate(0, 390, 2000);
    rotateY(PI/2);
    translate(0, 0, 625);
    box(20, 20, 750);
    translate(0, 0, -1250);
    box(20, 20, 750);
    popMatrix();
  }
  
  void drawStar(int x, int z, float angle, int number) {
    pushMatrix();
    translate(x, 300, z);
    rotateY(angle);
    fill(255, 255, 0);
    textSize(150);
    textAlign(CENTER);
    text("★", 0, 0);
    fill(255, 0, 0);
    hint(DISABLE_DEPTH_TEST);
    if(number == 0) {
      textSize(20);
      text("START", 0, -50);
    }else{
      textSize(30);
      text(number, 0, -40);
    }
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }
  
  void drawScoreboard(int time, int bestScore, boolean start) {
    pushMatrix();
    translate(0, 0, 3200);
    fill(0);
    rect(0, 0, 500, 300);
    fill(200);
    rect(50, 300, 50, 100);
    rect(400, 300, 50, 100);
    fill(255);
    translate(0, 0, -1);
    rotateY(PI);
    textAlign(CENTER);
    if(start == true) {
      textSize(200);
      text(time, -250, 200);
    }else{
      textSize(80);
      text("BEST SCORE", -250, 100);
      text(bestScore, -250, 200);
    }
    popMatrix();
  }
}
