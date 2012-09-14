import sys
from PIL import Image

filenames = [
  "basic/blank.png",
  "basic/triangle.png",
  "basic/rectangle.png",
  "basic/small.png",
  "basic/medium.png",
  "basic/large.png",
  "Alex Wolfe/Border.png",
  "Alex Wolfe/Butterfly.png",
  "Alex Wolfe/Checkers.png",
  "Alex Wolfe/Cyan Frame.png",
  "Alex Wolfe/Double Point.png",
  "Alex Wolfe/Drain.png",
  "Alex Wolfe/Green Frame.png",
  "Alex Wolfe/Lace.png",
  "Alex Wolfe/Maze.png",
  "Alex Wolfe/Stripe.png",
  "Alex Wolfe/Yellow Frame.png",
  "Caius/checker.png",
  "Caius/diamond.png",
  "Caius/fin.png",
  "Caius/flame.png",
  "Caius/herringbone2.png",
  "Caius/herringbone.png",
  "Caius/king.png",
  "Caius/moon.png",
  "Caius/queen.png",
  "Caius/star.png",
  "Caius/up.png",
  "CryoGenik/Circles.png",
  "CryoGenik/Floral.png",
  "CryoGenik/Gothic-Windows.png",
  "CryoGenik/Sound.png",
  "CryoGenik/Splatter.png",
  "CryoGenik/Star-Corners.png",
  "CryoGenik/Tribal-Frame.png",
  "CryoGenik/Tribal-Heart.png",
  "geironul/yin.png",
#  "Richard Deck/TF+Stamps+-+SeaHorse+1.png",
#  "Richard Deck/TF+Stamps+-+SeaHorse+2.png",
#  "Richard Deck/TF+Stamps+-+SeaHorse+3.png",
#  "Richard Deck/TF+Stamps+-+SeaHorse+4.png",
#  "Richard Deck/TF+Stamps+-+SeaHorse+5.png",
#  "Richard Deck/TF+Stamps+-+SeaHorse+6.png",
  "SaintPeter/Block-A.png",
  "SaintPeter/Block-B.png",
  "SaintPeter/Block-C.png",
  "SaintPeter/Exclamation.png",
  "SaintPeter/Question.png",
]

print "package"
print "{"
print "  public class Stamps"
print "  {"
print "    public static var stamps = ["

for file in filenames:
  print "      ["
  image = Image.open(file)
  data = image.getdata();

  i = 1

  sys.stdout.write("        \"")
  for pixel in data:
    if ((len(pixel) > 3 and pixel[3] == 0) or
        (pixel[0] == 255 and pixel[1] == 255 and pixel[2] == 255)):
      sys.stdout.write("0")
    else:
      sys.stdout.write("1")
    if i % 30 == 0:
      sys.stdout.write("\",\n")
      if i < len(data) - 1:
        sys.stdout.write("        \"")
    i = i + 1
  print "      ],";

print "    ];"
print "  }"
print "}"

