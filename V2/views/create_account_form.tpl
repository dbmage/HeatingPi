<form action='/createuser' method='post'>
    <h2 class='d-flex justify-content-center'>Create a login</h2>
    <hr>
    <div class='form-group'>
        <div class='input-group row'>
            <span class='input-group-addon col-1 material-icons-two-tone d-flex justify-content-center'>info</span>
            <input type='text' class='form-control' id='fname' name='fname' placeholder='First Name' required='required'>
            <span class='col-1'></span>
            <input type='text' class='form-control' id='lname' name='lname' placeholder='Last Name' required='required'>
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
            <span class='input-group-addon col-1 material-icons-two-tone d-flex justify-content-center'>mail</span>
            <input type='email' class='form-control' id='email' name='email' placeholder='Email Address' required='required'>
        </div>
    </div>
    <div class='form-group'>
        <div class='input-group row'>
            <span class='input-group-addon col-1 material-icons-two-tone d-flex justify-content-center'>lock</span>
            <input id='passwd' type='password' class='form-control' name='password' placeholder='Password' required='required'>
        </div>
    </div>
    <div class='form-group'>
        <div class='input-group row'>
            <span class='input-group-addon col-1 material-icons d-flex justify-content-center'>lock</span>
            <input id='passconf' type='password' class='form-control' name='confirm_password' placeholder='Confirm Password' required='required'>
        </div>
    </div>
    <div class='form-group'>
        <div class='progress'>
            <span class='input-group-addon col-1 d-flex justify-content-center'>Password Strength</span>
            <div id='pwstr' class='progress-bar progress-bar-striped active' role='progressbar'
            aria-valuenow='0' aria-valuemin='0' aria-valuemax='100'>
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
    fname = document.getElementById('fname').value;
    lname = document.getElementById('lname').value;
    uname = document.getElementById('uname').value;
    email = document.getElementById('email').value;
    password = document.getElementById('passwd');
    passconf = document.getElementById('passconf');
    meter = document.getElementById('pwstr');
    function invalidate(domitem){
        domitem.classList.remove('valid')
        domitem.classList.add('invalid')
    };
    function validate(domitem){
        domitem.classList.remove('invalid')
        domitem.classList.add('valid')
    };
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
        invalidate(passconf)
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
        for ( thing in [fname, lname, uname, email] ){
            if ( !( passwd.value.includes(thing) ) ) {
                continue;
            };
            score += 1;
        }
        if ( score > 0 ) {
            invalidate(password);
            return;
        }
        validate(password);
    });
    passconf.addEventListener('input', function() {
        if (passconf.value == password.value) {
            validate(passconf)
            return;
        };
        invalidate(passconf)
    });
</script>
