<!DOCTYPE html><!--[if lt IE 7]><html class="no-js ie ie6 lt-ie7 lt-ie8 lt-ie9 lt-ie10"><![endif]-->
<!--[if IE 7]>   <html class="no-js ie ie7 lt-ie8 lt-ie9 lt-ie10"><![endif]-->
<!--[if IE 8]>   <html class="no-js ie ie8 lt-ie9 lt-ie10"><![endif]-->
<!--[if IE 9]>   <html class="no-js ie ie9 lt-ie10"><![endif]-->
<!--[if gt IE 9]><html class="no-js ie ie10"><![endif]-->
<!--[if !IE]><!-->
<html class="no-js"><!--<![endif]-->
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1">
    <title>Sea level monitor</title>
    <!-- Modernizr -->
    <script src="${request.static_url('sealevel:static/js/libs/modernizr-2.6.2.min.js')}"></script>
    <!-- jQuery-->
    <script type="text/javascript" src="${request.static_url('sealevel:static/js/libs/jquery-1.10.2.min.js')}"></script>
    <link rel="stylesheet" href="${request.static_url('sealevel:static/css/ui-lightness/jquery-ui-1.10.3.custom.min.css')}" />
    <script src="${request.static_url('sealevel:static/js/libs/jquery-ui-1.10.3.custom.min.js')}"></script>
    <!-- framework css -->
    <!--[if gt IE 9]>
        <!-->
        <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork.css')}">
        <!--<![endif]-->
        <!--[if lte IE 9]>
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-core.css')}">
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-type.css')}">
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-ui.css')}">
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-anim.css')}">
            <link type="text/css" rel="stylesheet" href="${request.static_url('sealevel:static/css/groundwork-ie.css')}">
            <![endif]-->
    <link rel="stylesheet" href="${request.static_url('sealevel:static/css/main.css')}" type="text/css" media="screen" />
    <script type="text/javascript" src="${request.static_url('sealevel:static/js/libs/jquery-1.10.2.min.js')}"></script>
    <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.css" />
    <!--[if lte IE 8]>
        <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.ie.css" />
        <![endif]-->
    <script src="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js"></script>
    <script src="http://d3js.org/d3.v3.min.js"></script>
    <link rel="stylesheet" href="${request.static_url('sealevel:static/css/map.css')}" type="text/css" media="screen" />
</head>
<body>
  <header class="padded">
    <div class="container">
      <div class="row">
        <div class="one third">
          <h2 class="logo"><a href="/" target="_parent"><img src="${request.static_url('sealevel:static/images/deltares.gif')}" alt="Deltares"></a></h2>
        </div>
        <div class=" bounceInRight animated one third">
          <h1 class="zero">${_("Sea level monitor")}</h1>
        </div>
        <div class="one third">
          <p class="small double pad-top no-pad-small-tablet align-right align-left-small-tablet"> <a href="http://www.openearth.nl">Source</a> </p>
        </div>
      </div>
      <nav role="navigation" class="nav gap-top">
        <ul role="menubar">
          <li><a href="/"><i class="icon-home"></i> Home</a></li>
          <li role="menu">
            <button>Analysis</button>
            <ul>
              <li><a href="${request.route_url('map')}">World</a></li>
              <li><a href="${request.route_url('map')}">Europe</a></li>
              <li><a href="${request.route_url('main', _query=dict(station='DUTCH MEAN'))}">The Netherlands</a></li>
            </ul>
          </li>
          <li role="menu">
            <button>Background</button>
            <ul>
              <li><a href="${request.static_url('sealevel:static/reports/report.pdf')}" title="Report">Report</a></li>
              <li><a href="${request.static_url('sealevel:static/reports/method.pdf')}" title="Method">Method description</a></li>
            </ul>
          </li>
        </ul>
      </nav>
    </div>
  </header>
  <div class="container">
    <hr>
    <article class="row">
      <section class="three fourths padded bounceIn animated">
        <div id="map"></div>
        <script src="${request.static_url('sealevel:static/js/map.js')}"></script>
      </section>

      <aside class="one fourth padded border-left bounceInRight animated">
        <h2>Sea level trend</h2>
        <div id="plot"></div>
      </aside>
    </article>

  </div>
  <footer class="gap-top bounceInUp animated">
    <div class="box square charcoal">
      <div class="container padded">
        <div class="row">
          <div class="one small-tablet fourth padded">
            Footer
          </div>
        </div>
      </div>
    </div>
  </footer>
  <!-- javascript-->
  <script type="text/javascript" src="${request.static_url('sealevel:static/js/groundwork.all.js')}"></script>
  <!-- google analytics-->

</body>
</html>
