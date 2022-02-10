const express = require('express')
const multiparty = require('multiparty');
const sharp = require('sharp');
const app = express()

app.post('/api/img', function (req, res) {


    let form = new multiparty.Form();

    let image = {
        filename: 'untitled.',
        size: 0,
        buffer: []
    };

    form.on('close', () => {
        console.log('image process start')
        sharp(Buffer.concat(image.buffer))
            .webp()
            .toBuffer((err, data, info) => {
                console.log(err);
                console.log(info);
                console.log('image process end')
                res.set('Content-Type', 'image/webp');
                res.send(data);
            })
    });

    // listen on part event for image file
    form.on('part', function(part){
        if (!part.filename) return;
        if (part.name !== 'image') return part.resume();
        image.filename = part.filename;
        part.on('data', (buf) => {
            image.size += buf.length;
            image.buffer.push(buf);
        });
    });

    // parse the form
    form.parse(req);
})

app.listen(8081)
console.log('Express started on port 8081');