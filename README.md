# MATLAB MultiMethod DiffSolver Suite

A feature-rich MATLAB App Designer application created for solving Ordinary Differential Equations (ODEs) using both **symbolic** and **numerical** methods. The app provides real-time solutions, dynamic plotting, usage guidance, and a PDF export feature for generating reports.

---

## Key Features

* **Multiple Solving Methods:**
  * **Symbolic Differential Equation:** Solves ODEs analytically using MATLAB's `dsolve` and plots the resulting function.
  * **Euler Method:** Numerical approach using standard first-order Euler integration.
  * **RK4 (Runge-Kutta 4th Order):** High-accuracy numerical solver for complex differential equations.
* **Interactive UI:** Built using MATLAB App Designer with customized layout panels, user inputs, and built-in axes.
* **Dynamic Plotting:** Automatically plots symbolic curves or numerical data points (`x` vs `y`) upon solving.
* **Help & Examples:** Built-in guidance popup showing syntax examples for each method.
* **PDF Report Generation:** Export current equation details and solutions into a vector PDF report.

---

## UI Preview & Layout

| Component | Description |
| :--- | :--- |
| **Header Panel** | Styled title bar (`MultiMethod DiffSolver`). |
| **Equation Input** | Input field (`txtEquation`) to enter ODE expressions. |
| **Method Dropdown** | Select between *Differential Equation*, *Euler*, or *RK4*. |
| **Control Buttons** | `Solve`, `Export PDF`, `Help`, and `Clear`. |
| **Solution Display** | Text area for numerical step-by-step values or symbolic results. |
| **Plot Axes** | Integrated `UIAxes` displaying graphical solutions. |

---

## How to Run

1. Open MATLAB and set the working directory to the project folder.
2. Run the code directly from the Command Window:
   ```matlab
   main
