<!DOCTYPE html>
<html>
    <head>
        <title>HeatingPi setup</title>
        % include('header.tpl')
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
