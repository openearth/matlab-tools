<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <script src="${request.static_url('bmidemo:assets/global/js/libs/socket.io/0.9.11/socket.io.js')}"></script>
    <script src="http://code.jquery.com/jquery-1.9.0.min.js"></script>
    <script src="http://d3js.org/d3.v3.min.js"></script>
    <script src="http://maps.googleapis.com/maps/api/js?sensor=false"></script>
    <style>
      html, body, #map { height: 100%}
      #map {
      width: 100%;
      }

      // We can have multiple overlays
      .SvgOverlay {
      position: relative;
      width: 100%;;
      height: 100%;
      }

      .SvgOverlay svg {
      position: absolute;
      top: -4000px;
      left: -4000px;
      width: 8000px;
      height: 8000px;
      }

      .SvgOverlay path {
      fill: grey;
      fill-opacity: .7;
      }

      audio {
      display: none;
      }
    </style>
  </head>
  <body>

    <div id="map"></div>

    <script src="${request.static_url('bmidemo:assets/js/map.js')}"></script>
    <audio id="ee">
      <source src="${request.static_url('bmidemo:assets/eastenders.mp3')}" type="audio/mpeg">
    </audio>
  </body>
</html>
