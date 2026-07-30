const express = require('express');
const app = express();
const { exec } = require('child_process');
const http = require('http').Server(app);
const io = require('socket.io')(http);
app.set('view engine', 'ejs');

app.use(express.static(__dirname + '/public'));

app.get('/', (req, res) => {
    res.render('index', {});
});

io.on('connection', (socket) => {
    const timer = setInterval(() => {
        exec('docker stats --no-stream', (err, stdout, stderr) => {
            if (err) {
                console.error(`exec error: ${err}`);
                return;
            }

            let output = stdout.split('\n');
            let headers = output[0].split(/\s{2,}/);
            let containers = output.slice(1).filter(line => line.trim()).map(line => {
                let data = line.split(/\s{2,}/);
                let container = {};
                headers.forEach((header, index) => {
                    container[header.toLowerCase()] = data[index];
                });

                // Convert memory usage to MiB and set memUnit accordingly
                if (container["mem usage / limit"]) {
                    let mem = container["mem usage / limit"].split('/')[0].trim();
                    let value = parseFloat(mem);

                    // The unit is three characters ("GiB"/"MiB"/"KiB"), so the
                    // old mem.slice(-2) === 'Gi' test never matched and every
                    // container was reported as MiB.
                    if (mem.endsWith('GiB')) {
                        value = value * 1024; // convert GiB to MiB
                        container.memUnit = 1; // GiB
                    } else if (mem.endsWith('KiB')) {
                        value = value / 1024; // convert KiB to MiB
                        container.memUnit = 0;
                    } else if (mem.endsWith('B') && !mem.endsWith('iB')) {
                        value = value / (1024 * 1024); // bytes to MiB
                        container.memUnit = 0;
                    } else {
                        container.memUnit = 0; // MiB
                    }

                    container.memValue = value;
                }

                return container;
            });

            socket.emit('docker stats', containers);
        });
    }, 2000); // update every 2 seconds

    // Without this the interval outlives the socket: every page load added a
    // permanent `docker stats` poller that ran for the lifetime of the process.
    socket.on('disconnect', () => clearInterval(timer));
});

http.listen(3000, () => console.log('Server is running on port 3000'));
