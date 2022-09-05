import jama.Matrix;
import jkalman.JKalman;

import java.util.Random;

JKalman kalman;
Matrix m; // measurement [x, y]

// init
Matrix s = new Matrix(4, 1); // state [x, y, dx, dy, dxy]        
Matrix c = new Matrix(4, 1); // corrected state [x, y, dx, dy, dxy]

Random rand;
double x = 0;
double y = 0;
double dx, dy;

final int HISTORY = 500;
int cursor = 0;
Float[] m_x = new Float[HISTORY];
Float[] m_y = new Float[HISTORY];
Float[] c_x = new Float[HISTORY];
Float[] c_y = new Float[HISTORY];

void setup() {
  size(960, 480);
  
  try {
    kalman = new JKalman(4, 2);
    
    rand = new Random(System.currentTimeMillis() % 2011);
    // constant velocity
    dx = rand.nextDouble();
    dy = rand.nextDouble();
    
    m = new Matrix(2, 1); // measurement [x]
    m.set(0, 0, x);
    m.set(1, 0, y);

    // transitions for x, y, dx, dy
    double[][] tr = { {1, 0, 1, 0}, 
                      {0, 1, 0, 1}, 
                      {0, 0, 1, 0}, 
                      {0, 0, 0, 1} };
    kalman.setTransition_matrix(new Matrix(tr));
    
    // 1s somewhere?
    kalman.setError_cov_post(kalman.getError_cov_post().identity());

    // init first assumption similar to first observation (cheat :)
    // kalman.setState_post(kalman.getState_post());

    // report what happend first :)
    println("first x:" + x + ", y:" + y + ", dx:" + dx + ", dy:" + dy);
    println("no; x; y; dx; dy; predictionX; predictionY; predictionDx; predictionDy; correctionX; correctionY; correctionDx; correctionDy;");
  }
  catch (Exception ex) {
    println(ex.getMessage());
  }
}

void draw() {
  background(0);
  
  // check state before
  s = kalman.Predict();
  
  // function init :)
   m.set(0, 0, rand.nextDouble());
   m.set(1, 0, rand.nextDouble());
  //x = rand.nextGaussian();
  //y = rand.nextGaussian();

  //m.set(0, 0, m.get(0, 0) + dx + rand.nextGaussian());
  //m.set(1, 0, m.get(1, 0) + dy + rand.nextGaussian());                

  // a missing value (more then 1/4 times)
  if (rand.nextGaussian() < -0.8) { 
      //System.out.println(";;;;" + s.get(0, 0) + ";" + s.get(1, 0) + ";" + s.get(2, 0) + ";" + s.get(3, 0) + ";");
  }
  else { // measurement is ok :)
      // look better
      c = kalman.Correct(m);
  
      m_x[cursor] = (float) m.get(0, 0);
      m_y[cursor] = (float) m.get(1, 0);
      
      c_x[cursor] = (float) c.get(0, 0);
      c_y[cursor] = (float) c.get(1, 0);
      
      pushMatrix();
      pushStyle();
      noFill();
      stroke(255, 0, 0);
      plot(m_x, width, height/2, cursor);
      stroke(0, 255, 0);
      plot(m_y, width, height/2, cursor);
      popMatrix();
      
      pushMatrix();
      translate(0, height/2);
      stroke(255, 0, 0);
      plot(c_x, width, height/2, cursor);
      stroke(0, 255, 0);
      plot(c_y, width, height/2, cursor);
      popStyle();
      popMatrix();
      
      cursor = (cursor + 1) % HISTORY;
      
      //System.out.println(m.get(0, 0) + ";" + m.get(1, 0) + ";" + x + ";" + y + ";"
      //         + s.get(0, 0) + ";" + s.get(1, 0) + ";" + s.get(2, 0) + ";" + s.get(3, 0) + ";"
      //         + c.get(0, 0) + ";" + c.get(1, 0) + ";" + c.get(2, 0) + ";" + c.get(3, 0) + ";");
  }
}

<T>void plot(T[] hist, float w, float h, int k) {
  float mw = w / hist.length;
  beginShape();
  for (int i=0; i<hist.length; i++) {
    int j = (i+k+1) % hist.length;
    if (hist[j] != null) {
      float val = (float) hist[j];
      vertex(i*mw, val * h);
    }
  }
  endShape();
}
