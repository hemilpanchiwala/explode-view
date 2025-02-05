library explode_view;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;

// The duration for the scattering the particles and fade out
const explosionDuration = Duration(milliseconds: 1500);

// The duration for shaking the image while creating the particles
const shakingDuration = Duration(milliseconds: 3000);

const noOfParticles = 64;

class ExplodeView extends StatelessWidget {

  final String imagePath;
  final double imagePosFromLeft;
  final double imagePosFromTop;

  const ExplodeView({
    @required this.imagePath,
    @required this.imagePosFromLeft,
    @required this.imagePosFromTop
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    return new Container(
      child: new ExplodeViewBody(screenSize: size, imagePath: imagePath, imagePosFromLeft: imagePosFromLeft, imagePosFromTop: imagePosFromTop),
    );
  }
}

class ExplodeViewBody extends StatefulWidget {
  final Size screenSize;
  final String imagePath;
  double imagePosFromLeft = 200;
  double imagePosFromTop = 400;

  ExplodeViewBody({Key key, @required this.screenSize, @required this.imagePath, @required this.imagePosFromLeft, @required this.imagePosFromTop}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExplodeViewState();
}

class _ExplodeViewState extends State<ExplodeViewBody> with TickerProviderStateMixin{

  GlobalKey currentKey;
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();

  bool useSnapshot = true;
  bool isImage = true;
  math.Random random;

  final List<Particle> particles = [];

  AnimationController imageAnimationController;

  double imageSize = 50.0;
  double distFromLeft=10.0, distFromTop=10.0;

  final StreamController<Color> _stateController = StreamController<Color>.broadcast();
  img.Image photo;

  @override
  void initState() {
    super.initState();

    currentKey = useSnapshot ? paintKey : imageKey;
    random = new math.Random();

    imageAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );

  }

  Vector3 _shakeImage() {
    return Vector3(math.sin((imageAnimationController.value) * math.pi * 20.0) * 8, 0.0, 0.0);
  }

  Future<void> loadImageBundleBytes() async {
    ByteData imageBytes = await rootBundle.load(widget.imagePath);
    setImageBytes(imageBytes);
  }

  Future<void> loadSnapshotBytes() async {
    RenderRepaintBoundary boxPaint = paintKey.currentContext.findRenderObject();
    ui.Image capture = await boxPaint.toImage();
    ByteData imageBytes =
    await capture.toByteData(format: ui.ImageByteFormat.png);
    setImageBytes(imageBytes);
    capture.dispose();
  }

  void setImageBytes(ByteData imageBytes) {
    List<int> values = imageBytes.buffer.asUint8List();
    photo = img.decodeImage(values);
  }

  Future<Color> getPixel(Offset globalPosition, Offset position, double size) async {
    if (photo == null) {
      await (useSnapshot ? loadSnapshotBytes() : loadImageBundleBytes());
    }

    Color newColor = calculatePixel(globalPosition, position, size);
    return newColor;
  }

  Color calculatePixel(Offset globalPosition, Offset position, double size) {

    double px = position.dx;
    double py = position.dy;


    if (!useSnapshot) {
      double widgetScale = size / photo.width;
      px = (px / widgetScale);
      py = (py / widgetScale);

    }


    int pixel32 = photo.getPixelSafe(px.toInt()+1, py.toInt());

    int hex = abgrToArgb(pixel32);

    _stateController.add(Color(hex));

    Color returnColor = Color(hex);

    return returnColor;
  }

