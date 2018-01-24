PFont f;
int [] data;
Table stuff;
float [] circles;
String [] countries;
nipple single;
//nipple [] manynipples;
int [] year;
int years;
int a =0;
int choice;

//load txt file
void setup() {
  size(500, 500);
  f = createFont("Helvetica", 8);
  //tsv = tab separated values
  stuff = loadTable("data.txt", "tsv");
  circles = new float[stuff.getRowCount()];
  countries = new String[stuff.getRowCount()];
  year = new int[]{2005,2012,2015};

  //println(stuff.getRowCount() + " total rows in table"); 
 
  //access values in table
  String s = stuff.getString(0, 0); 
  int t = stuff.getInt(0, 1); 
  //println(s,t);

  //access entire rows
  TableRow row = stuff.getRow(2); 
  //print(row.getFloat(2));
  single = new nipple(150, 150, 60);
  //manynipples = new nipple[stuff.getRowCount()];
}

void draw() {
    //background(250,174,207);
  background(255, 227, 113);
  textFont(f);
  
  //b = a++%3;
  //a = +a%3;
  //print(b, "/");
  //print(a++%3, "/");
  for (int i=0; i<stuff.getRowCount(); i++) {
    //print(i);
    TableRow row2 = stuff.getRow(i);
    //print(row2.getFloat(2),"/");
    //manynipples[i] = row2.getFloat(2);
    //int counter = 0;

    if (row2.getInt(1) == year[choice]) {
      //print(i,":",row2.getString(0),"/");


      //float x = map(i,0,23,0,35);
      circles[i%36]= row2.getFloat(2);
      countries[i%36]=row2.getString(0);

      //print(countries[i], "/");
      //print(circles[i], "/");
    }
    //counter += 1;
    //print(a%3, "/");
  }
  
  for (int i=0; i<6; i++) {
    for (int j=0; j<6; j++) {
      int index = (i*6+j);
      //print(index,"/");
      noStroke();
      fill(250, 246, 237);
      ellipse(width/7*i+(width/7), height/7*j+(height/7), 1.3*circles[index], 1.3*circles[index]);
      fill(209, 131, 146);
      ellipse(width/7*i+(width/7), height/7*j+(height/7), 0.25*circles[index], 0.25*circles[index]);
      fill(130);
      text(countries[index], (width/7*i+(width/7))-20, (height/7*j+(height/7))-20);
    }
  }
   
  //noLoop();
 
  
  fill(100);
  stroke(2, 100);
  line(width-(width-15), 12*height/13, width-15, 12*height/13);
  textSize(13);
  textAlign(LEFT);
  text("% WOMEN IN PARLAMENT - source: https://data.oecd.org", width-(width-15), height-20);
  text(years, width-(width-15), height-(height-20));
  //single.display(); 
  //noLoop();
  // print(a);
}


void keyPressed(){
  int choice = key;
//this switches between color palettes
  switch(choice){
    case 1:
      years = 2005;
      break;
    case 2:
      years = 2012;
      break;
    case 3:
      years = 2015;
      break;
  }
}

class nipple {
  float posX; //width/7;
  float posY; //height/7;
  float diameter;
  float [] rad = circles; 

  nipple(float x, float y, float r) {
    posX = x;
    posY = y;
    diameter=r;
  }

  void display() {
    noStroke();
    fill(250, 246, 237);
    ellipse(posX, posY, diameter, diameter);
    fill(209, 131, 146);
    ellipse(posX, posY, diameter/5, diameter/5);
  }
}