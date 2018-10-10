class Breathing{
  int a=0;
  int id;
  float al;
  float x;
  boolean beatchange = true;
  
  Breathing (){

  }
  void display1(){
    noStroke();
    fill(255,180);
    ellipse(width/2-800,height/2-200,1200,1200);
    fill(40);
    ellipse(width/2-800,height/2-200,900,900);
    noFill();
    fill(195,30,84,200);
    ellipse(width/2-800,height/2-200,cb,cb);
    fill(40);
    ellipse(width/2-800,height/2-200,cb-200,cb-200);
    noFill();

  }
  
  void display2(){
    if(textA != 4){
      strokeWeight(30);
    }else{
      strokeWeight(100);
    }
    noFill();
    stroke(195,30,84,200);
    ellipse(width/2-800,height/2-200,cb,cb);
    noStroke();
  }
}