  int abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isImage
          ? StreamBuilder(
        initialData: Colors.green[500],
        stream: _stateController.stream,
        builder: (buildContext, snapshot) {
          return Stack(
            children: <Widget>[
              RepaintBoundary(
                key: paintKey,
                child: GestureDetector(
                  onLongPress: () {
                    imageAnimationController.forward();

                    RenderBox box = imageKey.currentContext.findRenderObject();
                    Offset imagePosition = box.localToGlobal(Offset.zero);
                    double imagePositionOffsetX = imagePosition.dx;
                    double imagePositionOffsetY = imagePosition.dy;

                    double imageCenterPositionX = imagePositionOffsetX + (imageSize / 2);
                    double imageCenterPositionY = imagePositionOffsetY + (imageSize / 2);

                    final List<Color> colors = [];

                    for(int i = 0; i < noOfParticles; i++){
                      setState(() {
                        distFromLeft = imagePositionOffsetX.toDouble();
                        distFromTop = (imagePositionOffsetY - 60).toDouble();
                      });
                      if(i < 21){
                        getPixel(imagePosition, Offset(imagePositionOffsetX + (i * 0.7), imagePositionOffsetY - 60), box.size.width).then((value) {
                          colors.add(value);
                        });
                      }else if(i >= 21 && i < 42){
                        getPixel(imagePosition, Offset(imagePositionOffsetX + (i * 0.7), imagePositionOffsetY - 52), box.size.width).then((value) {
                          colors.add(value);
                        });
                      }else{
                        getPixel(imagePosition, Offset(imagePositionOffsetX + (i * 0.7), imagePositionOffsetY - 68), box.size.width).then((value) {
                          colors.add(value);
                        });
                      }
                    }

                    Future.delayed(Duration(milliseconds: 3500), () {

                      for(int i = 0; i < noOfParticles; i++){
                        if(i < 21){
                          particles.add(Particle(id: i, screenSize: widget.screenSize, colors: colors[i].withOpacity(1.0), offsetX: (imageCenterPositionX - imagePositionOffsetX + (i * 0.7)) * 0.1, offsetY: (imageCenterPositionY - (imagePositionOffsetY - 60)) * 0.1, newOffsetX: imagePositionOffsetX + (i * 0.7), newOffsetY: imagePositionOffsetY - 60));
                        }else if(i >= 21 && i < 42){
                          particles.add(Particle(id: i, screenSize: widget.screenSize, colors: colors[i].withOpacity(1.0), offsetX: (imageCenterPositionX - imagePositionOffsetX + (i * 0.5)) * 0.1, offsetY: (imageCenterPositionY - (imagePositionOffsetY - 52)) * 0.1, newOffsetX: imagePositionOffsetX + (i * 0.7), newOffsetY: imagePositionOffsetY - 52));
                        }else{
                          particles.add(Particle(id: i, screenSize: widget.screenSize, colors: colors[i].withOpacity(1.0), offsetX: (imageCenterPositionX - imagePositionOffsetX + (i * 0.9)) * 0.1, offsetY: (imageCenterPositionY - (imagePositionOffsetY - 68)) * 0.1, newOffsetX: imagePositionOffsetX + (i * 0.7), newOffsetY: imagePositionOffsetY - 68));
                        }
                      }

                      setState(() {
                        isImage = false;
                      });
                    });
                  },
                  child: Container(
                    alignment: FractionalOffset((widget.imagePosFromLeft / widget.screenSize.width), (widget.imagePosFromTop / widget.screenSize.height)),
                    child: Transform(
                      transform: Matrix4.translation(_shakeImage()),
                      child: Image.asset(
                        widget.imagePath,
                        key: imageKey,
                        width: imageSize,
                        height: imageSize,
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ):
          Container(
            child: Stack(
              children: <Widget>[
                for(Particle particle in particles) particle.startParticleAnimation()
              ],
            ),
          )
    );
  }

  @override
  void dispose(){
    imageAnimationController.dispose();
    super.dispose();
  }

}

class Particle extends _ExplodeViewState {

  int id;
  Size screenSize;
  Offset position;
  Paint singleParticle;

  double offsetX=0.0, offsetY=0.0;
  double newOffsetX = 0.0, newOffsetY = 0.0;

  static final randomValue = math.Random();
  AnimationController animationController;

  Animation translateXAnimation, negatetranslateXAnimation;
  Animation translateYAnimation, negatetranslateYAnimation;
  Animation fadingAnimation;
  Animation particleSize;

  double lastXOffset, lastYOffset;
  Color colors;


  Particle({@required this.id, @required this.screenSize, this.colors, this.offsetX, this.offsetY, this.newOffsetX, this.newOffsetY}) {

    position = Offset(this.offsetX, this.offsetY);

    math.Random random = new math.Random();
    this.lastXOffset = random.nextDouble() * 100;
    this.lastYOffset = random.nextDouble() * 100;

    animationController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1500)
    );

    translateXAnimation = Tween(begin: position.dx, end: lastXOffset).animate(animationController);
    translateYAnimation = Tween(begin: position.dy, end: lastYOffset).animate(animationController);
    negatetranslateXAnimation = Tween(begin: -1 * position.dx, end: -1 * lastXOffset).animate(animationController);
    negatetranslateYAnimation = Tween(begin: -1 * position.dy, end: -1 * lastYOffset).animate(animationController);
    fadingAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(animationController);

    particleSize = Tween(begin: 5.0, end: random.nextDouble() * 20).animate(animationController);

  }

  startParticleAnimation() {
    animationController.forward();

    return Container(
      alignment: FractionalOffset((newOffsetX / screenSize.width), (newOffsetY / screenSize.height)),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget widget) {
          if(id % 4 == 0){
            return Transform.translate(
              offset: Offset(translateXAnimation.value, translateYAnimation.value),
              child: FadeTransition(
                opacity: fadingAnimation,
                child: Container(
                  width: particleSize.value>5 ? particleSize.value : 5,
                  height: particleSize.value>5 ? particleSize.value : 5,
                  decoration: BoxDecoration(
                      color: colors,
                      shape: BoxShape.circle
                  ),
                ),
              )
            );
          }else if(id % 4 == 1){
            return Transform.translate(
              offset: Offset(negatetranslateXAnimation.value, translateYAnimation.value),
              child: FadeTransition(
                opacity: fadingAnimation,
                child: Container(
                  width: particleSize.value>5 ? particleSize.value : 5,
                  height: particleSize.value>5 ? particleSize.value : 5,
                  decoration: BoxDecoration(
                      color: colors,
                      shape: BoxShape.circle
                  ),
                ),
              )
            );
          }else if(id % 4 == 2){
            return Transform.translate(
              offset: Offset(translateXAnimation.value, negatetranslateYAnimation.value),
              child: FadeTransition(
                opacity: fadingAnimation,
                child: Container(
                  width: particleSize.value>5 ? particleSize.value : 5,
                  height: particleSize.value>5 ? particleSize.value : 5,
                  decoration: BoxDecoration(
                      color: colors,
                      shape: BoxShape.circle
                  ),
                ),
              )
            );
          }else{
            return Transform.translate(
              offset: Offset(negatetranslateXAnimation.value, negatetranslateYAnimation.value),
              child: FadeTransition(
                opacity: fadingAnimation,
                child: Container(
                  width: particleSize.value>5 ? particleSize.value : 5,
                  height: particleSize.value>5 ? particleSize.value : 5,
                  decoration: BoxDecoration(
                      color: colors,
                      shape: BoxShape.circle
                  ),
                ),
              )
            );
          }
        },
      ),
    );
  }
}