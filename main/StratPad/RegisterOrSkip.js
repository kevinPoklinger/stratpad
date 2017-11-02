var eles = ["l1","l2","l3","l4", "thanks"];
function hide() {
    for (var i=0; i<eles.length;i++) {
        document.getElementById(eles[i]).className = "hidden";
    }
}
function show() {
    for (var i=0; i<eles.length;i++) {
        document.getElementById(eles[i]).className = "";
    }
}
function toggle() {
    if (document.getElementById(eles[0]).className == "hidden") {
        show();
    } else {
        hide();
    }
}
