<!-- Form -->
<form action='/setup' method='post' novalidate>
    <h2 class='d-flex justify-content-center pt-3'>Setup Pins and usage</h2>
    <hr>
    <fieldset class='form-group'>
        <div class='row'>
            <div class='col-sm-1'>
            </div>
            <legend class='col-form-label col-sm-2 pt-0'>System use</legend>
            <div class='custom-control custom-radio custom-control-inline'>
                <input class='custom-control-input' type='radio' name='use' id='heating' value='heat' onclick='validateUse()' required>
                <label class='custom-control-label' for='heating'>Heating</label>
            </div>
            <div class='custom-control custom-radio custom-control-inline'>
                <input class='custom-control-input' type='radio' name='use' id='hotwater' value='water' onclick='validateUse()'>
                <label class='custom-control-label' for='hotwater'>Hot Water</label>
            </div>
            <div class='custom-control custom-radio custom-control-inline'>
                <input class='custom-control-input' type='radio' name='use' id='both' value='both' onclick='validateUse()'>
                <label class='custom-control-label' for='both'>Both</label>
            </div>
        </div>
        <div id='nouse' class='invalid-feedback' style='display:none' >Please select an option</div>
    </fieldset>
    <fieldset class='form-group'>
        <div class='row'>
            <div class='col-sm-1'>
            </div>
            <legend class='col-form-label col-sm-2 pt-0'>Pin use</legend>
            <div class='col-sm-7'>
                <table style='width:80%; table-layout: fixed' class='table table-striped' id='pins'>
                    <thead>
                        <th>Pin</th>
                        <th>Use</th>
                        <th></th>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <button type='button' class='btn btn-primary h-50' onclick='addPinModal()'>Add pin</button>
        </div>
    </fieldset>
    <div class='row pb-3'>
        <div class='col-sm-5'>
            <input style='display:none' id='pindata' name='pindata'>
        </div>
        <button type='submit' class='btn btn-primary' id='subbtn' disabled>Submit</button>
    </div>
</form>
<h3 id='error' style='display:none'></h3>
<!-- Modal -->
<div class='modal fade' id='add-pin'>
    <div class='modal-dialog'>
        <div class='modal-content'>
            <div class="modal-header">
                <h4 class="modal-title">Add pin use</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class-'row'>
                    <label class='col-form-label' for='pin'>Pin</label>
                    <div class='custom-control' >
                        <select class='custom-select' id='pin' name='pin'></select>
                    </div>
                </div>
                <div class-'row'>
                    <label class='col-form-label' for='pinuse'>Use</label>
                    <div class='custom-control'>
                        <input type='text' class='form-control' id='pinuse' name='pinuse' required>
                        <div class='invalid-feedback'>Must contain valid text</div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-success" onclick='addPinRow()'>Add</button>
                <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</modal>
<!-- javascript -->
<script type='text/javascript'>
    pins = {{pins}};
    pinset = [];
    seterror = {{error}};
    function formValidation() {
        useval = $('input[name=use]:checked').val() || '';
        pinval = $('#pindata').val() || '';
        if ( useval == '' && pinval == '' ) {
            $('#subbtn').prop('disabled', true);
        };
        $('#subbtn').prop('disabled', false);
    };

    function validateUse() {
        if ( typeof $('input[name=use]:checked').val() === 'undefined' ) {
            $('#nouse').show();
            return false;
        };
        $('#nouse').hide();
        return true;
    }

    function populatePinTable() {
        $('#pins').DataTable( {
            data : pinset,
            order : [[0, 'asc']],
            "columnDefs": [
                {
                "render": function ( data, type, row ) {
                    return "<button type='button' style='font-size: 18px;' class='btn btn-outline-danger btn-sm material-icons' onclick='removePinRow(" + row[0] + ")'>delete</button>";
                    },
                "targets": 2
                }
            ],
            'info' : false,
            'paging' : false,
            'searching' : false,
            'destroy' : true
        } );
        $('#pindata').val(JSON.stringify(pinset));
    };

    function addPinModal(){
        if ( validateUse() == false ) {
            return;
        }
        $('#pin').empty();
        pinselect = document.getElementById('pin');
        for (pin in pins) {
            opt = document.createElement('option');
            opt.value = pins[pin];
            opt.innerHTML = pins[pin];
            pinselect.appendChild(opt);
        };
        document.getElementById('pinuse').value = '';
        $("#add-pin").modal();
        return true;
    };

    function addPinRow(){
        pin = parseInt($('#pin').val());
        pinvalue = $('#pinuse').val();
        valuebox = document.getElementById('pinuse');
        valuenospace = pinvalue.replace(/\s+/g,'');
        if ( pinvalue.length < 1 || valuenospace.length < 1 ){
            valuebox.classList.add('is-invalid');
            return;
        };
        valuebox.classList.remove('is-invalid');
        pinset.push([ pin, pinvalue ]);
        pins.splice( pins.indexOf( pin ), 1 );
        $('#pin option[value="' + pin + '"]').remove();
        populatePinTable();
        valuebox.value = '';
        return true;
    };

    function removePinRow(pin) {
        pin = parseInt(pin);
        todo = [];
        for (row in pinset){
            if ( pinset[row][0] != pin ){
                continue;
            };
            todo.push(pinset[row]);
        };
        for ( x in todo ){
            pinset.splice( pinset.indexOf(todo[x]), 1);
            addBackToPins(todo[x][0]);
        }
        populatePinTable();
    };

    function addBackToPins(pin) {
        pin = parseInt(pin);
        origdata = pins;
        newdata = [];
        newdata[pin] = pin;
        for ( x in origdata ) {
            newdata[origdata[x]] = origdata[x];
        };
        pins = newdata;
    };
    $( document ).ready(function() {
        inputs = document.querySelectorAll('input');
        for ( input of inputs ) {
            input.addEventListener('change', (event) => {
                formValidation();
            });
        };
        if ( error != '' ) {
            $('#seterror').text(error);
            $('#seterror').show();
        };
    });
</script>
