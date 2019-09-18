import 'bootstrap/dist/css/bootstrap.min.css'
import jQuery from 'jquery'
import 'popper.js'
import 'bootstrap/dist/js/bootstrap.bundle.min.js'
import '@fortawesome/fontawesome-free/css/solid.min.css'
import '@fortawesome/fontawesome-free/css/fontawesome.min.css'

import css from '../css/app.scss';


import "phoenix_html"

jQuery(document).ready(function($) {
    $(".clickable-row").click(function() {
        // actual click event
        window.location = $(this).data("href");
    });

    $(".clickable-row").click(function() {
        // send google event
        ga('send', {
            hitType: 'event',
            eventCategory: 'Job',
            eventAction: 'Outbound Click',
            eventLabel: $(this).data("jl")
            });
    });

});