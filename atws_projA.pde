import peasy.*;
PeasyCam cam;
MotionDataManager motionData;
MotionDataManager motionData2;

int n_bone = 25;
PVector[] pos = new PVector[n_bone];
PVector[] pos2 = new PVector[n_bone];

BufferLine bufLine;

int channel = 0;
int n_channel = 5;
int frame = 0;

boolean record = false;

void setup() {
  frameRate(30);
 // fullScreen(P3D);
  size(1280, 720, P3D);

  cam = new PeasyCam(this, 100, 0, 0, 100); 
  cam.setMinimumDistance(50);  
  cam.setMaximumDistance(500);  

  motionData = new MotionDataManager();
  motionData.setDataPath("data/kata.csv");

  motionData2 = new MotionDataManager();
  motionData2.setDataPath("data/uke2.csv");

  for(int i = 0; i < n_bone; i++)
  {
    pos[i] = new PVector();
    pos2[i] = new PVector();
  }

  bufLine = new BufferLine(50);

}

void draw() {
  //noCursor();
 // rotateY(frameCount * 0.01);
  background(0);
  lights();

  //Show Dimention Arrow
  pushStyle();

  stroke(255, 0, 0);
  line(0, 0, 0, 20, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 20, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 20);

  popStyle();

  push();
  pushStyle();

  translate(-100, -300, -0.75);
  fill(0, 255, 0);
  box(10, 600, 900);

  popStyle();
  pop();

  motionData.setDataMode(true);
  motionData.update();
  motionData.setBasePosition(0, -1.0, 1.5);
  motionData.setBaseScale(75);

  motionData2.setDataMode(true);
  motionData2.update();
  motionData2.setBasePosition(0, -1.0, 3);
  motionData2.setBaseScale(75);

  for(int i = 0; i < n_bone; i ++)
  {
    pos[i] = motionData.getBoneData(i);

    push();

    translate(pos[i].x, pos[i].y, pos[i].z);

    //debug print
    // println("x: " + pos[i].x + "y: " + pos[i].y + "z: " + pos[i].z);

    pushStyle();
    noStroke();
    fill(179, 145, 23);
    if(channel == 0 || channel == 2) 
    {
      if(i==11) 
      {
        float size = map(pos[i].z, 10, 50, 5, 8);

        pushStyle();
        noFill();
        stroke(25,255,244,50);
        sphere(9);
        popStyle();

        if(pos[i].z >= 25)
        {
          noStroke();
          fill(255,0,0);

        }
        sphere(size);
      }
      else 
      {
        sphere(4);
      }
    }
    popStyle();
    pop();

    //second data
    pos2[i] = motionData2.getBoneData(i);
    push();
    translate(pos2[i].x, pos2[i].y, pos2[i].z);
    pushStyle();
    noStroke();
    fill(179, 145, 23);
    sphere(4);
    popStyle();
    pop();
  }

  bufLine.updateBuffer(pos);

  if(channel == 1 || channel == 2) bufLine.drawBufferLine();
  pushStyle();
  stroke(255, 128);
  motionData.drawGrid(50, 20);
  popStyle();

  if(record) 
  {
    saveFrame ("frames/######.png");
    frame++;
  }
}

void keyPressed() {
  switch(key){
    case '1':
      channel = 0;
      break;

    case '2':
      channel = 1;
      break;

    case '3':
      channel = 2;
      break;
  }

  if(keyCode == ENTER)
  {
    record = !record;
  }
}

class BufferLine {
  int BUFFER_SIZE = 10;
  PVector[][] bonePosBuffer;

  BufferLine(int bufferSize)
  {
    this.BUFFER_SIZE = bufferSize;
    this.bonePosBuffer = new PVector[this.BUFFER_SIZE][n_bone];

    for (int i = 0; i < BUFFER_SIZE; i ++)
    {
      for (int j = 0; j < n_bone; j ++)
      {
        bonePosBuffer[i][j] = new PVector(0, 0, 0);
      }
    }
  }

  void updateBuffer(PVector[] np)
  {
    for (int i = BUFFER_SIZE - 1; i > 0; i --)
    {
      for (int j = 0; j < n_bone; j ++)
      {
        if(j==11) 
        {
          this.bonePosBuffer[i][j].x= this.bonePosBuffer[i - 1][j].x;
          this.bonePosBuffer[i][j].y= this.bonePosBuffer[i - 1][j].y;
          this.bonePosBuffer[i][j].z= this.bonePosBuffer[i - 1][j].z;
        }
      }
    }

    for (int i = 0; i < n_bone; i ++)
    {
      if (i == 11)
      {
        this.bonePosBuffer[0][i].x= np[i].x;
        this.bonePosBuffer[0][i].y= np[i].y;
        this.bonePosBuffer[0][i].z= np[i].z;
      }
    }
  }

  void drawBufferLine()
  {
    for (int i = 0; i < BUFFER_SIZE - 1; i ++)
    {
      
      for (int j = 0; j < n_bone; j ++)
      {
        pushStyle();
        float dist = this.bonePosBuffer[i][j].dist(this.bonePosBuffer[i + 1][j]);

        //fire 
        int rgb_g = (int)random(0, 235);
        stroke(255, rgb_g, 0);

        line(this.bonePosBuffer[i][j].x, this.bonePosBuffer[i][j].y, this.bonePosBuffer[i][j].z, 
          this.bonePosBuffer[i + 1][j].x, this.bonePosBuffer[i + 1][j].y, this.bonePosBuffer[i + 1][j].z);
        popStyle();
      }
    }
  }
}
