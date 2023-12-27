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
    setInterval(() => {
        exec('docker stats --no-stream', (err, stdout, stderr) => {
            if (err) {
                console.error(`exec error: ${err}`);
                return;
            }

            let output = stdout.split('\n');
            let headers = output[0].split(/\s{2,}/);
            let containers = output.slice(1, -1).map(line => {
                let data = line.split(/\s{2,}/);
                let container = {};
                headers.forEach((header, index) => {
                    container[header.toLowerCase()] = data[index];
                });

                // Convert memory usage to MiB and set memUnit accordingly
                if (container["mem usage / limit"]) {
                    let mem = container["mem usage / limit"].split('/')[0].trim();
                    let value = parseFloat(mem);
                    let suffix = mem.slice(-2);

                    if (suffix == 'Gi') {
                        value = value * 1024; // convert GiB to MiB
                        container.memUnit = 1; // GiB
                    } else { 
                        container.memUnit = 0; // assume MiB if not GiB
                        // Adjust this part if there are more units you need to handle
                    }

                    container.memValue = value;
                }

                return container;
            });

            socket.emit('docker stats', containers);
        });
    }, 2000); // update every 2 seconds
});

http.listen(3000, () => console.log('Server is running on port 3000'));
