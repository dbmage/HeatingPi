<form action='/createuser' method='post'>
    <h2 class='d-flex justify-content-center'>Create a login</h2>
    <hr>
    <div class='form-group'>
        <div class='input-group row'>
            <span class='input-group-addon col-1 material-icons-two-tone d-flex justify-content-center'>info</span>
            <input type='text' class='form-control' id='fname' name='fname' placeholder='Full Name' required='required'>
        </div>
    </div>
    <div class='form-group'>
        <div class='input-group row'>
            <span class='input-group-addon col-1 material-icons-two-tone d-flex justify-content-center'>account_circle</span>
            <input type='text' class='form-control' id='uname' name='username' placeholder='Username' required='required'>
        </div>
    </div>
    <div class='form-group'>
        <div class='input-group row'>
            <span class='input-group-addon col-1 material-icons-two-tone d-flex justify-content-center'>lock</span>
            <input id='passwd' type='password' class='form-control' name='password' placeholder='Password' required='required' data-toggle="tooltip" title="Password must not contain your name or username">
        </div>
    </div>
    <div class='form-group'>
        <div class='input-group row'>
            <span class='input-group-addon col-1 material-icons d-flex justify-content-center'>lock</span>
            <input id='passconf' type='password' class='form-control' name='confirm_password' placeholder='Confirm Password' required='required' data-toggle="tooltip" title="Passwords do not match">
        </div>
    </div>
    <div class='form-group'>
        <span class='input-group-addon col-3 d-flex justify-content-center'>Password Strength</span>
        <div class='progress bg-light'>
            <div id='pwstr' class='progress-bar progress-bar-striped active'>
            </div>
        </div>
    </div>
    <div class='form-group'>
        <button type='submit' class='btn btn-primary btn-lg'>Sign Up</button>
    </div>
</form>
<script type='text/javascript'>
    strength = {
        1: 'Bad',
        2: 'Weak',
        3: 'Good',
        4: 'Strong'
    };
    colours = {
        1: 'error',
        2: 'error',
        3: 'warning',
        4: 'success'
    }
    $('[data-toggle="tooltip"]').tooltip();
    names = document.getElementById('fname').value.toLowerCase().split(' ');
    username = document.getElementById('uname');
    uname = username.value.toLowerCase();
    password = document.getElementById('passwd');
    passconf = document.getElementById('passconf');
    meter = document.getElementById('pwstr');
    function invalidate(domitem){
        $('#' + domitem.id).tooltip('show')
        domitem.classList.remove('is-valid')
        domitem.classList.add('is-invalid')
    };
    function validate(domitem){
        $('#' + domitem.id).tooltip('hide');
        domitem.classList.remove('is-invalid');
        domitem.classList.add('is-valid');
    };
    username.addEventListener('input', function() {
        username.value = username.value.toLowerCase();
    });
    password.addEventListener('input', function() {
        $('#pwstr').removeClass (function (index, className) {
            return (className.match (/(^|\s)bg-\S+/g) || []).join(' ');
        });
        if (password.value == '') {
            meter.innerHTML = '';
            meter.style.width = '0%';
            invalidate(password);
            return;
        };
        if (passconf.value == password.value) {
            validate(passconf)
            return;
        };
        if ( passconf.value != '' ){
            invalidate(passconf)
        };
        result = zxcvbn(password.value);
        // Update the password strength meter
        if ( result.score == 0 ){
            result.score = 1;
        }
        meter.style.width = result.score * 25 + '%';
        // Update the text indicator
        meter.innerHTML = strength[result.score];
        meter.classList.add('bg-' + colours[result.score])
        score = 0
        [fname, uname].concat(names).forEach(function(thing) {
            if ( !( passwd.value.toLowerCase().includes(thing) ) ) {
                return;
            };
            score += 1;
        });
        if ( score > 0 ) {
            invalidate(password);
            return;
        }
        validate(password);
    });
    passconf.addEventListener('input', function() {
        if (passconf.value.toLowerCase() == password.value.toLowerCase()) {
            validate(passconf)
            return;
        };
        invalidate(passconf)
    });
</script>
