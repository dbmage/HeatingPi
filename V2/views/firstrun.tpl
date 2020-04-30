<!DOCTYPE html>
<html>
    <head>
        <title>HeatingPi setup</title>
        <meta name='viewport' content='width=device-width, initial-scale=1'>
        <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css'>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Two+Tone" rel="stylesheet">
        <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js'></script>
        <script src='https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js'></script>
        <script src='https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js'></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/zxcvbn/4.2.0/zxcvbn.js"></script>
        <style type='text/css'>
            .container {
                background-color: #e9ecef;
                width: 30%;
            }
            .fa-check {
                color: white;
            }
            .material-icons-two-tone, .material-icons{
                font-size: 36px;
                margin-top: 1px;
            }
            .progress-bar {
                width: 0%;
            }
        </style>
    </head>
    <body>
        <div class='jumbotron text-center'>
            <h1>HeatingPi first setup</h1>
        </div>
        <div class='container'>
            % include(content)
        </div>
    </body>

</html>
