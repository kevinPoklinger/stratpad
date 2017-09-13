var onload = function() {
    
    // this is added by the AdViewController
    //document.addEventListener('click', function(){document.location='%@';},false);
    
    // we need to stop clicks on the advertise link form also invoking the click on the doc
    document.getElementById('advertise').addEventListener('click', function(event){
                                                            event.stopPropagation();
                                                            document.location='http://alexglassey.com/stratpad/advertise';
                                                          }, false);           
};
window.addEventListener('load', onload, false);
