<form action='/setup' method='post'>
    <h2 class='d-flex justify-content-center'>Setup Pins and usage</h2>
    <hr>
    <fieldset class="form-group">
        <div class="row">
            <legend class="col-form-label col-sm-2 pt-0">Use</legend>
            <div class="col-sm-10">
                <div class="custom-control custom-radio custom-control-inline">
                    <input class="custom-control-input" type="radio" name="heating" id="heating" value="heat">
                    <label class="custom-control-label" for="heating">Heating</label>
                </div>
                <div class="custom-control custom-radio custom-control-inline">
                    <input class="custom-control-input" type="radio" name="hotwater" id="hotwater" value="water">
                    <label class="custom-control-label" for="hotwater">Hot Water</label>
                </div>
                <div class="custom-control custom-radio custom-control-inline">
                    <input class="custom-control-input" type="radio" name="both" id="both" value="both">
                    <label class="custom-control-label" for="both">Both</label>
                </div>
            </div>
        </div>
    </fieldset>
    <fieldset class="form-group">
        <div class="row"> <!--need to add more rows on demand-->
            <legend class="col-form-label col-sm-2 pt-0">Pins</legend>
            <div class="col-sm-10">
                <select class="form-control" id="pina">
                </select>
                <input type="text" class="form-control" id="pinause">
            </div>
        </div>
    </fieldset>
</form>
<script type='text/javascript'>
    pins = {{pins}};
    pinselect = document.getElementById('pina');
    pinindex = 0
    for (pin in pins) {
        opt = document.createElement("option");
        opt.value = pinindex;
        opt.innerHTML = pin;
        pinselect.appendChild(opt);
        pinindex++;
    };
</script>
