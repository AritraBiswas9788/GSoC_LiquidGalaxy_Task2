/*import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import '../providers/data_providers.dart';
import '../utils/extensions.dart';

import '../constants/constants.dart';*/


class KMLMakers {
  static screenOverlayImage(String imageUrl, double factor) =>
      '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
    <Document id ="logo">
         <name>Smart City Dashboard</name>
             <Folder>
                  <name>Splash Screen</name>
                  <ScreenOverlay>
                      <name>Logo</name>
                      <Icon><href>$imageUrl</href> </Icon>
                      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                      <screenXY x="0.025" y="0.95" xunits="fraction" yunits="fraction"/>
                      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                      <size x="300" y="${300 * factor}" xunits="pixels" yunits="pixels"/>
                  </ScreenOverlay>
             </Folder>
    </Document>
</kml>''';

  static String lookAtLinear(double latitude, double longitude, double zoom,
          double tilt, double bearing) =>
      '<gx:duration>2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';

  static String orbitLookAtLinear(double latitude, double longitude,
      double zoom, double tilt, double bearing) =>
      '<gx:duration>2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
  static String lookAt(double latitude, double longitude, bool scaleZoom,double tilt, double bearing) => '''<LookAt>
  <longitude>$longitude</longitude>
  <latitude>$latitude</latitude>
  <range>${7980}</range>
  <tilt>$tilt</tilt>
  <heading>$bearing</heading>
  <gx:altitudeMode>relativeToGround</gx:altitudeMode>
</LookAt>''';


  static String buildTourOrbit(double latitude, double longitude,
      double zoom, double tilt, double bearing) {
    String lookAts = '''<gx:FlyTo>
  <gx:duration>2.0</gx:duration>
  <gx:flyToMode>bounce</gx:flyToMode>
  ${lookAt(latitude,longitude,true, tilt, bearing)}
</gx:FlyTo>
''';
    lookAts+='''<gx:Wait>
    <gx:duration>1.0</gx:duration>   <!-- wait time in seconds -->
    </gx:Wait>''';
    var j = 0;
    for (int i = 0; i <= 360; i += 34) {
      if (j == 360) {
        j = 0;
      }
      lookAts += '''<gx:FlyTo>
  <gx:duration>5.0</gx:duration>
  <gx:flyToMode>smooth</gx:flyToMode>
  ${lookAt(latitude,longitude,true, double.parse(j.toString()),  double.parse(i.toString()))}
</gx:FlyTo>
''';
      j+=5;
    }

//     lookAts += '''<gx:FlyTo>
//   <gx:duration>5.0</gx:duration>
//   <gx:flyToMode>bounce</gx:flyToMode>
//   ${lookAt(ref.read(lastGMapPositionProvider)!, false)}
// </gx:FlyTo>
// ''';

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
   <gx:Tour>
   <name>Orbit</name>
      <gx:Playlist>
         $lookAts
      </gx:Playlist>
   </gx:Tour>
</kml>''';
  }

  static orbitBalloon(
      double latitude, double longitude,
      double zoom, double tilt, double bearing,
      String name,
      String imglink,
      String cityName
      ) =>
      '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
 <name>About Data</name>
 <Style id="about_style">
   <BalloonStyle>
     <textColor>ffffffff</textColor>
     <text>
        <h1>City: $cityName</h1>
        <img src="${imglink}" alt="picture" width="300" height="200"/> 
        <h2>$name</h2>
     </text>
     <bgColor>ff15151a</bgColor>
   </BalloonStyle>
 </Style>
 <Placemark id="Location">
   <description>
   </description>
   <LookAt>
     <longitude>${longitude}</longitude>
     <latitude>${latitude}</latitude>
     <heading>${bearing}</heading>
     <tilt>${tilt}</tilt>
     <range>${zoom}</range>
   </LookAt>
   <styleUrl>#about_style</styleUrl>
   <gx:balloonVisibility>1</gx:balloonVisibility>
   <Point>
     <coordinates>${longitude},${latitude},0</coordinates>
   </Point>
 </Placemark>
</Document>
</kml>''';
}
