class Menu{
  
  Menu(){
    
  }
  
  void display1(){
    for(int i = 0;i<title.length;i++){
      image(title[i],0,0,width,height);
      tint(255);
    }
    for(int i = 0;i < menu.length; i++){
      if(i == textA){
        tint(255,255);
      }else{
        tint(255,30);
      }
      image(menu[i],0,0,width,height);
    }
  }
  
  void display2(){
    for(int i = 0;i<bar.length;i++){
      if(i == textA){
        tint(255,255);
      }else{
        tint(255,30);
      }
      image(bar[i],0,0,width,height); 
    }
    
  }
}