var socket = io();
socket.on('docker stats', function(containers){
    var headersHtml = '';
    if (containers.length > 0) {
        for (var key in containers[0]) {
            if (key != 'memValue' && key != 'memUnit') {
                headersHtml += '<th>' + key + '</th>';
            }
        }
    }
    document.getElementById('thead').innerHTML = headersHtml;

    var html = '';
    for (var i=0; i < containers.length; i++){
        var c = containers[i];
        var memClass = '';
        if (c.memValue > 2048 && c.memValue <= 5120) memClass = 'warning'; // 2 GB to 5 GB (in MiB)
        else if (c.memValue > 5120) memClass = 'danger'; // over 5 GB (in MiB)
        else memClass = 'safe'; // less than 2 GB (in MiB)

        html += '<tr>';
        for (var key in c) {
            if (key != 'memValue' && key != 'memUnit') {
                if (key === "mem usage / limit") {
                    html += '<td class="'+memClass+'">'+c[key]+'</td>';
                } else {
                    html += '<td>'+c[key]+'</td>';
                }
            }
        }
        html += '</tr>';
    }
    document.getElementById('tbody').innerHTML = html;
});