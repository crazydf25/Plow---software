class Dot {
  //float y;
  float x;
  boolean virgin = true;
  color myColor = color(195,30,84,80);
  float r = 100f;
  boolean beatchange = true;
  
  Dot(float _x) {
    x = _x;
  }
  
  void display() {
    x+=bpm/30;
    if(x>0 && x<100){
      r = cb/4;
    }
    //stroke(myColor);
    //strokeWeight(1);
    fill(myColor);
    rect(x, height-r-50, 20, r-50);
    noFill();
    noStroke();
  }
}