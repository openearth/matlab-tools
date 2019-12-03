<!doctype html>
<head>
  <title>BMI example application</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="keywords" content="python web application" />
  <meta name="description" content="pyramid web application" />
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <link href="http://fonts.googleapis.com/css?family=Cantata+One|Electrolize|Donegal+One" rel="stylesheet" type="text/css" />

  <link rel="shortcut icon" href="${request.static_url('bmidemo:assets/favicon.ico')}" />

  <link rel="stylesheet" href="${request.static_url('bmidemo:assets/bootstrap/css/bootstrap.min.css')}">
  <link rel="stylesheet" href="${request.static_url('bmidemo:assets/bootstrap/css/bootstrap.min.responsive.css')}">
  <link rel="stylesheet" href="${request.static_url('bmidemo:assets/global/css/bmidemo.css')}" />
  <script src="${request.static_url('bmidemo:assets/global/js/libs/jquery/1.8.3/jquery.min.js')}"></script>
  <script src="${request.static_url('bmidemo:assets/global/js/libs/modernizr/modernizr.js')}"></script>
  <script src="${request.static_url('bmidemo:assets/global/js/libs/processing/1.4.1/processing.js')}"></script>
  <script src="${request.static_url('bmidemo:assets/global/js/libs/socket.io/0.9.11/socket.io.js')}"></script>
</head>
<body>
  <section>
    <header class="container-fluid">
      Flexible Mesh html5 demo
    </header>
    <div class="container-fluid middle">
      <canvas data-processing-sources="${request.static_url('bmidemo:assets/global/processing/streamlines.pde')}"></canvas>
    </div>
    <div class="container-fluid content">

    </div>
  </section>
  <footer class="container-fluid">

  </footer>
</body>
</html>
