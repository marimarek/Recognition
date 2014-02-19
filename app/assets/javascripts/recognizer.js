//#Place all the behaviors and hooks related to the matching controller here.
//#All this logic will automatically be available in application.js.
//#You can use CoffeeScript in this file: http://coffeescript.org/


var canvas;
var context;
var paint;

var ready = function() {
    prepareCanvas();

    $('#canvas').mousedown(function(e){
        paint = true;
        context.moveTo(e.pageX - this.offsetLeft, e.pageY - this.offsetTop);
        context.stroke();
    });

    $('#canvas').mousemove(function(e){
        if(paint){
            context.lineTo(e.pageX - this.offsetLeft, e.pageY - this.offsetTop);
            context.stroke();
        }
    });

    $('#canvas').mouseup(function(e){
        paint = false;
    });

    $('#canvas').mouseleave(function(e){
        paint = false;
    });

    $('#clear').mousedown(function(e)
    {
        context.closePath();
        clearCanvas();
        context.beginPath();
    });

    $('#send').mousedown(function(e)
    {
        var sendButton = document.getElementById("send");
        sendButton.disabled = true;

        scaleCanvas = document.createElement('canvas');
        scaleCanvas.setAttribute('width', 28);
        scaleCanvas.setAttribute('height', 28);
        var scaleContex = scaleCanvas.getContext('2d');
        scaleContex.scale(0.14, 0.14);
        scaleContex.drawImage(canvas, 0, 0);

        var imageData = scaleContex.getImageData(0, 0, scaleCanvas.width, scaleCanvas.height);
        var data = imageData.data;

        var pixels = new Array();
        for(var i = 0; i < data.length/4; ++i) {
            var brightness = 0.34 * data[4*i] + 0.5 * data[4*i + 1] + 0.16 * data[4*i + 2];
            pixels[i] = 255 - brightness;
        }

        $.ajax({
            type:  'post',
            url:  'recognizer/recognize',
            data:  {pixels: pixels, data_uri: scaleCanvas.toDataURL('image/png')},
            dataType: 'json',
            success: function(resp) {
                for(var i = 0; i < 10; ++i)
                    if(resp[i] < 0.0)
                        drawNumber(i, 0.0);
                    else if(resp[i] >= 1.0)
                        drawNumber(i, 1.0);
                    else
                        drawNumber(i, resp[i]);
            },
            timeout: 1500,
            error: function (xhr, ajaxOptions, thrownError) {
                alert(thrownError);
            },
            complete: function (xhr, ajaxOptions, thrownError) {
                sendButton.disabled = false;
            }

        });
    });
};

$(document).ready(ready);
$(document).on('page:load', ready);


function prepareCanvas()
{
    canvas = document.getElementById("canvas");
    context = canvas.getContext("2d");
    context.strokeStyle = "#000000";
    context.lineJoin = context.lineCap = "round";
    context.lineWidth = 8;
    clearCanvas();
    context.beginPath();
    paint = false;

    for(var i = 0; i < 10; ++i)
        drawNumber(i, 1.0);
}



function drawNumber(n, alpha)
{
    canvasN = document.getElementById("canvas"+ n.toString());
    contextN = canvasN.getContext("2d");
    contextN.clearRect(0, 0, canvasN.width, canvasN.height);
    contextN.font='60pt Calibri';
    contextN.textAlign = 'center';
    contextN.textBaseline = 'middle';
    contextN.globalAlpha = alpha;
    var x = canvasN.width / 2;
    var y = canvasN.height / 2;
    contextN.fillText(n.toString(),x,y);
}

function clearCanvas()
{
    context.fillStyle="#ffffff";
    context.fillRect(0, 0, canvas.getAttribute('width'), canvas.getAttribute('height'));
}