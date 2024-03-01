# JKalman Processing Library

JKalman is a Kalman Filter library written by Petr Chmelar.

For the original source code see:
https://sourceforge.net/projects/jkalman/

## Installation

Copy this directory into `processing/libraries`

## Usage

```
// 1-dimensional example
JKalman kalman = new JKalman(2, 1);

// Transition matrix (model dynamics)
Matrix transition = new Matrix(new double[][]{{1, 1}, {0, 1}});
kalman.setTransition_matrix(transition);

// Initial state estimate (can be zero or some initial guess)
Matrix initial_state = new Matrix(new double[][]{{0}, {0}});
kalman.setState_pre(initial_state);

// Example measurement loop
Matrix measurement = new Matrix(1, 1); // One measurement
double[] noisyMeasurements = new double[]{2, 3, 2.5, 3.2, 2.8}; // Example measurements

for (double measurementVal : noisyMeasurements) {
    measurement.set(0, 0, measurementVal); // Set the current measurement value

    // Correct the state estimate with the new measurement
    Matrix corrected_state = kalman.Correct(measurement);
    System.out.println("Corrected State: " + corrected_state.get(0, 0));
    
    // Predict the next state
    Matrix predicted_state = kalman.Predict();
    System.out.println("Predicted State: " + predicted_state.get(0, 0));
}
```

For x,y 2-dimensional example see: [examples/Test.pde](https://github.com/kasparsj/JKalman/blob/main/examples/Test/Test.pde)

## Build

```bash
gradle -q
```

## Generate JavaDoc

```bash
gradle javadoc
```

## License

GNU General Public License version 2.0 (GPLv2), Intel Open Source License
