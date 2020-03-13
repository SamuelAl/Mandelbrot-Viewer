import interfascia.*;

//Main settings
int height = 500;
int width = 600;
int yMargin = 50;

//GUI Settings
GUIController controller;
IFButton resetButton;
boolean mouseOver = true;
PFont font, titleFont;

//Calculation Settings
double EPSILON = 1e-12;
double xStart = -3;
double xEnd = 1.5;
double yStart = -1.5;
double yEnd = 1.5;
int maxIterations = 2000;
int INFINITY = 18;
float muLimit = 1;


//Zoom rectangle settings
float xProportion = 0.5;
float yProportion = 0.5;

boolean calculateFractal = true;
void setup()
{
  size(600, 500);
  controller = new GUIController(this);
  resetButton = new IFButton("Reset", width - 400, 10, 40);
  resetButton.addActionListener(this);
  controller.add(resetButton);
  font = createFont("Arial", 12);
  titleFont = createFont("Arial", 20);
  textFont(font);
  pixelDensity(1);
  loadPixels();
}

void draw()
{
  if (calculateFractal)
  {
    for (int x = 0; x < width; x++)
    {
      for (int y = yMargin; y < height; y++)
      {

        double a = map(x, 0, width, xStart, xEnd);
        double b = map(y, 0 + yMargin, height, yStart, yEnd);

        double cReal = a;
        double cIm = b;

        int iteration = 0;

        while (iteration < maxIterations)
        {
          double zSquaredReal = (a*a) - (b*b);
          double zSquaredIm = 2 * a * b;
          a = zSquaredReal + cReal;
          b = zSquaredIm + cIm;
          double modulus = Math.sqrt((a*a) + (b*b));
          if (modulus > INFINITY)
            break;
          iteration++;
        }

        colorMode(HSB, 360, 100, 100);
        double modulus = Math.sqrt((a*a) + (b*b));
        double mu = iteration + 1 - (Math.log(Math.log(modulus)))/log(2.0);
        if (Double.isNaN(mu)) {
          mu = 0;
        }
        float hue = (float) map(mu, 0, muLimit, 0, 5);
        float saturation = 100;
        float lightness = 100;
        if (iteration == maxIterations)
          lightness = 0;
        int pixelIndex = (y*width) + x;
        pixels[pixelIndex] = color(hue, saturation, lightness);
      }
    }
    calculateFractal = false;
  }
  updatePixels();
  fill(0);
  textFont(font);
  text("Real Limits: " + String.format("%.2f", xStart) + "  -  " + String.format("%.2f", xEnd), 10, 15);
  text("Imaginary Limits: " + String.format("%.2f", yStart) + "  -  " + String.format("%.2f", yEnd), 10, 27);
  textFont(titleFont);
  text("MANDELBROT EXPLORER", width - 300, 20);
  rectMode(CENTER);
  stroke(0);
  fill(0, 0, 0, 0);
  if (focused && mouseOver)
  {
    rect(mouseX, mouseY, width*xProportion, height*yProportion);
  }
}


public void mouseExited() {
  mouseOver= false;
}

public void mouseEntered() {
  mouseOver= true;
}

void zoom(int x, int y)
{
  xStart = map(x - ((width*xProportion)/2.0), 0, width, xStart, xEnd);
  xEnd = map(x + ((width*xProportion)/2.0), 0, width, xStart, xEnd);
  yStart = map(y - ((height*yProportion)/2.0), 0, height, yStart, yEnd);
  yEnd = map(y + ((height*yProportion)/2.0), 0, height, yStart, yEnd);
  calculateFractal = true;
}

void mousePressed()
{
  zoom(mouseX, mouseY);
}

void actionPerformed(GUIEvent e)
{
  if (e.getSource() == resetButton)
  {
    xStart = -3;
    xEnd = 1.5;
    yStart = -1.5;
    yEnd = 1.5;
    calculateFractal = true;
  }
}

double map(double valueCoord1, 
  double startCoord1, double endCoord1, 
  double startCoord2, double endCoord2) 
{

  if (Math.abs(endCoord1 - startCoord1) < EPSILON) {
    throw new ArithmeticException("/ 0");
  }

  double offset = startCoord2;
  double ratio = (endCoord2 - startCoord2) / (endCoord1 - startCoord1);
  return ratio * (valueCoord1 - startCoord1) + offset;
}
