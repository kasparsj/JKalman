import jama.Matrix;
import jkalman.JKalman;

import java.util.Random;

JKalman kalman;
Matrix measurement;

// init
Matrix predicted_state = new Matrix(4, 1);        
Matrix corrected_state = new Matrix(4, 1);

Random rand;
double x = 0;
double y = 0;
double dx, dy;

final int HISTORY = 500;
int cursor = 0;
Float[] measured_x = new Float[HISTORY];
Float[] measured_y = new Float[HISTORY];
Float[] filtered_x = new Float[HISTORY];
Float[] filtered_y = new Float[HISTORY];

void setup() {
  size(960, 480);
  
  try {
    kalman = new JKalman(4, 2);
    
    rand = new Random(System.currentTimeMillis() % 2011);
    // constant velocity
    dx = rand.nextDouble();
    dy = rand.nextDouble();
    
    measurement = new Matrix(2, 1); // measurement [x]
    measurement.set(0, 0, x);
    measurement.set(1, 0, y);

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
  predicted_state = kalman.Predict();
  
  // function init :)
  measurement.set(0, 0, rand.nextDouble());
  measurement.set(1, 0, rand.nextDouble());
  //x = rand.nextGaussian();
  //y = rand.nextGaussian();

  //measurement.set(0, 0, measurement.get(0, 0) + dx + rand.nextGaussian());
  //measurement.set(1, 0, measurement.get(1, 0) + dy + rand.nextGaussian());
  
  measured_x[cursor] = (float) measurement.get(0, 0);
  measured_y[cursor] = (float) measurement.get(1, 0);
  
  drawValue(cursor, measured_x, measured_y);

  // simulate a missing value (more then 1/4 times)
  if (rand.nextGaussian() < -0.8) { 
      // use prediction in this case
      filtered_x[cursor] = (float) predicted_state.get(0, 0);
      filtered_y[cursor] = (float) predicted_state.get(1, 0);
  }
  else { 
      // measurement is ok :)
      corrected_state = kalman.Correct(measurement);

      // use corrected_state
      filtered_x[cursor] = (float) corrected_state.get(0, 0);
      filtered_y[cursor] = (float) corrected_state.get(1, 0);
      
  }
  
  pushMatrix();
  translate(0, height/2);
  drawValue(cursor, filtered_x, filtered_y);
  popMatrix();
  
  cursor = (cursor + 1) % HISTORY;
}

<T>void drawValue(int cursor, T[] x, T[] y) {  
    pushStyle();
    noFill();
    stroke(255, 0, 0);
    plot(x, width, height/2, cursor);
    stroke(0, 255, 0);
    plot(y, width, height/2, cursor);
    popStyle();
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
